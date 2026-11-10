// screens_customer.dart
// Layar untuk pelanggan: tampilan depan, masuk, data motor, beranda,
// booking (layanan -> jadwal -> montir -> pembayaran), konfirmasi, riwayat, profil.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'data.dart';
import 'theme.dart';
import 'widgets.dart';

// ====================================================== 1. TAMPILAN DEPAN
class WelcomeScreen extends StatelessWidget {
  final AppState st;
  const WelcomeScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    Widget dot() => Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: p.line, shape: BoxShape.circle),
        );
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.0,
          colors: [p.w1, p.w2, p.w3],
          stops: const [0, 0.6, 1],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [p.tile1, p.tile2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: p.tileLine),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.28),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Icon(Icons.build_outlined, size: 40, color: p.primary),
                      ),
                      const SizedBox(height: 20),
                      Text('BengkelKu', style: ts(p.ink, size: 32, w: FontWeight.w700, ls: -0.8)),
                      const SizedBox(height: 6),
                      Text(
                        'Solusi servis motor praktis & tanpa antre',
                        textAlign: TextAlign.center,
                        style: ts(p.muted, size: 14),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 6,
                      decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 6),
                    dot(),
                    const SizedBox(width: 6),
                    dot(),
                  ],
                ),
                const SizedBox(height: 22),
                AppButton('Masuk Akun', onPressed: () => st.goLogin('masuk')),
                const SizedBox(height: 10),
                AppButton('Daftar Akun Baru', kind: BtnKind.outline, onPressed: () => st.goLogin('daftar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================== 2. MASUK / DAFTAR
class LoginScreen extends StatefulWidget {
  final AppState st;
  const LoginScreen(this.st, {super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  void submit() => widget.st.sendLogin(name.text, phone.text);

  @override
  Widget build(BuildContext context) {
    final st = widget.st;
    final p = pal(context);
    final daftar = st.mode == 'daftar';
    return ScreenFrame(
      maxWidth: 480,
      children: [
        ScreenTitle(daftar ? 'Daftar akun' : 'Masuk', onBack: () => st.goTo(Screen.welcome)),
        Text(
          'Cukup isi nama dan nomor HP. Data diingat di perangkat ini, jadi lain kali langsung masuk.',
          style: ts(p.muted, size: 14, h: 1.4),
        ),
        AppField(label: 'Nama', controller: name, hint: 'Budi Santoso', cap: TextCapitalization.words),
        AppField(
          label: 'Nomor HP',
          controller: phone,
          hint: '0812 3456 7890',
          keyboard: TextInputType.phone,
          onSubmitted: (_) => submit(),
        ),
        if (st.error.isNotEmpty) Text(st.error, style: ts(p.bad, size: 13, w: FontWeight.w500)),
        AppButton(daftar ? 'Daftar' : 'Masuk', onPressed: submit),
        // Tombol demo HANYA muncul saat debug (flutter run). Tidak ada di APK rilis,
        // jadi pelanggan tidak bisa mengetahui adanya akses pemilik.
        if (kDebugMode)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coba cepat (hanya mode debug)', style: ts(p.muted, size: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppButton('Pelanggan demo',
                          kind: BtnKind.soft, small: true, onPressed: () => st.demo('customer')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton('Pemilik demo',
                          kind: BtnKind.soft, small: true, onPressed: () => st.demo('owner')),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ====================================================== 2b. PIN PEMILIK (tersembunyi)
// Layar ini hanya muncul jika nomor HP yang diketik di layar Masuk sama dengan nomor pemilik.
class OwnerPinScreen extends StatefulWidget {
  final AppState st;
  const OwnerPinScreen(this.st, {super.key});

  @override
  State<OwnerPinScreen> createState() => _OwnerPinScreenState();
}

class _OwnerPinScreenState extends State<OwnerPinScreen> {
  final pin = TextEditingController();
  String err = '';

  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  void submit() {
    final e = widget.st.verifyOwnerPin(pin.text);
    if (e != null) {
      setState(() {
        err = e;
        pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenFrame(
      maxWidth: 480,
      children: [
        ScreenTitle('Verifikasi', onBack: widget.st.cancelOwnerLogin),
        Text('Masukkan PIN untuk melanjutkan.', style: ts(p.muted, size: 14)),
        AppField(
          label: 'PIN',
          controller: pin,
          hint: '••••••',
          keyboard: TextInputType.number,
          maxLength: 6,
          obscure: true,
          digitsOnly: true,
          onSubmitted: (_) => submit(),
        ),
        if (err.isNotEmpty) Text(err, style: ts(p.bad, size: 13, w: FontWeight.w500)),
        AppButton('Lanjut', onPressed: submit),
      ],
    );
  }
}

// ====================================================== 3. DATA MOTOR
class MotorScreen extends StatefulWidget {
  final AppState st;
  const MotorScreen(this.st, {super.key});

  @override
  State<MotorScreen> createState() => _MotorScreenState();
}

class _MotorScreenState extends State<MotorScreen> {
  late final TextEditingController brand;
  late final TextEditingController plate;
  late final TextEditingController year;

  @override
  void initState() {
    super.initState();
    final m = widget.st.me?.motor;
    brand = TextEditingController(text: m?.brand ?? '');
    plate = TextEditingController(text: m?.plate ?? '');
    year = TextEditingController(text: m?.year ?? '');
  }

  @override
  void dispose() {
    brand.dispose();
    plate.dispose();
    year.dispose();
    super.dispose();
  }

  void save() {
    final err = widget.st.saveMotor(brand.text, plate.text, year.text);
    if (err != null) {
      widget.st.error = err;
      widget.st.changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.st;
    final p = pal(context);
    final editing = st.me?.motor != null;
    return ScreenFrame(
      maxWidth: 480,
      children: [
        ScreenTitle('Data motor', onBack: editing ? () => st.goTo(Screen.account) : null),
        Text('Dipakai otomatis setiap kali kamu booking.', style: ts(p.muted, size: 14)),
        AppField(label: 'Merek dan tipe', controller: brand, hint: 'Honda Beat'),
        AppField(label: 'Plat nomor', controller: plate, hint: 'AB 1234 XY', uppercase: true),
        AppField(label: 'Tahun', controller: year, hint: '2020', keyboard: TextInputType.number, maxLength: 4),
        if (st.error.isNotEmpty) Text(st.error, style: ts(p.bad, size: 13, w: FontWeight.w500)),
        AppButton('Simpan dan mulai', onPressed: save),
      ],
    );
  }
}

// ====================================================== 4. BERANDA
class HomeScreen extends StatelessWidget {
  final AppState st;
  const HomeScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final me = st.me;
    final nameText = (me?.name ?? '').trim();
    final first = nameText.isEmpty ? 'kamu' : nameText.split(' ').first;

    final active = st.mine
        .where((b) => ['menunggu', 'diterima', 'dikerjakan'].contains(b.status))
        .toList()
      ..sort(cmpBooking);
    final nx = active.isEmpty ? null : active.first;
    final recent = st.mine.where((b) => b.status == 'selesai').toList()
      ..sort((a, b) => cmpBooking(b, a));

    // Kartu "Servis berikutnya" (menimpa pita atas)
    Widget nextCard;
    if (nx != null) {
      final cancelable = nx.status == 'menunggu' || nx.status == 'diterima';
      nextCard = AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servis berikutnya', style: ts(p.muted, size: 13)),
            const SizedBox(height: 4),
            Text('${rel(nx.date)} · ${tf(nx.time)}', style: ts(p.ink, size: 22, w: FontWeight.w700, ls: -0.2)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(nx.svcName, style: ts(p.ink, size: 14))),
                StatusChip(nx.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Montir ${nx.montirName}', style: ts(p.muted, size: 13)),
                Plate(nx.plate),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${methodLabel(nx.payMethod)} · ${nx.paid ? 'Lunas' : 'Belum dibayar'}',
                  style: ts(p.muted, size: 13),
                ),
                if (cancelable) LinkText('Batalkan', () => st.cancelBooking(nx.id)),
              ],
            ),
          ],
        ),
      );
    } else {
      nextCard = AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servis berikutnya', style: ts(p.muted, size: 13)),
            const SizedBox(height: 4),
            Text('Belum ada booking aktif', style: ts(p.ink, size: 16, w: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Jadwalkan servis motormu supaya tidak perlu antre.', style: ts(p.muted, size: 13)),
          ],
        ),
      );
    }

    final band = BandHeader(
      top: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selamat datang', style: ts(Colors.white.withOpacity(0.85), size: 13)),
                const SizedBox(height: 2),
                Text('Hallo, $first', style: ts(Colors.white, size: 24, w: FontWeight.w700, ls: -0.4)),
              ],
            ),
          ),
          Avatar(initial(nameText.isEmpty ? 'B' : nameText),
              bg: Colors.white.withOpacity(0.2), fg: Colors.white),
        ],
      ),
      card: nextCard,
    );

    final s = st.shop;
    return ScreenFrame(
      maxWidth: 760,
      band: band,
      children: [
        // Pengingat "besok jatah kamu ya!"
        for (final b in st.tomorrowMine())
          RemindBox(
            title: 'Hai $first, besok jatah kamu ya!',
            lines: [
              Text('${b.svcName} · ${tf(b.time)} · Montir ${b.montirName}', style: ts(p.ink, size: 13)),
              Text(
                b.payMethod == 'transfer' && !b.paid
                    ? 'Jangan lupa bawa bukti transfer.'
                    : b.payMethod == 'cash'
                        ? 'Siapkan pembayaran tunai.'
                        : '',
                style: ts(p.muted, size: 13),
              ),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft, child: Plate(b.plate)),
            ],
          ),
        if (s.closedNow) const NoteBox('Bengkel sedang tutup sementara. Booking belum bisa dibuat.'),
        AppButton(
          'Booking servis',
          icon: Icons.calendar_month_outlined,
          onPressed: s.closedNow ? null : () => st.goTo(Screen.service),
        ),
        if (recent.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Riwayat terakhir', style: ts(p.ink, size: 16, w: FontWeight.w600)),
                  LinkText('Lihat semua', () => st.goTo(Screen.history)),
                ],
              ),
              const SizedBox(height: 10),
              AutoGrid(
                minWidth: 280,
                children: [
                  for (final b in recent.take(2))
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.svcName, style: ts(p.ink, size: 14, w: FontWeight.w600)),
                              StatusChip(b.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${dlabel(b.date)} · ${rp(b.price)}', style: ts(p.muted, size: 13)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        // Info bengkel
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(s.name, style: ts(p.ink, size: 16, w: FontWeight.w600))),
                  s.closedNow ? PillChip('Tutup sementara', p.badBg, p.bad) : PillChip('Buka', p.okBg, p.ok),
                ],
              ),
              const SizedBox(height: 10),
              _infoRow(p, Icons.location_on_outlined, s.address),
              const SizedBox(height: 6),
              _infoRow(
                p,
                Icons.calendar_month_outlined,
                'Sen–Jum ${tf(s.wk.open)}–${tf(s.wk.close)} · Sab ${tf(s.sat.open)}–${tf(s.sat.close)}'
                '${s.sun != null ? ' · Min ${tf(s.sun!.open)}–${tf(s.sun!.close)}' : ' · Min tutup'}',
              ),
              const SizedBox(height: 6),
              _infoRow(p, Icons.schedule, 'Istirahat ${tf(s.breakStart)}–${tf(s.breakEnd)}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton('Telepon',
                        kind: BtnKind.soft,
                        small: true,
                        icon: Icons.phone_outlined,
                        onPressed: () => st.toast('Telepon: ${s.phone}')),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton('Peta',
                        kind: BtnKind.soft,
                        small: true,
                        icon: Icons.location_on_outlined,
                        onPressed: () => st.toast(s.address)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(Pal p, IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: p.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: ts(p.muted, size: 13, h: 1.35))),
        ],
      );
}

