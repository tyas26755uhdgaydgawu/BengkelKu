
import 'package:flutter/material.dart';
import 'app_state.dart';
import 'data.dart';
import 'theme.dart';
import 'widgets.dart';
import 'screens_customer.dart';
import 'screens_owner.dart';

class NavItem {
  final Screen screen;
  final String label;
  final IconData icon;

  const NavItem(this.screen, this.label, this.icon);
}

const List<NavItem> customerNav = [
  NavItem(Screen.home, 'Beranda', Icons.home_outlined),
  NavItem(Screen.history, 'Riwayat', Icons.history),
  NavItem(Screen.account, 'Profil', Icons.person_outline),
];

const List<NavItem> ownerNav = [
  NavItem(Screen.oHome, 'Beranda', Icons.home_outlined),
  NavItem(Screen.oBookings, 'Booking', Icons.calendar_today_outlined),
  NavItem(Screen.oServices, 'Atur', Icons.list_alt_outlined),
  NavItem(Screen.oReport, 'Laporan', Icons.bar_chart_outlined),
];

class Shell extends StatelessWidget {
  final AppState st;

  const Shell(this.st, {super.key});

  Widget _screen() {
    switch (st.screen) {
      case Screen.welcome:
        return WelcomeScreen(st);
      case Screen.login:
        return LoginScreen(st);
      case Screen.motor:
        return MotorScreen(st);
      case Screen.home:
        return HomeScreen(st);
      case Screen.service:
        return ServiceScreen(st);
      case Screen.schedule:
        return ScheduleScreen(st);
      case Screen.montir:
        return MontirScreen(st);
      case Screen.pay:
        return PayScreen(st);
      case Screen.confirm:
        return ConfirmScreen(st);
      case Screen.history:
        return HistoryScreen(st);
      case Screen.account:
        return AccountScreen(st);
      case Screen.oHome:
        return OwnerHomeScreen(st);
      case Screen.oBookings:
        return OwnerBookingsScreen(st);
      case Screen.oServices:
        return OwnerServicesScreen(st);
      case Screen.oSettings:
        return OwnerSettingsScreen(st);
      case Screen.ownerPin:
        return OwnerPinScreen(st);
      default:
        return OwnerReportScreen(st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final size = MediaQuery.of(context).size;
    final wide = size.width >= 768;
    final showTop = wide && size.height >= 520;

    final List<NavItem>? nav = st.user == null
        ? null
        : (st.user!.role == 'owner' ? ownerNav : customerNav);

    final showNav =
        nav != null && nav.any((n) => n.screen == st.screen);

    // Pengingat saat Beranda dibuka
    if (st.screen == Screen.home && st.consumeRemind()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showRemindDialog(context, st);
        }
      });
    }

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [
          ...previous,
          if (current != null) current,
        ],
      ),
      child: KeyedSubtree(
        key: ValueKey(st.screen),
        child: _screen(),
      ),
    );

    final Widget body;

    if (wide) {
      body = Row(
        children: [
          if (nav != null && showNav)
            _SideNav(st: st, items: nav),
          Expanded(child: content),
        ],
      );
    } else {
      body = Column(
        children: [
          Expanded(child: content),
          if (nav != null && showNav)
            _BottomNav(st: st, items: nav),
        ],
      );
    }

    return PopScope(
      canPop: st.isRootScreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          st.back();
        }
      },
      child: Scaffold(
        backgroundColor: p.surface,
        body: SafeArea(
          child: Column(
            children: [
              if (showTop) _TopBar(st: st),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BILAH ATAS (TABLET / LAPTOP)
// ============================================================

class _TopBar extends StatelessWidget {
  final AppState st;

  const _TopBar({required this.st});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(
          bottom: BorderSide(color: p.line),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [p.tile1, p.tile2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.tileLine),
            ),
            child: Icon(
              Icons.build_outlined,
              size: 18,
              color: p.primary,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            'BengkelKu',
            style: ts(
              p.ink,
              size: 18,
              w: FontWeight.w700,
              ls: -0.2,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 140,
            child: AppButton(
              st.dark ? 'Mode terang' : 'Mode gelap',
              kind: BtnKind.ghost,
              small: true,
              onPressed: st.toggleTheme,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 150,
            child: AppButton(
              'Ulangi dari awal',
              kind: BtnKind.ghost,
              small: true,
              onPressed: st.resetDemo,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MENU SAMPING (TABLET / LAPTOP)
// ============================================================

class _SideNav extends StatelessWidget {
  final AppState st;
  final List<NavItem> items;

  const _SideNav({
    required this.st,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final p = pal(context);

    final width =
        MediaQuery.of(context).size.width >= 1280 ? 248.0 : 224.0;

    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(
          right: BorderSide(color: p.line),
        ),
      ),
      child: Column(
        children: [
          for (final n in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _sideItem(context, p, n),
            ),
        ],
      ),
    );
  }

  Widget _sideItem(BuildContext context, Pal p, NavItem n) {
    final active = n.screen == st.screen;

    final badge =
        n.screen == Screen.oBookings ? st.pendingCount : 0;

    return GestureDetector(
      onTap: () => st.goTo(n.screen),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: active ? p.soft : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              n.icon,
              size: 20,
              color: active ? p.softInk : p.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                n.label,
                style: ts(
                  active ? p.softInk : p.muted,
                  size: 14,
                  w: FontWeight.w600,
                ),
              ),
            ),
            if (badge > 0) _badge(badge),
          ],
        ),
      ),
    );
  }
}

Widget _badge(int n) {
  return Container(
    constraints: const BoxConstraints(
      minWidth: 17,
      minHeight: 17,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 4),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFE5586E),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      '$n',
      style: ts(
        Colors.white,
        size: 10,
        w: FontWeight.w600,
      ),
    ),
  );
}

// ============================================================
// MENU BAWAH (HP)
// ============================================================

class _BottomNav extends StatelessWidget {
  final AppState st;
  final List<NavItem> items;

  const _BottomNav({
    required this.st,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final p = pal(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      decoration: BoxDecoration(
        color: p.card,
        border: Border(
          top: BorderSide(color: p.line),
        ),
      ),
      child: Row(
        children: [
          for (final n in items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => st.goTo(n.screen),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            n.icon,
                            size: 22,
                            color: n.screen == st.screen
                                ? p.primary
                                : p.muted,
                          ),
                          if (n.screen == Screen.oBookings &&
                              st.pendingCount > 0)
                            Positioned(
                              right: -10,
                              top: -6,
                              child: _badge(st.pendingCount),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        n.label,
                        style: ts(
                          n.screen == st.screen
                              ? p.primary
                              : p.muted,
                          size: 11,
                          w: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// JENDELA PENGINGAT BOOKING BESOK
// ============================================================

void showRemindDialog(BuildContext context, AppState st) {
  final p = pal(context);
  final list = st.tomorrowMine();

  if (list.isEmpty) return;

  final nameText = (st.me?.name ?? '').trim();
  final first =
      nameText.isEmpty ? 'kamu' : nameText.split(' ').first;

  final needProof = list.any(
    (b) => b.payMethod == 'transfer' && !b.paid,
  );

  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      size: 22,
                      color: p.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hai $first, besok jatah kamu ya!',
                      style: ts(
                        p.ink,
                        size: 20,
                        w: FontWeight.w600,
                        ls: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final b in list) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${b.svcName} · ${tf(b.time)}',
                        style: ts(
                          p.ink,
                          size: 14,
                          w: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Montir ${b.montirName} · ${methodLabel(b.payMethod)}',
                        style: ts(p.muted, size: 13),
                      ),
                      const SizedBox(height: 6),
                      Plate(b.plate),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Datanglah beberapa menit lebih awal.'
                '${needProof ? ' Bawa bukti transfer untuk ditunjukkan ke bengkel.' : ''}',
                style: ts(
                  p.muted,
                  size: 13,
                  h: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                'Oke, mengerti',
                onPressed: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 8),
              AppButton(
                'Lihat detail',
                kind: BtnKind.ghost,
                onPressed: () {
                  Navigator.pop(ctx);
                  st.goTo(Screen.history);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
