// screens_owner.dart
// Layar untuk pemilik bengkel: dashboard, daftar booking, atur (layanan + montir),
// pengaturan (jam buka, istirahat, rekening), dan laporan.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_state.dart';
import 'data.dart';
import 'theme.dart';
import 'widgets.dart';

// ====================================================== DASHBOARD
class OwnerHomeScreen extends StatelessWidget {
  final AppState st;
  const OwnerHomeScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final t = st.todayBookings;
    final done = t.where((b) => b.status == 'selesai').toList();
    final working = t.where((b) => b.status == 'dikerjakan').length;
    final revenue = done.fold<int>(0, (a, b) => a + b.price);
    final pend = st.pendingCount;
    final next = t.where((b) => b.status == 'menunggu' || b.status == 'diterima').toList()
      ..sort(cmpBooking);
    final tomorrowN = st.tomorrowAll().length;

    final band = BandHeader(
      top: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dlabel(st.todayIso), style: ts(Colors.white.withOpacity(0.85), size: 13)),
                const SizedBox(height: 2),
                Text(st.shop.name, style: ts(Colors.white, size: 24, w: FontWeight.w700, ls: -0.4)),
              ],
            ),
          ),
          IconBtn(Icons.logout, st.logout,
              bg: Colors.white.withOpacity(0.18), fg: Colors.white, border: false),
        ],
      ),
      card: AppCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(st.shop.closedNow ? 'Tutup sementara' : 'Bengkel buka',
                      style: ts(p.ink, size: 14, w: FontWeight.w600)),
                  Text('Geser untuk menutup booking', style: ts(p.muted, size: 13)),
                ],
              ),
            ),
            AppSwitch(value: !st.shop.closedNow, onChanged: (_) => st.toggleClosed()),
          ],
        ),
      ),
    );

    return ScreenFrame(
      maxWidth: 1120,
      band: band,
      children: [
        if (pend > 0)
          NoteBox('$pend booking baru menunggu persetujuan', onTap: st.ownPending),
        if (tomorrowN > 0)
          RemindBox(
            title: 'Besok ada $tomorrowN jadwal servis',
            lines: [Text('Ketuk untuk melihat dan menyiapkan montir.', style: ts(p.muted, size: 13))],
            onTap: st.ownTomorrow,
          ),
        AutoGrid(
          minWidth: 150,
          children: [
            _stat(p, 'Booking hari ini', '${t.length}'),
            _stat(p, 'Dikerjakan', '$working'),
            _stat(p, 'Selesai', '${done.length}'),
            _stat(p, 'Pendapatan', rp(revenue), small: true),
          ],
        ),
        _slotCard(context),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Montir hari ini', style: ts(p.ink, size: 16, w: FontWeight.w600)),
            const SizedBox(height: 10),
            AutoGrid(
              minWidth: 280,
              children: [
                for (final m in st.montir)
                  AppCard(
                    child: Row(
                      children: [
                        Avatar(initial(m.name)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(m.name, style: ts(p.ink, size: 14, w: FontWeight.w600))),
                        m.active
                            ? PillChip('${t.where((b) => b.montir == m.id).length} booking', p.soft, p.softInk)
                            : PillChip('Libur', p.badBg, p.bad),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Berikutnya', style: ts(p.ink, size: 16, w: FontWeight.w600)),
            const SizedBox(height: 10),
            if (next.isEmpty)
              AppCard(child: Text('Tidak ada antrean berikutnya hari ini.', style: ts(p.muted)))
            else
              AutoGrid(
                minWidth: 300,
                children: [for (final b in next.take(3)) _nextCard(p, b)],
              ),
          ],
        ),
      ],
    );
  }

  Widget _stat(Pal p, String label, String value, {bool small = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: ts(p.muted, size: 13)),
            const SizedBox(height: 2),
            Text(value, style: ts(p.ink, size: small ? 21 : 28, w: FontWeight.w700)),
          ],
        ),
      );

  Widget _nextCard(Pal p, Booking b) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tf(b.time), style: ts(p.ink, size: 20, w: FontWeight.w700)),
                StatusChip(b.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('${b.cust} · ${b.svcName}', style: ts(p.ink, size: 14))),
                Plate(b.plate),
              ],
            ),
            const SizedBox(height: 4),
            Text('Montir ${b.montirName}', style: ts(p.muted, size: 13)),
          ],
        ),
      );

  /// Kartu "Slot hari ini": jam yang penuh berwarna merah.
  Widget _slotCard(BuildContext context) {
    final p = pal(context);
    final cfg = st.hoursFor(st.todayIso);
    if (cfg == null) {
      return AppCard(child: Text('Bengkel tutup hari ini.', style: ts(p.muted)));
    }
    final oh = int.parse(cfg.open.split(':')[0]);
    final ch = int.parse(cfg.close.split(':')[0]);
    final total = st.activeN;
    final cells = <Widget>[];
    for (var h = oh; h < ch; h++) {
      if (st.inBreak(h)) continue;
      final time = '${pad(h)}:00';
      final left = st.freeMontir(st.todayIso, time).length;
      final full = left <= 0;
      cells.add(Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: full ? p.badBg : p.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: full ? Colors.transparent : p.line),
        ),
        child: Column(
          children: [
            Text(tf(time), style: ts(full ? p.bad : p.ink, size: 13, w: FontWeight.w600)),
            Text(full ? 'Penuh' : '${total - left}/$total', style: ts(full ? p.bad : p.muted, size: 11)),
          ],
        ),
      ));
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Slot hari ini', style: ts(p.ink, size: 16, w: FontWeight.w600)),
              Text('terisi / total', style: ts(p.muted, size: 13)),
            ],
          ),
          const SizedBox(height: 10),
          AutoGrid(minWidth: 72, gap: 6, children: cells),
        ],
      ),
    );
  }
}