// ====================================================== 5. PILIH LAYANAN (langkah 1)
class ServiceScreen extends StatelessWidget {
  final AppState st;
  const ServiceScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final d = st.draft;
    return ScreenFrame(
      children: [
        ScreenTitle('Pilih layanan', onBack: () => st.goTo(Screen.home)),
        const StepsBar(1),
        AutoGrid(
          minWidth: 280,
          children: [
            for (final s in st.services)
              OptTile(
                selected: d.svc == s.id,
                radio: true,
                onTap: () => st.pickSvc(s.id),
                title: Text(s.name, style: ts(p.ink, size: 14, w: FontWeight.w600)),
                subtitle: Text('${s.dur} menit', style: ts(p.muted, size: 13)),
                trailing: Text(rp(s.price), style: ts(p.ink, size: 14, w: FontWeight.w700)),
              ),
          ],
        ),
        if (st.services.isEmpty) Text('Belum ada layanan.', style: ts(p.muted)),
        Text('Harga adalah estimasi jasa. Suku cadang dihitung terpisah jika diperlukan.',
            style: ts(p.muted, size: 13)),
        AppButton('Lanjut pilih jadwal', onPressed: d.svc == null ? null : st.toSchedule),
      ],
    );
  }
}

// ====================================================== 6. PILIH JADWAL (langkah 2)
class ScheduleScreen extends StatelessWidget {
  final AppState st;
  const ScheduleScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final d = st.draft;
    final s = st.svcOf(d.svc);
    final slots = st.slotsFor(d.date);
    final allOff = slots.isNotEmpty && slots.every((t) => t.off);
    final anyFull = slots.any((t) => t.full);
    final dt = parseD(d.date);

