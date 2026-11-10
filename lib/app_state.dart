// app_state.dart
// Otak aplikasi: menyimpan data dan semua aturan (slot 3 montir per jam,
// jam istirahat, pembayaran, pengingat besok, dsb). Semua layar membaca dari sini.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

/// Daftar layar. Berpindah layar = mengganti nilai AppState.screen.
enum Screen {
  welcome,
  login,
  motor,
  home,
  service,
  schedule,
  montir,
  pay,
  confirm,
  history,
  account,
  oHome,
  oBookings,
  oServices,
  oSettings,
  oReport,
  ownerPin, // layar PIN pemilik (tersembunyi, hanya muncul bila nomor pemilik dipakai)
}

/// Kunci untuk menampilkan notifikasi kecil (SnackBar) dari mana saja.
final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Pilihan sementara saat pelanggan membuat booking (langkah 1 sampai 4).
class Draft {
  String? svc;
  String date = '';
  String? time;
  String? montir;
  String? pay;
}

/// Satu jam booking beserta sisa slot (jumlah montir yang masih kosong).
class Slot {
  final String time;
  final int left;
  final bool past;
  Slot(this.time, this.left, this.past);

  bool get off => left <= 0 || past; // tidak bisa dipilih
  bool get full => left <= 0 && !past; // penuh
}

class AppState extends ChangeNotifier {
  static const String prefsKey = 'bengkelku-flutter-v1';
  static const String demoCust = '081234567890';
  static const String demoOwner = '081111111111';

  late DateTime today;
  bool dark = true;
  AppUser? user;
  Screen screen = Screen.welcome;
  String mode = 'masuk'; // 'masuk' atau 'daftar'
  String error = '';

  Map<String, Customer> customers = {};
  Shop shop = defaultShop();
  List<Service> services = [];
  List<Montir> montir = [];
  List<Booking> bookings = [];
  int nextId = 2000;
  Map<String, String> remind = {};

  Draft draft = Draft();
  String ownTab = 'baru'; // baru | proses | selesai
  String ownDate = 'semua'; // semua | hari | besok
  int? lastId;

  // --- Masuk pemilik (tersembunyi) ---
  String? pendingOwnerPhone;
  int _pinFails = 0;
  DateTime? _pinLockUntil;

  SharedPreferences? _prefs;

  AppState() {
    today = todayDate();
    _fresh();
  }

  // ====================== DATA AWAL & PENYIMPANAN ======================
  void _fresh() {
    customers = {
      demoCust: Customer(
        name: 'Budi Santoso',
        motor: Motor(brand: 'Honda Beat', plate: 'AB 1234 XY', year: '2020'),
      ),
    };
    shop = defaultShop();
    services = defaultServices();
    montir = defaultMontir();
    bookings = seedBookings(today, demoCust);
    nextId = 2000 + bookings.length;
    remind = {};
    user = null;
    screen = Screen.welcome;
    draft = Draft();
    lastId = null;
    ownTab = 'baru';
    ownDate = 'semua';
    error = '';
  }

  Timer? _poll;
  String? _lastRaw;