// ====================================================== DAFTAR BOOKING
class OwnerBookingsScreen extends StatelessWidget {
  final AppState st;
  const OwnerBookingsScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    const groups = <String, List<String>>{
      'baru': ['menunggu'],
      'proses': ['diterima', 'dikerjakan'],
      'selesai': ['selesai', 'ditolak', 'dibatalkan'],
    };
    final df = st.ownDate;
    final base = st.bookings.where((b) {
      if (df == 'semua') return b.date.compareTo(st.todayIso) >= 0;
      if (df == 'hari') return b.date == st.todayIso;
      return b.date == st.isoDay(1);
    }).toList();
    // Tab "Selesai" + "Mendatang": tampilkan 7 hari terakhir
    final src = (st.ownTab == 'selesai' && df == 'semua')
        ? st.bookings.where((b) => today7(st, b)).toList()
        : base;
    int count(String k) => base.where((b) => groups[k]!.contains(b.status)).length;
    final list = src.where((b) => groups[st.ownTab]!.contains(b.status)).toList()..sort(cmpBooking);

    return ScreenFrame(
      maxWidth: 1120,
      children: [
        const ScreenTitle('Booking'),
        SegBar(
          options: const [
            ['semua', 'Mendatang'],
            ['hari', 'Hari ini'],
            ['besok', 'Besok'],
          ],
          value: df,
          onChanged: st.setOwnDate,
        ),
        Row(
          children: [
            for (final o in const [
              ['baru', 'Baru'],
              ['proses', 'Proses'],
              ['selesai', 'Selesai'],
            ]) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => st.setOwnTab(o[0]),
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: st.ownTab == o[0] ? p.soft : p.card,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: st.ownTab == o[0] ? p.primary : p.line),
                    ),
                    child: Text(
                      '${o[1]} (${count(o[0])})',
                      style: ts(st.ownTab == o[0] ? p.softInk : p.ink, size: 13, w: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              if (o[0] != 'selesai') const SizedBox(width: 6),
            ],
          ],
        ),
        if (list.isEmpty)
          AppCard(child: Text('Tidak ada booking di kelompok ini.', style: ts(p.muted)))
        else
          AutoGrid(
            minWidth: 320,
            children: [for (final b in list) _bookingCard(p, b)],
          ),
      ],
    );
  }

  bool today7(AppState st, Booking b) {
    final diff = (st.today.difference(parseD(b.date)).inHours / 24).round();
    return diff <= 7;
  }

  Widget _bookingCard(Pal p, Booking b) {
    final acts = <Widget>[];
    void add(Widget w) {
      if (acts.isNotEmpty) acts.add(const SizedBox(width: 8));
      acts.add(Expanded(child: w));
    }

    if (b.status == 'menunggu') {
      add(AppButton('Tolak', kind: BtnKind.bad, small: true, onPressed: () => st.rejectBooking(b.id)));
      add(AppButton('Terima', small: true, onPressed: () => st.acceptBooking(b.id)));
    } else if (b.status == 'diterima') {
      add(AppButton('Mulai dikerjakan', small: true, onPressed: () => st.startBooking(b.id)));
    } else if (b.status == 'dikerjakan') {
      add(AppButton('Tandai selesai', small: true, onPressed: () => st.finishBooking(b.id)));
    }
    if (b.payMethod == 'transfer' &&
        !b.paid &&
        ['diterima', 'dikerjakan', 'selesai'].contains(b.status)) {
      add(AppButton('Tandai lunas', kind: BtnKind.soft, small: true, onPressed: () => st.markPaid(b.id)));
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tf(b.time), style: ts(p.ink, size: 20, w: FontWeight.w700)),
                  Text(rel(b.date), style: ts(p.muted, size: 13)),
                ],
              ),
              StatusChip(b.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.cust, style: ts(p.ink, size: 14, w: FontWeight.w600)),
                    Text('${b.veh} · ${b.svcName} · ${rp(b.price)}', style: ts(p.muted, size: 13)),
                  ],
                ),
              ),
              Plate(b.plate),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Montir ${b.montirName} · ${methodLabel(b.payMethod)}',
                    style: ts(p.muted, size: 13)),
              ),
              if (b.live) PayChip(b.paid),
            ],
          ),
          if (acts.isNotEmpty) ...[const SizedBox(height: 10), Row(children: acts)],
        ],
      ),
    );
  }
}

