import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/bengkel_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import 'booking/step1_service_screen.dart';

class CustomerHomeTab extends StatelessWidget {
  final VoidCallback onNavigateToHistory;

  const CustomerHomeTab({super.key, required this.onNavigateToHistory});

  void _showCancelDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: const Text(
          'Batalkan Booking?',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Apakah kamu yakin ingin membatalkan booking ${booking.service.name} pada ${booking.timeSlot}?',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Kembali',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              BengkelScope.of(context).cancelBooking(booking.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking telah dibatalkan'),
                  backgroundColor: AppColors.surfaceSecondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.chipRedBg,
              foregroundColor: AppColors.chipRedFg,
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final user = state.currentUser;
    final nextBooking = state.nextCustomerBooking;
    final recentHistory = state.customerRecentHistory;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card with Gradient
          Container(
            padding: const EdgeInsets.fromLTRB(18, 56, 18, 48),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat datang',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hallo, ${user?.name.split(' ').first ?? 'Pelanggan'}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0] : 'B',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content body overlapping header
          Transform.translate(
            offset: const Offset(0, -32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Next Service Card (if active)
                  if (nextBooking != null) ...[
                    CustomCard(
                      hasShadow: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Servis berikutnya',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${AppFormatters.formatDate(nextBooking.date)} · ${nextBooking.timeSlot}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  nextBooking.service.name,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (nextBooking.status == BookingStatus.diterima)
                                StatusChip.diterima()
                              else if (nextBooking.status ==
                                  BookingStatus.menunggu)
                                StatusChip.menunggu()
                              else if (nextBooking.status ==
                                  BookingStatus.dikerjakan)
                                StatusChip.dikerjakan(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Montir ${nextBooking.mechanic.name}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              PlateBadge(
                                plate: nextBooking.motorcycle.plateNumber,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${nextBooking.paymentMethod == PaymentMethod.transfer ? 'Transfer' : 'Cash'} · ${nextBooking.paymentStatus == PaymentStatus.lunas ? 'Lunas' : 'Belum dibayar'}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    _showCancelDialog(context, nextBooking),
                                child: const Text(
                                  'Batalkan',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentRose,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.accentRose,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Booking Servis Button
                  GradientButton(
                    label: 'Booking servis',
                    icon: const Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color: AppColors.textDark,
                    ),
                    onPressed: () {
                      state.resetDraft();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Step1ServiceScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Riwayat Terakhir section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Riwayat terakhir',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onNavigateToHistory,
                        child: const Text(
                          'Lihat semua',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentRose,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accentRose,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (recentHistory.isEmpty)
                    CustomCard(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Belum ada riwayat servis',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...recentHistory.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.service.name,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  StatusChip.selesai(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppFormatters.formatDate(item.date)} · ${AppFormatters.formatRupiah(item.service.price)}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 14),

                  // Revora Garage info card
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.workshopName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            state.isWorkshopOpen
                                ? StatusChip.buka()
                                : StatusChip.tutup(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.workshopAddress,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.workshopHours,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GradientButton(
                                label: 'Telepon',
                                height: 38,
                                isSecondaryOutline: true,
                                icon: const Icon(
                                  Icons.phone_outlined,
                                  size: 15,
                                  color: AppColors.accentRoseLight,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Menghubungi: ${state.workshopPhone}'),
                                      backgroundColor:
                                          AppColors.surfaceSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GradientButton(
                                label: 'Peta',
                                height: 38,
                                isSecondaryOutline: true,
                                icon: const Icon(
                                  Icons.map_outlined,
                                  size: 15,
                                  color: AppColors.accentRoseLight,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Membuka rute ke Revora Garage...'),
                                      backgroundColor:
                                          AppColors.surfaceSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