    return ScreenFrame(
      children: [
        ScreenTitle('Pilih jadwal', onBack: () => st.goTo(Screen.service)),
        const StepsBar(2),
        if (s != null)
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: ts(p.ink, size: 14, w: FontWeight.w600)),
                    Text('${s.dur} menit', style: ts(p.muted, size: 13)),
                  ],
                ),
                Text(rp(s.price), style: ts(p.ink, size: 14, w: FontWeight.w700)),
              ],
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal · ${bulan[dt.month - 1]} ${dt.year}', style: ts(p.muted, size: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 78,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [for (var i = 0; i < 7; i++) _dateChip(context, i)],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jam tersedia · ${st.activeN} slot per jam, sesuai jumlah montir · istirahat ${tf(st.shop.breakStart)}–${tf(st.shop.breakEnd)}',
              style: ts(p.muted, size: 13),
            ),
            const SizedBox(height: 8),
            if (slots.isEmpty)
              Text('Tidak ada jam tersedia di tanggal ini.', style: ts(p.muted))
            else
              AutoGrid(
                minWidth: 104,
                gap: 8,
                children: [for (final t in slots) _timeBtn(context, t)],
              ),
          ],
        ),
        if (allOff) ...[
          NoteBox(anyFull ? 'Semua jam di tanggal ini sudah penuh.' : 'Tidak ada jam tersisa hari ini.'),
          AppButton('Lihat tanggal terdekat yang masih kosong', kind: BtnKind.soft, onPressed: st.nextFree),
        ] else if (slots.isNotEmpty)
          Text('Jam berwarna merah sudah penuh. Pilih jam lain atau tanggal lain.',
              style: ts(p.muted, size: 13)),
        AppButton('Lanjut pilih montir', onPressed: d.time == null ? null : st.toMontir),
      ],
    );
  }

  Widget _dateChip(BuildContext context, int i) {
    final p = pal(context);
    final ds = st.isoDay(i);
    final d = addDays(st.today, i);
    final info = st.dayInfo(ds);
    final sel = ds == st.draft.date;
    final full = info == 'penuh';
    final enabled = info == 'ada';

    Color bg = p.card;
    Color fg = p.ink;
    Color sub = p.muted;
    Color border = p.line;
    if (full) {
      bg = p.badBg;
      fg = p.bad;
      sub = p.bad;
      border = Colors.transparent;
    }
    if (sel) {
      bg = p.primary;
      fg = p.onPrimary;
      sub = p.onPrimary;
      border = p.primary;
    }
    return GestureDetector(
      onTap: enabled ? () => st.pickDate(ds) : null,
      child: Opacity(
        opacity: (enabled || full) ? 1 : 0.4,
        child: Container(
          width: 56,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(hariOf(d), style: ts(sub, size: 11)),
              Text('${d.day}', style: ts(fg, size: 19, w: FontWeight.w700)),
              if (full)
                Text('Penuh', style: ts(sub, size: 9.5, w: FontWeight.w600))
              else if (info == 'tutup')
                Text('Tutup', style: ts(sub, size: 9.5, w: FontWeight.w600))
              else if (info == 'lewat')
                Text('Lewat', style: ts(sub, size: 9.5, w: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeBtn(BuildContext context, Slot t) {
    final p = pal(context);
    final sel = st.draft.time == t.time;
    Color bg = p.card;
    Color fg = p.ink;
    Color border = p.line;
    if (t.full) {
      bg = p.badBg;
      fg = p.bad;
      border = Colors.transparent;
    }
    if (sel) {
      bg = p.primary;
      fg = p.onPrimary;
      border = p.primary;
    }
    final label = t.past ? 'Lewat' : (t.left <= 0 ? 'Penuh' : 'sisa ${t.left} slot');
    return Opacity(
      opacity: (t.off && !t.full) ? 0.45 : 1,
      child: GestureDetector(
        onTap: t.off ? null : () => st.pickTime(t.time),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tf(t.time),
                style: ts(fg, size: 16, w: FontWeight.w600,
                    deco: t.full ? TextDecoration.lineThrough : null),
              ),
              Text(label, style: ts(t.full ? p.bad : (sel ? p.onPrimary : p.muted), size: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================== 7. PILIH MONTIR (langkah 3)
class MontirScreen extends StatelessWidget {
  final AppState st;
  const MontirScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final d = st.draft;
    final free = st.freeMontir(d.date, d.time ?? '').map((m) => m.id).toList();
    return ScreenFrame(
      children: [
        ScreenTitle('Pilih montir', onBack: () => st.goTo(Screen.schedule)),
        const StepsBar(3),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${dlabel(d.date)} · ${tf(d.time ?? '')}',
                  style: ts(p.ink, size: 14, w: FontWeight.w600)),
              Text('${free.length} montir kosong', style: ts(p.muted, size: 13)),
            ],
          ),
        ),
        AutoGrid(
          minWidth: 240,
          children: [
            for (final m in st.montir)
              Builder(builder: (context) {
                final ok = m.active && free.contains(m.id);
                final label = !m.active ? 'Libur' : (ok ? 'Tersedia' : 'Sudah terisi');
                return OptTile(
                  selected: d.montir == m.id,
                  enabled: ok,
                  radio: false,
                  onTap: () => st.pickMontir(m.id),
                  leading: Avatar(initial(m.name)),
                  title: Text(m.name, style: ts(p.ink, size: 14, w: FontWeight.w600)),
                  trailing: ok ? PillChip(label, p.okBg, p.ok) : PillChip(label, p.badBg, p.bad),
                );
              }),
          ],
        ),
        AppButton('Lanjut ke pembayaran', onPressed: d.montir == null ? null : st.toPay),
      ],
    );
  }
}

// ====================================================== 8. PEMBAYARAN (langkah 4)
class PayScreen extends StatelessWidget {
  final AppState st;
  const PayScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final d = st.draft;
    final s = st.svcOf(d.svc);
    final m = st.montirOf(d.montir);
    if (s == null || m == null || d.time == null) {
      return ScreenFrame(children: [
        ScreenTitle('Pembayaran', onBack: () => st.goTo(Screen.montir)),
        Text('Data booking belum lengkap. Silakan ulangi dari pilih layanan.', style: ts(p.muted)),
        AppButton('Kembali ke awal', onPressed: () => st.goTo(Screen.service)),
      ]);
    }
    final mt = st.me?.motor;
    return ScreenFrame(
      children: [
        ScreenTitle('Pembayaran', onBack: () => st.goTo(Screen.montir)),
        const StepsBar(4),
        AppCard(
          child: Column(
            children: [
              KV('Layanan', value: s.name),
              KV('Waktu', value: '${dlabel(d.date)} · ${tf(d.time!)}'),
              KV('Montir', value: m.name),
              KV('Motor', value: mt?.plate ?? '-'),
              KV('Estimasi biaya', value: rp(s.price), last: true),
            ],
          ),
        ),
        Text('Cara bayar', style: ts(p.ink, size: 16, w: FontWeight.w600)),
        AutoGrid(
          minWidth: 280,
          children: [
            OptTile(
              selected: d.pay == 'transfer',
              radio: true,
              onTap: () => st.pickPay('transfer'),
              leading: _icon(p, Icons.credit_card),
              title: Text('Transfer', style: ts(p.ink, size: 14, w: FontWeight.w600)),
              subtitle: Text('Bayar lewat rekening bengkel', style: ts(p.muted, size: 13)),
            ),
            OptTile(
              selected: d.pay == 'cash',
              radio: true,
              onTap: () => st.pickPay('cash'),
              leading: _icon(p, Icons.payments_outlined),
              title: Text('Cash', style: ts(p.ink, size: 14, w: FontWeight.w600)),
              subtitle: Text('Bayar tunai di bengkel', style: ts(p.muted, size: 13)),
            ),
          ],
        ),
        if (d.pay == 'transfer')
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${st.shop.bank} · a.n. ${st.shop.an}', style: ts(p.softInk, size: 13)),
                const SizedBox(height: 4),
                Text(st.shop.rek, style: ts(p.ink, size: 20, w: FontWeight.w700, ls: 0.8)),
                const SizedBox(height: 4),
                Text(
                  'Transfer ${rp(s.price)}, lalu tunjukkan bukti transfer saat datang. Pemilik akan menandai pembayaranmu lunas.',
                  style: ts(p.softInk, size: 13, h: 1.4),
                ),
                const SizedBox(height: 10),
                AppButton('Salin nomor rekening',
                    kind: BtnKind.ghost,
                    small: true,
                    icon: Icons.content_copy,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: st.shop.rek.replaceAll(' ', '')));
                      st.toast('Nomor rekening disalin');
                    }),
              ],
            ),
          ),
        if (d.pay == 'cash')
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(14)),
            child: Text(
              'Bayar tunai di kasir bengkel setelah servis selesai. Siapkan ${rp(s.price)} atau sesuai total akhir.',
              style: ts(p.softInk, size: 13, h: 1.4),
            ),
          ),
        AppButton('Konfirmasi booking', onPressed: d.pay == null ? null : st.book),
      ],
    );
  }

  Widget _icon(Pal p, IconData i) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(12)),
        child: Icon(i, size: 20, color: p.softInk),
      );
}

