import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../state/bengkel_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_widgets.dart';
import '../customer_main_nav.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);

    return AppMobileFrame(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // Checkmark circle
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.chipPurpleBg,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 36,
                            color: AppColors.chipPurpleFg,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Booking terkirim!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Bengkel akan memeriksa dan mengonfirmasi jadwalmu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Detail Card
                      CustomCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Column(
                          children: [
                            _buildRow('Kode', booking.code),
                            const Divider(color: AppColors.borderCard, height: 16),
                            _buildRow('Layanan', booking.service.name),
                            const Divider(color: AppColors.borderCard, height: 16),
                            _buildRow(
                              'Waktu',
                              '${AppFormatters.formatDate(booking.date)} · ${booking.timeSlot}',
                            ),
                            const Divider(color: AppColors.borderCard, height: 16),
                            _buildRow('Montir', booking.mechanic.name),
                            const Divider(color: AppColors.borderCard, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Motor',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                PlateBadge(plate: booking.motorcycle.plateNumber),
                              ],
                            ),
                            const Divider(color: AppColors.borderCard, height: 16),
                            _buildRow(
                              'Pembayaran',
                              '${booking.paymentMethod == PaymentMethod.transfer ? 'Transfer' : 'Cash'} · ${AppFormatters.formatRupiah(booking.service.price)}',
                            ),
                            const Divider(color: AppColors.borderCard, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                StatusChip.menunggu(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Instruction banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentRose.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              booking.paymentMethod == PaymentMethod.transfer
                                  ? Icons.credit_card_rounded
                                  : Icons.payments_outlined,
                              color: AppColors.accentRoseLight,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                booking.paymentMethod == PaymentMethod.transfer
                                    ? 'Transfer ke BCA ${state.bcaAccountNumber} a.n. ${state.bcaAccountName}. Tunjukkan bukti transfer saat datang.'
                                    : 'Siapkan pembayaran tunai ${AppFormatters.formatRupiah(booking.service.price)} saat datang ke bengkel.',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.accentRoseLight,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Fixed bottom buttons
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                decoration: const BoxDecoration(
                  color: AppColors.bgPrimary,
                  border: Border(
                    top: BorderSide(color: AppColors.borderCard, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    GradientButton(
                      label: 'Lihat riwayat',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerMainNav(initialIndex: 1),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    GradientButton(
                      label: 'Ke beranda',
                      isOutline: true,
                      customBg: AppColors.bgSurface,
                      customFg: AppColors.textPrimary,
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerMainNav(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
