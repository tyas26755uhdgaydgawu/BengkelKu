import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import 'customer_history_tab.dart';
import 'customer_home_tab.dart';
import 'customer_profile_tab.dart';

class CustomerMainNav extends StatefulWidget {
  final int initialIndex;
  const CustomerMainNav({super.key, this.initialIndex = 0});

  @override
  State<CustomerMainNav> createState() => _CustomerMainNavState();
}

class _CustomerMainNavState extends State<CustomerMainNav> {
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
    return AppMobileFrame(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            CustomerHomeTab(
              onNavigateToHistory: () => _onTabSelected(1),
            ),
            const CustomerHistoryTab(),
            const CustomerProfileTab(),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
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
                  label: 'Riwayat',
                  icon: Icons.access_time_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Profil',
                  icon: Icons.person_outline_rounded,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.accentRoseLight : AppColors.textMuted,
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
        ),
      ),
    );
  }
}