// ====================================================== 9. KONFIRMASI
class ConfirmScreen extends StatelessWidget {
  final AppState st;
  const ConfirmScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    Booking? b;
    for (final x in st.bookings) {
      if (x.id == st.lastId) b = x;
    }
    if (b == null) {
      final l = st.mine..sort(cmpBooking);
      if (l.isNotEmpty) b = l.last;
    }
    if (b == null) {
      return ScreenFrame(maxWidth: 480, children: [
        ScreenTitle('Konfirmasi', onBack: () => st.goTo(Screen.home)),
        Text('Belum ada booking.', style: ts(p.muted)),
      ]);
    }
    final bk = b;
    final diterima = bk.status == 'diterima';
    return ScreenFrame(
      maxWidth: 480,
      children: [
        Center(
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(color: p.okBg, shape: BoxShape.circle),
            child: Icon(Icons.check, size: 34, color: p.ok),
          ),
        ),
        Column(
          children: [
            Text(diterima ? 'Booking dikonfirmasi' : 'Booking terkirim',
                textAlign: TextAlign.center, style: ts(p.ink, size: 24, w: FontWeight.w700, ls: -0.4)),
            const SizedBox(height: 6),
            Text(
              diterima ? 'Bengkel sudah menerima jadwalmu.' : 'Bengkel akan memeriksa dan mengonfirmasi jadwalmu.',
              textAlign: TextAlign.center,
              style: ts(p.muted, size: 14),
            ),
          ],
        ),
        AppCard(
          child: Column(
            children: [
              KV('Kode', value: 'BK-${bk.id}'),
              KV('Layanan', value: bk.svcName),
              KV('Waktu', value: '${dlabel(bk.date)} · ${tf(bk.time)}'),
              KV('Montir', value: bk.montirName),
              KV('Motor', child: Plate(bk.plate)),
              KV('Pembayaran', value: '${methodLabel(bk.payMethod)} · ${rp(bk.price)}'),
              KV('Status', child: StatusChip(bk.status), last: true),
            ],
          ),
        ),
        if (bk.payMethod == 'transfer')
          NoteBox(
            'Transfer ke ${st.shop.bank} ${st.shop.rek} a.n. ${st.shop.an}. Tunjukkan bukti transfer saat datang.',
            soft: true,
          ),
        AppButton('Lihat riwayat', onPressed: () => st.goTo(Screen.history)),
        AppButton('Ke beranda', kind: BtnKind.ghost, onPressed: () => st.goTo(Screen.home)),
      ],
    );
  }
}