// ====================================================== ATUR (layanan + montir)
class OwnerServicesScreen extends StatelessWidget {
  final AppState st;
  const OwnerServicesScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ScreenFrame(
      maxWidth: 1120,
      children: [
        const ScreenTitle('Atur bengkel'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Layanan dan harga', style: ts(p.ink, size: 16, w: FontWeight.w600)),
            const SizedBox(height: 10),
            AutoGrid(
              minWidth: 280,
              children: [
                for (final s in st.services)
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: ts(p.ink, size: 14, w: FontWeight.w600)),
                              Text('${rp(s.price)} · ${s.dur} menit', style: ts(p.muted, size: 13)),
                            ],
                          ),
                        ),
                        IconBtn(Icons.edit_outlined, () => showServiceSheet(context, st, s)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            AppButton('Tambah layanan',
                kind: BtnKind.ghost, icon: Icons.add, onPressed: () => showServiceSheet(context, st, null)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Montir', style: ts(p.ink, size: 16, w: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('Setiap montir aktif = 1 slot per jam. Saat ini ${st.activeN} slot per jam.',
                style: ts(p.muted, size: 13)),
            const SizedBox(height: 10),
            AutoGrid(
              minWidth: 320,
              children: [
                for (final m in st.montir)
                  AppCard(
                    child: Row(
                      children: [
                        Avatar(initial(m.name)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(m.name, style: ts(p.ink, size: 14, w: FontWeight.w600))),
                        IconBtn(Icons.edit_outlined, () => showMontirSheet(context, st, m)),
                        const SizedBox(width: 10),
                        AppSwitch(value: m.active, onChanged: (_) => st.toggleMontir(m.id)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        AppButton('Jam buka, pembayaran, dan info bengkel',
            kind: BtnKind.soft, icon: Icons.settings_outlined, onPressed: () => st.goTo(Screen.oSettings)),
      ],
    );
  }
}

// ---------- Jendela edit layanan
Future<void> showServiceSheet(BuildContext context, AppState st, Service? s) {
  final p = pal(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    constraints: const BoxConstraints(maxWidth: 480),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _ServiceSheet(st: st, service: s),
    ),
  );
}

class _ServiceSheet extends StatefulWidget {
  final AppState st;
  final Service? service;
  const _ServiceSheet({required this.st, required this.service});

  @override
  State<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends State<_ServiceSheet> {
  late final TextEditingController name;
  late final TextEditingController price;
  late final TextEditingController dur;
  String err = '';

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    name = TextEditingController(text: s?.name ?? '');
    price = TextEditingController(text: s == null ? '' : '${s.price}');
    dur = TextEditingController(text: s == null ? '' : '${s.dur}');
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    dur.dispose();
    super.dispose();
  }

  void save() {
    final e = widget.st.saveService(widget.service?.id, name.text, price.text, dur.text);
    if (e != null) {
      setState(() => err = e);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final isNew = widget.service == null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isNew ? 'Tambah layanan' : 'Ubah layanan', style: ts(p.ink, size: 20, w: FontWeight.w600)),
          const SizedBox(height: 14),
          AppField(label: 'Nama layanan', controller: name, hint: 'Ganti oli'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppField(label: 'Harga (Rp)', controller: price, hint: '55000', keyboard: TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppField(label: 'Durasi (menit)', controller: dur, hint: '30', keyboard: TextInputType.number),
              ),
            ],
          ),
          if (err.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(err, style: ts(p.bad, size: 13, w: FontWeight.w500)),
          ],
          const SizedBox(height: 14),
          AppButton('Simpan layanan', onPressed: save),
          if (!isNew) ...[
            const SizedBox(height: 8),
            AppButton('Hapus layanan', kind: BtnKind.bad, icon: Icons.delete_outline, onPressed: () {
              widget.st.deleteService(widget.service!.id);
              Navigator.pop(context);
            }),
          ],
          const SizedBox(height: 8),
          AppButton('Batal', kind: BtnKind.ghost, onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// ---------- Jendela edit montir (hanya nama)
Future<void> showMontirSheet(BuildContext context, AppState st, Montir m) {
  final p = pal(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    constraints: const BoxConstraints(maxWidth: 480),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _MontirSheet(st: st, montir: m),
    ),
  );
}

class _MontirSheet extends StatefulWidget {
  final AppState st;
  final Montir montir;
  const _MontirSheet({required this.st, required this.montir});

  @override
  State<_MontirSheet> createState() => _MontirSheetState();
}

class _MontirSheetState extends State<_MontirSheet> {
  late final TextEditingController name;
  String err = '';

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.montir.name);
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void save() {
    final e = widget.st.saveMontir(widget.montir.id, name.text);
    if (e != null) {
      setState(() => err = e);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ubah montir', style: ts(p.ink, size: 20, w: FontWeight.w600)),
          const SizedBox(height: 14),
          AppField(label: 'Nama montir', controller: name, hint: 'Devanda', cap: TextCapitalization.words),
          if (err.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(err, style: ts(p.bad, size: 13, w: FontWeight.w500)),
          ],
          const SizedBox(height: 14),
          AppButton('Simpan', onPressed: save),
          const SizedBox(height: 8),
          AppButton('Batal', kind: BtnKind.ghost, onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// ====================================================== PENGATURAN
class OwnerSettingsScreen extends StatefulWidget {
  final AppState st;
  const OwnerSettingsScreen(this.st, {super.key});

  @override
  State<OwnerSettingsScreen> createState() => _OwnerSettingsScreenState();
}

class _OwnerSettingsScreenState extends State<OwnerSettingsScreen> {
  late final TextEditingController name, address, phone, bank, rek, an, ownerPhone, pin;
  late String wkO, wkC, satO, satC, sunO, sunC, brS, brE;
  late bool sunOpen;
  String err = '';

  @override
  void initState() {
    super.initState();
    final s = widget.st.shop;
    name = TextEditingController(text: s.name);
    address = TextEditingController(text: s.address);
    phone = TextEditingController(text: s.phone);
    bank = TextEditingController(text: s.bank);
    rek = TextEditingController(text: s.rek);
    an = TextEditingController(text: s.an);
    ownerPhone = TextEditingController(text: s.ownerPhone);
    pin = TextEditingController(text: s.ownerPin);
    wkO = s.wk.open;
    wkC = s.wk.close;
    satO = s.sat.open;
    satC = s.sat.close;
    sunOpen = s.sun != null;
    sunO = s.sun?.open ?? '09:00';
    sunC = s.sun?.close ?? '13:00';
    brS = s.breakStart;
    brE = s.breakEnd;
  }

  @override
  void dispose() {
    for (final c in [name, address, phone, bank, rek, an, ownerPhone, pin]) {
      c.dispose();
    }
    super.dispose();
  }

  void save() {
    final e = widget.st.saveSettings(
      name: name.text,
      address: address.text,
      phone: phone.text,
      bank: bank.text,
      rek: rek.text,
      an: an.text,
      wk: Hours(wkO, wkC),
      sat: Hours(satO, satC),
      sun: sunOpen ? Hours(sunO, sunC) : null,
      breakStart: brS,
      breakEnd: brE,
      ownerPhone: ownerPhone.text,
      ownerPin: pin.text,
    );
    if (e != null) setState(() => err = e);
  }

  Widget _hoursRow(Pal p, String label, String o, String c, ValueChanged<String> onO, ValueChanged<String> onC) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: ts(p.ink, size: 14))),
          HourPick(o, (v) => setState(() => onO(v))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('–', style: ts(p.muted)),
          ),
          HourPick(c, (v) => setState(() => onC(v))),
        ],
      ),
    );
  }

  Widget _setRow(Pal p, Widget left, Widget right, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: p.line))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: left), right]),
      );

  @override
  Widget build(BuildContext context) {
    final st = widget.st;
    final p = pal(context);
    return ScreenFrame(
      children: [
        ScreenTitle('Pengaturan', onBack: () => st.goTo(Screen.oServices)),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              _hoursRow(p, 'Senin – Jumat', wkO, wkC, (v) => wkO = v, (v) => wkC = v),
              if (sunOpen)
                _hoursRow(p, 'Minggu', sunO, sunC, (v) => sunO = v, (v) => sunC = v)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Minggu', style: ts(p.ink, size: 14)),
                      Text('Tutup', style: ts(p.muted, size: 14)),
                    ],
                  ),
                ),
              _hoursRow(p, 'Sabtu', satO, satC, (v) => satO = v, (v) => satC = v),
              _hoursRow(p, 'Jam istirahat', brS, brE, (v) => brS = v, (v) => brE = v),
              _setRow(
                p,
                Text('Buka hari Minggu', style: ts(p.ink, size: 14)),
                AppSwitch(value: sunOpen, onChanged: (v) => setState(() => sunOpen = v)),
                last: true,
              ),
            ],
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(
            children: [
              _setRow(
                p,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Slot per jam', style: ts(p.ink, size: 14)),
                    Text('Mengikuti jumlah montir aktif', style: ts(p.muted, size: 13)),
                  ],
                ),
                Text('${st.activeN}', style: ts(p.ink, size: 16, w: FontWeight.w700)),
              ),
              _setRow(p, Text('Terima booking otomatis', style: ts(p.ink, size: 14)),
                  AppSwitch(value: st.shop.auto, onChanged: (_) => st.toggleAuto())),
              _setRow(p, Text('Tutup sementara', style: ts(p.ink, size: 14)),
                  AppSwitch(value: st.shop.closedNow, onChanged: (_) => st.toggleClosed()),
                  last: true),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Rekening transfer', style: ts(p.ink, size: 16, w: FontWeight.w600)),
            const SizedBox(height: 10),
            AppField(label: 'Bank', controller: bank, hint: 'BCA'),
            const SizedBox(height: 12),
            AppField(label: 'Nomor rekening', controller: rek, hint: '1234 5678 90', keyboard: TextInputType.number),
            const SizedBox(height: 12),
            AppField(label: 'Atas nama', controller: an, hint: 'Revora Garage'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Info bengkel', style: ts(p.ink, size: 16, w: FontWeight.w600)),
            const SizedBox(height: 10),
            AppField(label: 'Nama bengkel', controller: name, hint: 'Revora Garage'),
            const SizedBox(height: 12),
            AppField(label: 'Alamat', controller: address, hint: 'Jl. Minggir No. 21, Sleman'),
            const SizedBox(height: 12),
            AppField(label: 'Telepon', controller: phone, hint: '0274 555 0123', keyboard: TextInputType.phone),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Keamanan pemilik', style: ts(p.ink, size: 16, w: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Dipakai untuk masuk sebagai pemilik. Layar masuk pemilik tidak terlihat oleh pelanggan.',
              style: ts(p.muted, size: 13, h: 1.4),
            ),
            const SizedBox(height: 10),
            AppField(label: 'Nomor HP pemilik', controller: ownerPhone, hint: '0811 1111 1111', keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            AppField(
              label: 'PIN pemilik (6 digit)',
              controller: pin,
              hint: '••••••',
              keyboard: TextInputType.number,
              maxLength: 6,
              obscure: true,
              digitsOnly: true,
            ),
          ],
        ),
        if (err.isNotEmpty) Text(err, style: ts(p.bad, size: 13, w: FontWeight.w500)),
        AppButton('Simpan', onPressed: save),
      ],
    );
  }
}

