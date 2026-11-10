// data.dart
// Berisi: fungsi bantu (tanggal, rupiah), model data, dan data contoh (demo).

// ---------- Fungsi bantu ----------
String pad(int n) => n.toString().padLeft(2, '0');

String iso(DateTime d) => '${d.year}-${pad(d.month)}-${pad(d.day)}';

DateTime parseD(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

DateTime todayDate() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

const List<String> hari = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
const List<String> bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

// Dart: Senin = 1 ... Minggu = 7, jadi Minggu dipetakan ke indeks 0
String hariOf(DateTime d) => hari[d.weekday % 7];

String dlabel(String s) {
  final d = parseD(s);
  return '${hariOf(d)}, ${d.day} ${bulan[d.month - 1]}';
}

String rel(String s) {
  final t = todayDate();
  if (s == iso(t)) return 'Hari ini';
  if (s == iso(addDays(t, 1))) return 'Besok';
  return dlabel(s);
}

// '09:00' -> '09.00'
String tf(String t) => t.replaceAll(':', '.');

// 75000 -> 'Rp75.000'
String rp(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp${b.toString()}';
}

// Menyamakan format nomor HP: +62812... menjadi 0812...
String digits(String s) {
  var d = s.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('62')) d = '0${d.substring(2)}';
  return d;
}

String initial(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  final w = parts.isEmpty ? '?' : parts.last;
  return w.isEmpty ? '?' : w[0].toUpperCase();
}

String methodLabel(String m) => m == 'transfer' ? 'Transfer' : 'Cash';

// ---------- Model ----------
class AppUser {
  final String role; // 'customer' atau 'owner'
  final String phone;
  AppUser(this.role, this.phone);

  Map<String, dynamic> toJson() => {'role': role, 'phone': phone};
  factory AppUser.fromJson(Map<String, dynamic> j) =>
      AppUser(j['role'] as String, j['phone'] as String);
}

class Service {
  String id;
  String name;
  int price;
  int dur; // durasi dalam menit
  Service({required this.id, required this.name, required this.price, required this.dur});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price, 'dur': dur};
  factory Service.fromJson(Map<String, dynamic> j) => Service(
        id: j['id'] as String,
        name: j['name'] as String,
        price: (j['price'] as num).toInt(),
        dur: (j['dur'] as num).toInt(),
      );
}

class Montir {
  String id;
  String name;
  bool active;
  Montir({required this.id, required this.name, this.active = true});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'active': active};
  factory Montir.fromJson(Map<String, dynamic> j) => Montir(
        id: j['id'] as String,
        name: j['name'] as String,
        active: j['active'] as bool,
      );
}

class Motor {
  String brand;
  String plate;
  String year;
  Motor({required this.brand, required this.plate, required this.year});

  Map<String, dynamic> toJson() => {'brand': brand, 'plate': plate, 'year': year};
  factory Motor.fromJson(Map<String, dynamic> j) => Motor(
        brand: j['brand'] as String,
        plate: j['plate'] as String,
        year: j['year'] as String,
      );
}

class Customer {
  String name;
  Motor? motor;
  Customer({required this.name, this.motor});

  Map<String, dynamic> toJson() => {'name': name, 'motor': motor?.toJson()};
  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        name: j['name'] as String,
        motor: j['motor'] == null ? null : Motor.fromJson(j['motor'] as Map<String, dynamic>),
      );
}

class Hours {
  String open;
  String close;
  Hours(this.open, this.close);

  Map<String, dynamic> toJson() => {'open': open, 'close': close};
  factory Hours.fromJson(Map<String, dynamic> j) =>
      Hours(j['open'] as String, j['close'] as String);
}

class Shop {
  String name, address, phone, ownerPhone, bank, rek, an;
  String ownerPin; // PIN 6 digit untuk masuk sebagai pemilik
  Hours wk; // Senin - Jumat
  Hours sat; // Sabtu
  Hours? sun; // Minggu (null = tutup)
  String breakStart, breakEnd; // jam istirahat
  bool closedNow; // tutup sementara
  bool auto; // terima booking otomatis