  /// Dipanggil sekali di main() sebelum aplikasi tampil: memuat data yang tersimpan.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString(prefsKey);
      if (raw != null) {
        _lastRaw = raw;
        _hydrate(raw, withSession: true);
      }
    } catch (_) {
      // Jika data lama rusak, pakai data awal
      _fresh();
    }
    // Cek perubahan dari tab / jendela lain setiap 1 detik.
    // Jadi booking dari tab pelanggan langsung muncul di tab pemilik.
    // (hanya di web; di Android hanya ada satu jendela aplikasi)
    if (kIsWeb) {
      _poll = Timer.periodic(const Duration(seconds: 1), (_) => _checkRemote());
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _checkRemote() async {
    final p = _prefs;
    if (p == null) return;
    try {
      await p.reload();
      final raw = p.getString(prefsKey);
      if (raw == null || raw == _lastRaw) return;
      _lastRaw = raw;
      _hydrate(raw, withSession: false); // sesi login tab ini tidak diubah
      notifyListeners();
    } catch (_) {
      // abaikan, coba lagi pada pengecekan berikutnya
    }
  }

  /// Membaca data tersimpan. withSession = true hanya saat aplikasi pertama dibuka.
  void _hydrate(String raw, {required bool withSession}) {
    final j = jsonDecode(raw) as Map<String, dynamic>;

    // Geser tanggal booking contoh supaya tetap "hari ini / besok" bila aplikasi dibuka di hari lain
    final seedDay = (j['seedDay'] as String?) ?? iso(today);
    final delta = (today.difference(parseD(seedDay)).inHours / 24).round();

    final loadedBookings = (j['bookings'] as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
    if (delta != 0) {
      for (final b in loadedBookings) {
        b.date = iso(addDays(parseD(b.date), delta));
      }
    }

    customers = (j['customers'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, Customer.fromJson(v as Map<String, dynamic>)),
    );
    shop = Shop.fromJson(j['shop'] as Map<String, dynamic>);
    services = (j['services'] as List)
        .map((e) => Service.fromJson(e as Map<String, dynamic>))
        .toList();
    montir = (j['montir'] as List)
        .map((e) => Montir.fromJson(e as Map<String, dynamic>))
        .toList();
    bookings = loadedBookings;
    nextId = (j['nextId'] as num).toInt();
    remind = (j['remind'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String));
    if (withSession) {
      dark = (j['dark'] as bool?) ?? true;
    }
  }

  Map<String, dynamic> _toJson() => {
        'customers': customers.map((k, v) => MapEntry(k, v.toJson())),
        'bookings': bookings.map((b) => b.toJson()).toList(),
        'shop': shop.toJson(),
        'services': services.map((s) => s.toJson()).toList(),
        'montir': montir.map((m) => m.toJson()).toList(),
        'nextId': nextId,
        'seedDay': iso(today),
        'remind': remind,
        'dark': dark,
      };

  void _save() {
    final raw = jsonEncode(_toJson());
    _lastRaw = raw;
    _prefs?.setString(prefsKey, raw);
  }

  /// Setiap ada perubahan: perbarui tampilan + simpan.
  void changed() {
    notifyListeners();
    _save();
  }

  void toast(String msg) {
    final m = messengerKey.currentState;
    if (m == null) return;
    m.removeCurrentSnackBar();
    m.showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      width: 300,
    ));
  }

  void toggleTheme() {
    dark = !dark;
    changed();
  }

  void resetDemo() {
    _prefs?.remove(prefsKey);
    _fresh();
    notifyListeners();
    toast('Data demo diulang dari awal');
  }

  // ====================== PEMBANTU ======================
  Customer? get me => user == null ? null : customers[user!.phone];

  List<Booking> get mine => user == null
      ? <Booking>[]
      : bookings.where((b) => b.phone.isNotEmpty && b.phone == user!.phone).toList();

  Service? svcOf(String? id) {
    for (final s in services) {
      if (s.id == id) return s;
    }
    return null;
  }

  Montir? montirOf(String? id) {
    for (final m in montir) {
      if (m.id == id) return m;
    }
    return null;
  }

  int get activeN => montir.where((m) => m.active).length;
  String get todayIso => iso(today);
  String isoDay(int offset) => iso(addDays(today, offset));
  int get pendingCount => bookings.where((b) => b.status == 'menunggu').length;
  List<Booking> get todayBookings => bookings.where((b) => b.date == todayIso && b.live).toList();

  // ====================== JAM, SLOT, MONTIR ======================
  bool inBreak(int h) {
    final bs = int.parse(shop.breakStart.split(':')[0]);
    final be = int.parse(shop.breakEnd.split(':')[0]);
    return h >= bs && h < be;
  }

  Hours? hoursFor(String ds) {
    final w = parseD(ds).weekday;
    if (w == 7) return shop.sun;
    if (w == 6) return shop.sat;
    return shop.wk;
  }

  /// Montir yang masih kosong pada tanggal & jam tertentu.
  /// Satu montir hanya bisa menangani satu pelanggan per jam.
  List<Montir> freeMontir(String date, String time) {
    return montir
        .where((m) =>
            m.active &&
            !bookings.any((b) => b.date == date && b.time == time && b.montir == m.id && b.live))
        .toList();
  }

  /// Daftar jam booking untuk satu tanggal (jam istirahat otomatis dilewati).
  List<Slot> slotsFor(String date) {
    final cfg = hoursFor(date);
    if (cfg == null || shop.closedNow || activeN == 0) return [];
    final oh = int.parse(cfg.open.split(':')[0]);
    final ch = int.parse(cfg.close.split(':')[0]);
    final now = DateTime.now();
    final out = <Slot>[];
    for (var h = oh; h < ch; h++) {
      if (inBreak(h)) continue;
      final time = '${pad(h)}:00';
      final left = freeMontir(date, time).length;
      final past = date == todayIso && h <= now.hour;
      out.add(Slot(time, left, past));
    }
    return out;
  }

  /// Status satu hari: 'ada' (masih ada slot), 'penuh', 'tutup', atau 'lewat'.
  String dayInfo(String ds) {
    if (hoursFor(ds) == null || shop.closedNow || activeN == 0) return 'tutup';
    final sl = slotsFor(ds).where((s) => !s.past).toList();
    if (sl.isEmpty) return 'lewat';
    return sl.any((s) => !s.off) ? 'ada' : 'penuh';
  }

  String firstOpenDate() {
    for (var i = 0; i < 7; i++) {
      final d = isoDay(i);
      if (slotsFor(d).any((s) => !s.off)) return d;
    }
    return todayIso;
  }

  // ====================== PENGINGAT BESOK ======================
  List<Booking> tomorrowMine() {
    final t = isoDay(1);
    final l = mine
        .where((b) => b.date == t && ['menunggu', 'diterima', 'dikerjakan'].contains(b.status))
        .toList();
    l.sort(cmpBooking);
    return l;
  }

  List<Booking> tomorrowAll() => bookings
      .where((b) => b.date == isoDay(1) && ['menunggu', 'diterima'].contains(b.status))
      .toList();

  /// True jika pengingat perlu ditampilkan (maksimal sekali per hari per pelanggan).
  bool consumeRemind() {
    if (user == null || user!.role != 'customer') return false;
    if (tomorrowMine().isEmpty) return false;
    if (remind[user!.phone] == todayIso) return false;
    remind[user!.phone] = todayIso;
    _save();
    return true;
  }

  // ====================== NAVIGASI & LOGIN ======================
  void goTo(Screen s) {
    screen = s;
    error = '';
    changed();
  }

  /// Layar awal: tombol kembali Android boleh menutup aplikasi.
  bool get isRootScreen =>
      screen == Screen.welcome || screen == Screen.home || screen == Screen.oHome;

  /// Dipanggil saat tombol kembali Android ditekan: mundur satu langkah di alur aplikasi.
  void back() {
    switch (screen) {
      case Screen.login:
        goTo(Screen.welcome);
        break;
      case Screen.motor:
        if (me?.motor != null) {
          goTo(Screen.account);
        } else {
          logout();
        }
        break;
      case Screen.service:
      case Screen.history:
      case Screen.account:
      case Screen.confirm:
        goTo(Screen.home);
        break;
      case Screen.schedule:
        goTo(Screen.service);
        break;
      case Screen.montir:
        goTo(Screen.schedule);
        break;
      case Screen.pay:
        goTo(Screen.montir);
        break;
      case Screen.oBookings:
      case Screen.oServices:
      case Screen.oReport:
        goTo(Screen.oHome);
        break;
      case Screen.oSettings:
        goTo(Screen.oServices);
        break;
      case Screen.ownerPin:
        cancelOwnerLogin();
        break;
      default:
        break;
    }
  }

  void goLogin(String m) {
    mode = m;
    goTo(Screen.login);
  }

  void sendLogin(String name, String phone) {
    final ph = digits(phone);
    final nm = name.trim();
    if (ph.length < 9) {
      error = 'Masukkan nomor HP yang valid, minimal 9 digit.';
      changed();
      return;
    }
    // Nomor pemilik => diminta PIN dulu. Pelanggan biasa tidak pernah melihat layar ini.
    if (ph == digits(shop.ownerPhone)) {
      pendingOwnerPhone = ph;
      goTo(Screen.ownerPin);
      return;
    }
    final rec = customers[ph];
    if (rec == null && nm.isEmpty) {
      error = 'Nama belum diisi.';
      changed();
      return;
    }
    if (rec == null) {
      customers[ph] = Customer(name: nm);
    } else if (nm.isNotEmpty) {
      rec.name = nm;
    }
    _loginAs('customer', ph);
  }

  void demo(String role) {
    _loginAs(role, role == 'owner' ? demoOwner : demoCust);
  }

  void _loginAs(String role, String phone) {
    user = AppUser(role, phone);
    if (role == 'owner') {
      goTo(Screen.oHome);
      return;
    }
    final rec = customers[phone];
    goTo(rec != null && rec.motor != null ? Screen.home : Screen.motor);
  }

  void logout() {
    user = null;
    pendingOwnerPhone = null;
    goTo(Screen.welcome);
  }

  /// Memeriksa PIN pemilik. Mengembalikan pesan error, atau null bila berhasil masuk.
  /// Salah 5 kali = dikunci 1 menit.
  String? verifyOwnerPin(String pin) {
    final until = _pinLockUntil;
    if (until != null && DateTime.now().isBefore(until)) {
      final s = until.difference(DateTime.now()).inSeconds + 1;
      return 'Terlalu banyak percobaan. Coba lagi dalam $s detik.';
    }
    if (pin.trim() == shop.ownerPin) {
      _pinFails = 0;
      _pinLockUntil = null;
      final ph = pendingOwnerPhone ?? digits(shop.ownerPhone);
      pendingOwnerPhone = null;
      _loginAs('owner', ph);
      return null;
    }
    _pinFails++;
    if (_pinFails >= 5) {
      _pinFails = 0;
      _pinLockUntil = DateTime.now().add(const Duration(minutes: 1));
      return 'PIN salah 5 kali. Coba lagi dalam 1 menit.';
    }
    return 'PIN salah. Sisa percobaan ${5 - _pinFails}.';
  }

  void cancelOwnerLogin() {
    pendingOwnerPhone = null;
    goTo(Screen.login);
  }

  String? saveMotor(String brand, String plate, String year) {
    if (brand.trim().isEmpty || plate.trim().isEmpty) {
      return 'Merek dan plat nomor wajib diisi.';
    }
    final c = me;
    if (c == null) return 'Data pengguna tidak ditemukan.';
    c.motor = Motor(brand: brand.trim(), plate: plate.trim().toUpperCase(), year: year.trim());
    toast('Data motor tersimpan');
    goTo(Screen.home);
    return null;
  }

  // ====================== ALUR BOOKING PELANGGAN ======================
  void pickSvc(String id) {
    draft.svc = id;
    changed();
  }

  void toSchedule() {
    draft.date = firstOpenDate();
    draft.time = null;
    draft.montir = null;
    goTo(Screen.schedule);
  }

  void pickDate(String d) {
    draft.date = d;
    draft.time = null;
    draft.montir = null;
    changed();
  }

  void pickTime(String t) {
    draft.time = t;
    draft.montir = null;
    changed();
  }

  void toMontir() {
    draft.montir = null;
    goTo(Screen.montir);
  }

  void pickMontir(String id) {
    draft.montir = id;
    changed();
  }

  void toPay() {
    draft.pay = null;
    goTo(Screen.pay);
  }

  void pickPay(String k) {
    draft.pay = k;
    changed();
  }

  /// Pindah ke tanggal berikutnya yang masih punya slot kosong.
  void nextFree() {
    for (var i = 0; i < 7; i++) {
      final ds = isoDay(i);
      if (ds.compareTo(draft.date) > 0 && dayInfo(ds) == 'ada') {
        draft.date = ds;
        draft.time = null;
        draft.montir = null;
        toast('Pindah ke ${dlabel(ds)}');
        changed();
        return;
      }
    }
    toast('Belum ada jadwal kosong dalam 7 hari ke depan');
  }

  void book() {
    final s = svcOf(draft.svc);
    final m = montirOf(draft.montir);
    final mt = me?.motor;
    final t = draft.time;
    final ok = s != null &&
        m != null &&
        mt != null &&
        t != null &&
        draft.pay != null &&
        freeMontir(draft.date, t).any((x) => x.id == m.id);
    if (!ok) {
      toast('Montir di jam ini sudah terisi, pilih ulang');
      draft.montir = null;
      goTo(Screen.schedule);
      return;
    }
    final b = Booking(
      id: nextId++,
      date: draft.date,
      time: t,
      cust: me!.name,
      phone: user!.phone,
      veh: mt.brand,
      plate: mt.plate,
      svc: s.id,
      svcName: s.name,
      price: s.price,
      status: shop.auto ? 'diterima' : 'menunggu',
      montir: m.id,
      montirName: m.name,
      payMethod: draft.pay!,
      paid: false,
    );
    bookings.add(b);
    lastId = b.id;
    draft = Draft();
    goTo(Screen.confirm);
  }

  // ====================== STATUS BOOKING (PELANGGAN & PEMILIK) ======================
  void _setStatus(int id, String st, String msg) {
    for (final b in bookings) {
      if (b.id == id) {
        b.status = st;
        // Cash: otomatis lunas saat servis selesai
        if (st == 'selesai' && b.payMethod == 'cash') b.paid = true;
        toast(msg);
      }
    }
    changed();
  }

  void cancelBooking(int id) => _setStatus(id, 'dibatalkan', 'Booking dibatalkan');
  void acceptBooking(int id) => _setStatus(id, 'diterima', 'Booking diterima');
  void rejectBooking(int id) => _setStatus(id, 'ditolak', 'Booking ditolak');
  void startBooking(int id) => _setStatus(id, 'dikerjakan', 'Pengerjaan dimulai');
  void finishBooking(int id) => _setStatus(id, 'selesai', 'Booking selesai');

  void markPaid(int id) {
    for (final b in bookings) {
      if (b.id == id) {
        b.paid = true;
        toast('Ditandai lunas');
      }
    }
    changed();
  }

  // ====================== SISI PEMILIK ======================
  void setOwnTab(String t) {
    ownTab = t;
    changed();
  }

  void setOwnDate(String d) {
    ownDate = d;
    changed();
  }

  void ownPending() {
    ownTab = 'baru';
    ownDate = 'semua';
    goTo(Screen.oBookings);
  }

  void ownTomorrow() {
    ownDate = 'besok';
    ownTab = tomorrowAll().any((b) => b.status == 'menunggu') ? 'baru' : 'proses';
    goTo(Screen.oBookings);
  }

  void toggleClosed() {
    shop.closedNow = !shop.closedNow;
    toast(shop.closedNow ? 'Bengkel ditutup sementara' : 'Bengkel dibuka kembali');
    changed();
  }

  void toggleAuto() {
    shop.auto = !shop.auto;
    toast(shop.auto ? 'Booking diterima otomatis' : 'Booking perlu persetujuan');
    changed();
  }

  /// Simpan layanan baru (id == null) atau ubah layanan lama. Mengembalikan pesan error bila gagal.
  String? saveService(String? id, String name, String priceText, String durText) {
    final price = int.tryParse(priceText.trim()) ?? 0;
    final dur = int.tryParse(durText.trim()) ?? 0;
    if (name.trim().isEmpty || price <= 0 || dur <= 0) {
      return 'Isi nama, harga, dan durasi dengan benar.';
    }
    if (id == null) {
      services.add(Service(
        id: 's${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        price: price,
        dur: dur,
      ));
    } else {
      final s = svcOf(id);
      if (s != null) {
        s.name = name.trim();
        s.price = price;
        s.dur = dur;
      }
    }
    toast('Layanan disimpan');
    changed();
    return null;
  }

  void deleteService(String id) {
    services.removeWhere((s) => s.id == id);
    toast('Layanan dihapus');
    changed();
  }

  String? saveMontir(String id, String name) {
    if (name.trim().isEmpty) return 'Nama montir belum diisi.';
    final m = montirOf(id);
    if (m != null) {
      m.name = name.trim();
      for (final b in bookings) {
        if (b.montir == id) b.montirName = m.name;
      }
    }
    toast('Montir disimpan');
    changed();
    return null;
  }

  void toggleMontir(String id) {
    final m = montirOf(id);
    if (m == null) return;
    if (m.active && activeN <= 1) {
      toast('Minimal satu montir harus aktif');
      return;
    }
    m.active = !m.active;
    toast(m.active ? '${m.name} aktif' : '${m.name} libur');
    changed();
  }

  /// Simpan pengaturan bengkel. Mengembalikan pesan error bila ada yang tidak valid.
  String? saveSettings({
    required String name,
    required String address,
    required String phone,
    required String bank,
    required String rek,
    required String an,
    required Hours wk,
    required Hours sat,
    required Hours? sun,
    required String breakStart,
    required String breakEnd,
    required String ownerPhone,
    required String ownerPin,
  }) {
    for (final h in [wk, sat, sun]) {
      if (h != null && h.open.compareTo(h.close) >= 0) {
        return 'Jam tutup harus setelah jam buka.';
      }
    }
    if (breakStart.compareTo(breakEnd) >= 0) {
      return 'Jam selesai istirahat harus setelah jam mulai.';
    }
    if (name.trim().isEmpty) return 'Nama bengkel belum diisi.';
    if (digits(ownerPhone).length < 9) return 'Nomor HP pemilik tidak valid.';
    if (!RegExp(r'^\d{6}$').hasMatch(ownerPin.trim())) return 'PIN harus 6 digit angka.';
    shop
      ..name = name.trim()
      ..address = address.trim()
      ..phone = phone.trim()
      ..bank = bank.trim()
      ..rek = rek.trim()
      ..an = an.trim()
      ..wk = wk
      ..sat = sat
      ..sun = sun
      ..breakStart = breakStart
      ..breakEnd = breakEnd
      ..ownerPhone = ownerPhone.trim()
      ..ownerPin = ownerPin.trim();
    toast('Pengaturan tersimpan');
    goTo(Screen.oServices);
    return null;
  }
}