// ====================================================== LAPORAN
class OwnerReportScreen extends StatelessWidget {
  final AppState st;
  const OwnerReportScreen(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    int diff(Booking b) => (st.today.difference(parseD(b.date)).inHours / 24).round();
    final rng = st.bookings.where((b) {
      final d = diff(b);
      return d >= 0 && d < 28 && b.live;
    }).toList();

    final weeks = [0, 0, 0, 0];
    for (final b in rng) {
      weeks[3 - (diff(b) ~/ 7)]++;
    }
    final revenue = rng.where((b) => b.status == 'selesai').fold<int>(0, (a, b) => a + b.price);

    final svc = <String, int>{};
    final mt = <String, int>{};
    for (final b in rng) {
      svc[b.svcName] = (svc[b.svcName] ?? 0) + 1;
      mt[b.montirName] = (mt[b.montirName] ?? 0) + 1;
    }
    List<MapEntry<String, int>> sorted(Map<String, int> m, int take) {
      final l = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      return l.take(take).toList();
    }

    final topSvc = sorted(svc, 4);
    final topMontir = sorted(mt, 5);
    final transfer = rng.where((b) => b.payMethod == 'transfer').length;
    final cash = rng.length - transfer;
    final mx = math.max(1, weeks.reduce(math.max));

    Widget stat(String label, String value, {bool small = false}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ts(p.muted, size: 13)),
              const SizedBox(height: 2),
              Text(value, style: ts(p.ink, size: small ? 21 : 28, w: FontWeight.w700)),
            ],
          ),
        );

    Widget meterList(String title, List<MapEntry<String, int>> items) {
      final top = items.isEmpty ? 1 : items.first.value;
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ts(p.muted, size: 13)),
            const SizedBox(height: 10),
            if (items.isEmpty) Text('Belum ada data.', style: ts(p.muted)),
            for (final e in items) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: ts(p.ink, size: 14)),
                  Text('${e.value}', style: ts(p.ink, size: 14, w: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              Meter(e.value / top),
              const SizedBox(height: 10),
            ],
          ],
        ),
      );
    }

    const weekLabels = ['3 mgg lalu', '2 mgg lalu', 'Mgg lalu', 'Minggu ini'];
    final chart = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking per minggu', style: ts(p.muted, size: 13)),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${weeks[i]}', style: ts(p.ink, size: 14, w: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          height: math.max(6.0, weeks[i] / mx * 76),
                          decoration: BoxDecoration(
                            color: i == 3 ? p.primary : p.primary.withOpacity(0.38),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Text(weekLabels[i], textAlign: TextAlign.center, style: ts(p.muted, size: 11)),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return ScreenFrame(
      maxWidth: 1120,
      children: [
        const ScreenTitle('Laporan'),
        Text('28 hari terakhir', style: ts(p.muted, size: 13)),
        AutoGrid(
          minWidth: 150,
          children: [
            stat('Total booking', '${rng.length}'),
            stat('Pendapatan', rp(revenue), small: true),
            stat('Transfer', '$transfer'),
            stat('Cash', '$cash'),
          ],
        ),
        AutoGrid(
          minWidth: 320,
          children: [
            chart,
            meterList('Layanan terlaris', topSvc),
            meterList('Montir terbanyak digunakan', topMontir),
          ],
        ),
      ],
    );
  }
}