  Shop({
    required this.name,
    required this.address,
    required this.phone,
    required this.ownerPhone,
    required this.ownerPin,
    required this.bank,
    required this.rek,
    required this.an,
    required this.wk,
    required this.sat,
    required this.sun,
    required this.breakStart,
    required this.breakEnd,
    required this.closedNow,
    required this.auto,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'phone': phone,
        'ownerPhone': ownerPhone,
        'ownerPin': ownerPin,
        'bank': bank,
        'rek': rek,
        'an': an,
        'wk': wk.toJson(),
        'sat': sat.toJson(),
        'sun': sun?.toJson(),
        'breakStart': breakStart,
        'breakEnd': breakEnd,
        'closedNow': closedNow,
        'auto': auto,
      };

  factory Shop.fromJson(Map<String, dynamic> j) => Shop(
        name: j['name'] as String,
        address: j['address'] as String,
        phone: j['phone'] as String,
        ownerPhone: j['ownerPhone'] as String,
        ownerPin: (j['ownerPin'] as String?) ?? '123456',
        bank: j['bank'] as String,
        rek: j['rek'] as String,
        an: j['an'] as String,
        wk: Hours.fromJson(j['wk'] as Map<String, dynamic>),
        sat: Hours.fromJson(j['sat'] as Map<String, dynamic>),
        sun: j['sun'] == null ? null : Hours.fromJson(j['sun'] as Map<String, dynamic>),
        breakStart: j['breakStart'] as String,
        breakEnd: j['breakEnd'] as String,
        closedNow: j['closedNow'] as bool,
        auto: j['auto'] as bool,
      );
}

class Booking {
  int id;
  String date, time, cust, phone, veh, plate, svc, svcName, status, montir, montirName, payMethod;
  int price;
  bool paid;

  Booking({
    required this.id,
    required this.date,
    required this.time,
    required this.cust,
    required this.phone,
    required this.veh,
    required this.plate,
    required this.svc,
    required this.svcName,
    required this.price,
    required this.status,
    required this.montir,
    required this.montirName,
    required this.payMethod,
    required this.paid,
  });

  // booking yang masih "hidup" (tidak ditolak / dibatalkan)
  bool get live => status != 'ditolak' && status != 'dibatalkan';

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'cust': cust,
        'phone': phone,
        'veh': veh,
        'plate': plate,
        'svc': svc,
        'svcName': svcName,
        'price': price,
        'status': status,
        'montir': montir,
        'montirName': montirName,
        'payMethod': payMethod,
        'paid': paid,
      };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: (j['id'] as num).toInt(),
        date: j['date'] as String,
        time: j['time'] as String,
        cust: j['cust'] as String,
        phone: j['phone'] as String,
        veh: j['veh'] as String,
        plate: j['plate'] as String,
        svc: j['svc'] as String,
        svcName: j['svcName'] as String,
        price: (j['price'] as num).toInt(),
        status: j['status'] as String,
        montir: j['montir'] as String,
        montirName: j['montirName'] as String,
        payMethod: j['payMethod'] as String,
        paid: j['paid'] as bool,
      );
}

int cmpBooking(Booking a, Booking b) => (a.date + a.time).compareTo(b.date + b.time);

// ---------- Data awal (demo) ----------
List<Service> defaultServices() => [
      Service(id: 'rutin', name: 'Servis rutin', price: 75000, dur: 45),
      Service(id: 'oli', name: 'Ganti oli', price: 55000, dur: 20),
      Service(id: 'cvt', name: 'Servis CVT', price: 120000, dur: 60),
      Service(id: 'ban', name: 'Ganti ban', price: 40000, dur: 30),
      Service(id: 'tuneup', name: 'Tune up', price: 100000, dur: 60),
    ];

// Tiga montir = tiga slot per jam. Ganti namanya di menu "Atur" pada aplikasi.
List<Montir> defaultMontir() => [
      Montir(id: 'm1', name: 'Devanda'),
      Montir(id: 'm2', name: 'Yodha'),
      Montir(id: 'm3', name: 'Cakra'),
    ];

