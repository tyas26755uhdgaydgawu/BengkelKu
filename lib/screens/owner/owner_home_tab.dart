import 'package:flutter/material.dart';
import '../../state/bengkel_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';

class OwnerHomeTab extends StatelessWidget {
  final VoidCallback onNavigateToBookings;

  const OwnerHomeTab({super.key, required this.onNavigateToBookings});

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final pendingCount = state.pendingOwnerBookings.length;
    final todayBookings = state.todayBookings;
    final tomorrowBookings = state.tomorrowBookings;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.formatDate(DateTime.now()),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.workshopName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    state.toggleWorkshopOpen();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.isWorkshopOpen
                            ? 'Bengkel dibuka untuk booking'
                            : 'Bengkel ditutup sementara'),
                        backgroundColor: AppColors.surfaceSecondary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: state.isWorkshopOpen
                      ? StatusChip.buka()
                      : StatusChip.tutup(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Workshop Status Toggle Card
            CustomCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isWorkshopOpen
                            ? 'Bengkel buka'
                            : 'Bengkel tutup',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.isWorkshopOpen
                            ? 'Geser untuk menutup booking'
                            : 'Geser untuk membuka booking',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: state.isWorkshopOpen,
                    activeThumbColor: AppColors.accentRose,
                    activeTrackColor: AppColors.surfaceSecondary,
                    inactiveThumbColor: AppColors.textMuted,
                    inactiveTrackColor: AppColors.surfacePlate,
                    onChanged: (val) {
                      state.toggleWorkshopOpen();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Alert for pending bookings
            if (pendingCount > 0) ...[
              CustomCard(
                bg: AppColors.chipAmberBg.withValues(alpha: 0.4),
                border: Border.all(color: AppColors.chipAmberFg.withValues(alpha: 0.5)),
                onTap: onNavigateToBookings,
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.chipAmberFg,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$pendingCount booking baru menunggu persetujuan',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.chipAmberFg,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.chipAmberFg,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Daily Stats 2x2 Grid
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking hari ini',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${todayBookings.length}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dikerjakan',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${state.todayInProgressCount}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selesai',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${state.todayCompletedCount}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pendapatan',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppFormatters.formatRupiah(state.todayTotalRevenue),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tomorrow reminder card
            if (tomorrowBookings.isNotEmpty)
              CustomCard(
                onTap: onNavigateToBookings,
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_note_outlined,
                      color: AppColors.accentRoseLight,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Besok ada ${tomorrowBookings.length} jadwal servis',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Ketuk untuk melihat dan menyiapkan montir.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),

            // Slot hari ini terisi / total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Slot hari ini terisi / total',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Kapasitas: ${state.activeMechanicsCount}/jam',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Slot breakdown grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: BengkelState.availableHours.length,
              itemBuilder: (context, index) {
                final hour = BengkelState.availableHours[index];
                final remaining =
                    state.getRemainingSlots(DateTime.now(), hour);
                final total = state.activeMechanicsCount;
                final filled = (total - remaining).clamp(0, total);

                final isOccupied = filled > 0;

                return Container(
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? AppColors.surfaceSecondary
                        : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isOccupied
                          ? AppColors.accentRose.withValues(alpha: 0.5)
                          : AppColors.borderCard,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hour,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$filled/$total',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOccupied
                              ? AppColors.accentRoseLight
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Montir hari ini
            const Text(
              'Montir hari ini',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            ...state.mechanics.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceSecondary,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          m.avatarInitial,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentRoseLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Montir Aktif',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip.tersedia(),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
