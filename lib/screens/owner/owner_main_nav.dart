import 'package:flutter/material.dart';
import '../../state/bengkel_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import 'owner_bookings_tab.dart';
import 'owner_home_tab.dart';
import 'owner_reports_tab.dart';
import 'owner_settings_tab.dart';

class OwnerMainNav extends StatefulWidget {
  final int initialIndex;
  const OwnerMainNav({super.key, this.initialIndex = 0});

  @override
  State<OwnerMainNav> createState() => _OwnerMainNavState();
}

class _OwnerMainNavState extends State<OwnerMainNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final pendingCount = state.pendingOwnerBookings.length;

    return AppMobileFrame(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            OwnerHomeTab(
              onNavigateToBookings: () => _onTabSelected(1),
            ),
            const OwnerBookingsTab(),
            const OwnerSettingsTab(),
            const OwnerReportsTab(),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
          decoration: const BoxDecoration(
            color: AppColors.bgSurface,
            border: Border(
              top: BorderSide(color: AppColors.borderCard, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Beranda',
                  icon: Icons.home_rounded,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Booking',
                  icon: Icons.assignment_outlined,
                  badgeCount: pendingCount,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Atur',
                  icon: Icons.settings_outlined,
                ),
                _buildNavItem(
                  index: 3,
                  label: 'Laporan',
                  icon: Icons.bar_chart_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceSecondary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected
                        ? AppColors.accentRoseLight
                        : AppColors.textMuted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.accentRoseLight
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: 18,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.accentRose,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
