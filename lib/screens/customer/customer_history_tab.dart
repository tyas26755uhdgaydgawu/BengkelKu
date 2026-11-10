import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/bengkel_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';

class CustomerHistoryTab extends StatelessWidget {
  const CustomerHistoryTab({super.key});

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
          'Apakah kamu yakin ingin membatalkan booking ${booking.service.name} (${booking.code}) pada ${booking.timeSlot}?',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kembali', style: TextStyle(color: AppColors.textMuted)),
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
    final history = state.customerHistory;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 14),
            child: Text(
              'Riwayat',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada riwayat booking',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final isUpcoming = item.status == BookingStatus.diterima ||
                          item.status == BookingStatus.menunggu ||
                          item.status == BookingStatus.dikerjakan;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${AppFormatters.formatDate(item.date)} · ${item.timeSlot}',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.service.name} · ${AppFormatters.formatRupiah(item.service.price)}',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusChip(item.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Montir ${item.mechanic.name} · ${item.paymentMethod == PaymentMethod.transfer ? 'Transfer' : 'Cash'}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        PlateBadge(
                                            plate: item.motorcycle.plateNumber),
                                        if (item.paymentStatus ==
                                            PaymentStatus.lunas)
                                          StatusChip.lunas()
                                        else
                                          StatusChip.belumDibayar(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isUpcoming)
                                    GestureDetector(
                                      onTap: () =>
                                          _showCancelDialog(context, item),
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
                                    )
                                  else
                                    Text(
                                      item.code,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    switch (status) {
      case BookingStatus.menunggu:
        return StatusChip.menunggu();
      case BookingStatus.diterima:
        return StatusChip.diterima();
      case BookingStatus.dikerjakan:
        return StatusChip.dikerjakan();
      case BookingStatus.selesai:
        return StatusChip.selesai();
      case BookingStatus.ditolak:
        return StatusChip.ditolak();
      case BookingStatus.dibatalkan:
        return const StatusChip(
          label: 'Dibatalkan',
          bg: AppColors.surfaceSecondary,
          fg: AppColors.textMuted,
        );
    }
  }
}