Shop defaultShop() => Shop(
      name: 'Revora Garage',
      address: 'Jl. Minggir No. 21, Sleman, Yogyakarta',
      phone: '0274 555 0123',
      ownerPhone: '081111111111',
      ownerPin: '123456',
      bank: 'BCA',
      rek: '1234 5678 90',
      an: 'Revora Garage',
      wk: Hours('08:00', '17:00'),
      sat: Hours('08:00', '15:00'),
      sun: null,
      breakStart: '12:00',
      breakEnd: '13:00',
      closedNow: false,
      auto: false,
    );

const List<String> _names = [
  'Rina W.', 'Joko S.', 'Dewi A.', 'Agus T.', 'Maya L.', 'Hendra P.', 'Lina K.', 'Fajar N.'
];
const List<List<String>> _motor = [
  ['Beat', 'AB 4410 FA'],
  ['Scoopy', 'AB 1288 GH'],
  ['Vario 125', 'AB 7301 JK'],
  ['Mio', 'AB 5522 LM'],
  ['NMAX', 'AB 3099 QP'],
];

List<Booking> seedBookings(DateTime today, String demoPhone) {
  final svcs = defaultServices();
  final ms = defaultMontir();
  final list = <Booking>[];
  var id = 2000;

  void mk(int d, String time, String cust, String veh, String plate, String svcId,
      String status, int mi, String method, bool paid,
      [String phone = '']) {
    final s = svcs.firstWhere((x) => x.id == svcId);
    final m = ms[mi - 1];
    list.add(Booking(
      id: id++,
      date: iso(addDays(today, d)),
      time: time,
      cust: cust,
      phone: phone,
      veh: veh,
      plate: plate,
      svc: s.id,
      svcName: s.name,
      price: s.price,
      status: status,
      montir: m.id,
      montirName: m.name,
      payMethod: method,
      paid: paid,
    ));
  }

  // Booking hari ini
  mk(0, '08:00', 'Andi P.', 'Aerox', 'AB 9012 QR', 'tuneup', 'dikerjakan', 1, 'cash', false);
  mk(0, '08:00', 'Dedi K.', 'Supra X', 'AB 6677 TD', 'oli', 'selesai', 2, 'cash', true);
  mk(0, '10:00', 'Siti R.', 'Scoopy', 'AB 5678 ZZ', 'oli', 'diterima', 3, 'transfer', false);
  mk(0, '13:00', 'Rudi H.', 'NMAX', 'AB 2210 KL', 'cvt', 'menunggu', 1, 'cash', false);

  // Riwayat 4 minggu terakhir (supaya laporan ada isinya)
  for (var d = 1; d <= 27; d++) {
    if (addDays(today, -d).weekday == 7) continue; // Minggu libur
    final c = (d * 5) % 3 + 1;
    for (var k = 0; k < c; k++) {
      final v = _motor[(d + k) % _motor.length];
      final cancel = d % 9 == 0 && k == 0;
      var hour = 8 + ((d * 3 + k * 5) % 8);
      if (hour == 12) hour = 16; // jam istirahat
      mk(
        -d,
        '${pad(hour)}:00',
        _names[(d + k * 3) % _names.length],
        v[0],
        v[1],
        svcs[((d + k) * 7) % 5].id,
        cancel ? 'dibatalkan' : 'selesai',
        (d + k) % 3 + 1,
        (d + k) % 2 == 1 ? 'cash' : 'transfer',
        !cancel,
      );
    }
  }

  // Data milik pelanggan demo (Budi): jadwal besok + riwayat
  mk(1, '09:00', 'Budi Santoso', 'Honda Beat', 'AB 1234 XY', 'rutin', 'diterima', 1, 'transfer', false, demoPhone);
  mk(-21, '09:00', 'Budi Santoso', 'Honda Beat', 'AB 1234 XY', 'oli', 'selesai', 2, 'transfer', true, demoPhone);
  mk(-45, '10:00', 'Budi Santoso', 'Honda Beat', 'AB 1234 XY', 'rutin', 'selesai', 1, 'cash', true, demoPhone);
  return list;
}