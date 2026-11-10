import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/models.dart';
import '../../../state/bengkel_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_widgets.dart';
import 'booking_confirmation_screen.dart';

class Step4PaymentScreen extends StatefulWidget {
  const Step4PaymentScreen({super.key});

  @override
  State<Step4PaymentScreen> createState() => _Step4PaymentScreenState();
}

class _Step4PaymentScreenState extends State<Step4PaymentScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.transfer;

  void _confirm() {
    final state = BengkelScope.of(context);
    state.draftPaymentMethod = _paymentMethod;
    final newBooking = state.confirmBookingDraft();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(booking: newBooking),
      ),
      (route) => route.isFirst,
    );
  }

  void _copyAccount(String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor rekening BCA disalin ke papan klip'),
        backgroundColor: AppColors.surfaceSecondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final service = state.draftService;
    final date = state.draftDate ?? DateTime.now();
    final hour = state.draftTimeSlot ?? '09.00';
    final mechanic = state.draftMechanic;
    final motor = state.currentUser?.motorcycle;

    return AppMobileFrame(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          BackIconButton(onTap: () => Navigator.pop(context)),
                          const SizedBox(width: 14),
                          const Text(
                            'Pembayaran',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const StepProgressBar(
                        currentStep: 4,
                        totalSteps: 4,
                        stepName: 'Pembayaran',
                      ),
                      const SizedBox(height: 14),
                      // Booking Summary Card
                      CustomCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Column(
                          children: [
                            _buildSummaryRow('Layanan', service?.name ?? '-'),
                            const Divider(
                                color: AppColors.borderCard, height: 16),
                            _buildSummaryRow('Waktu',
                                '${AppFormatters.formatDate(date)} · $hour'),
                            const Divider(
                                color: AppColors.borderCard, height: 16),
                            _buildSummaryRow('Montir', mechanic?.name ?? '-'),
                            const Divider(
                                color: AppColors.borderCard, height: 16),
                            _buildSummaryRow(
                                'Motor', motor?.plateNumber ?? 'AB 1234 XY'),
                            const Divider(
                                color: AppColors.borderCard, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Estimasi biaya',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  AppFormatters.formatRupiah(
                                      service?.price ?? 75000),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cara bayar',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Transfer Option
                      CustomCard(
                        bg: _paymentMethod == PaymentMethod.transfer
                            ? AppColors.surfaceSecondary
                            : AppColors.bgSurface,
                        border: Border.all(
                          color: _paymentMethod == PaymentMethod.transfer
                              ? AppColors.accentRose
                              : AppColors.borderCard,
                          width:
                              _paymentMethod == PaymentMethod.transfer ? 1.6 : 1,
                        ),
                        onTap: () {
                          setState(() {
                            _paymentMethod = PaymentMethod.transfer;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.credit_card_rounded,
                                color: AppColors.accentRoseLight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transfer',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Bayar lewat rekening bengkel',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _paymentMethod == PaymentMethod.transfer
                                    ? AppColors.accentRose
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _paymentMethod == PaymentMethod.transfer
                                      ? AppColors.accentRose
                                      : AppColors.borderCard,
                                  width: 2,
                                ),
                              ),
                              child: _paymentMethod == PaymentMethod.transfer
                                  ? const Icon(Icons.check,
                                      size: 13, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Cash Option
                      CustomCard(
                        bg: _paymentMethod == PaymentMethod.cash
                            ? AppColors.surfaceSecondary
                            : AppColors.bgSurface,
                        border: Border.all(
                          color: _paymentMethod == PaymentMethod.cash
                              ? AppColors.accentRose
                              : AppColors.borderCard,
                          width: _paymentMethod == PaymentMethod.cash ? 1.6 : 1,
                        ),
                        onTap: () {
                          setState(() {
                            _paymentMethod = PaymentMethod.cash;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.payments_outlined,
                                color: AppColors.accentRoseLight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cash',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Bayar tunai di bengkel',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _paymentMethod == PaymentMethod.cash
                                    ? AppColors.accentRose
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _paymentMethod == PaymentMethod.cash
                                      ? AppColors.accentRose
                                      : AppColors.borderCard,
                                  width: 2,
                                ),
                              ),
                              child: _paymentMethod == PaymentMethod.cash
                                  ? const Icon(Icons.check,
                                      size: 13, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // BCA transfer instructions
                      if (_paymentMethod == PaymentMethod.transfer)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.accentRose.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BCA · a.n. ${state.bcaAccountName}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.accentRoseLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.bcaAccountNumber,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Transfer ${AppFormatters.formatRupiah(service?.price ?? 75000)}, lalu tunjukkan bukti transfer saat datang. Pemilik akan menandai pembayaranmu lunas.',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GradientButton(
                                label: 'Salin nomor rekening',
                                height: 38,
                                isSecondaryOutline: true,
                                icon: const Icon(
                                  Icons.copy_rounded,
                                  size: 15,
                                  color: AppColors.accentRoseLight,
                                ),
                                onPressed: () =>
                                    _copyAccount(state.bcaAccountNumber),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Fixed bottom button
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                decoration: const BoxDecoration(
                  color: AppColors.bgPrimary,
                  border: Border(
                    top: BorderSide(color: AppColors.borderCard, width: 1),
                  ),
                ),
                child: GradientButton(
                  label: 'Konfirmasi booking',
                  onPressed: _confirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
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
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