// ====================================================== 10. RIWAYAT
class HistoryScreen extends StatelessWidget {
  final AppState st;
  const HistoryScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final list = st.mine..sort((a, b) => cmpBooking(b, a));
    return ScreenFrame(
      children: [
        const ScreenTitle('Riwayat'),
        if (list.isEmpty)
          AppCard(child: Text('Belum ada riwayat servis. Mulai dari booking pertamamu.', style: ts(p.muted)))
        else
          AutoGrid(
            minWidth: 300,
            children: [
              for (final b in list)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${rel(b.date)} · ${tf(b.time)}',
                                    style: ts(p.ink, size: 20, w: FontWeight.w700, ls: -0.2)),
                                Text('${b.svcName} · ${rp(b.price)}', style: ts(p.muted, size: 13)),
                              ],
                            ),
                          ),
                          StatusChip(b.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Montir ${b.montirName} · ${methodLabel(b.payMethod)}',
                          style: ts(p.muted, size: 13)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Plate(b.plate),
                              if (b.live) ...[const SizedBox(width: 8), PayChip(b.paid)],
                            ],
                          ),
                          if (b.status == 'menunggu' || b.status == 'diterima')
                            LinkText('Batalkan', () => st.cancelBooking(b.id))
                          else
                            Text('BK-${b.id}', style: ts(p.muted, size: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ====================================================== 11. PROFIL
class AccountScreen extends StatelessWidget {
  final AppState st;
  const AccountScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final c = st.me;
    final m = c?.motor;
    return ScreenFrame(
      maxWidth: 480,
      children: [
        const ScreenTitle('Profil'),
        AppCard(
          child: Row(
            children: [
              Avatar(initial(c?.name ?? 'B'), size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c?.name ?? '', style: ts(p.ink, size: 16, w: FontWeight.w600)),
                    Text(st.user?.phone ?? '', style: ts(p.muted, size: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Motor', style: ts(p.muted, size: 13)),
              const SizedBox(height: 8),
              if (m != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Plate(m.plate), Text(m.year, style: ts(p.muted, size: 13))],
                ),
                const SizedBox(height: 8),
                Text(m.brand, style: ts(p.ink, size: 14, w: FontWeight.w600)),
              ] else
                Text('Belum diisi', style: ts(p.muted)),
            ],
          ),
        ),
        AppButton('Ubah data motor', kind: BtnKind.ghost, icon: Icons.edit_outlined, onPressed: () => st.goTo(Screen.motor)),
        AppButton('Keluar', kind: BtnKind.ghost, icon: Icons.logout, onPressed: st.logout),
      ],
    );
  }
}