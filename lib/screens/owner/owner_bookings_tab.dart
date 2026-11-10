import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/bengkel_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';

class OwnerBookingsTab extends StatefulWidget {
  const OwnerBookingsTab({super.key});

  @override
  State<OwnerBookingsTab> createState() => _OwnerBookingsTabState();
}

class _OwnerBookingsTabState extends State<OwnerBookingsTab> {
  // Time filter: 0 = Mendatang, 1 = Hari ini, 2 = Besok
  int _timeFilter = 0;

  // Status filter: 0 = Semua/Baru, 1 = Proses, 2 = Selesai
  int _statusFilter = 0;

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final allBookings = state.bookings;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Filter by time
    var filtered = allBookings.where((b) {
      final bDate = DateTime(b.date.year, b.date.month, b.date.day);
      if (_timeFilter == 1) {
        return bDate.isAtSameMomentAs(today);
      } else if (_timeFilter == 2) {
        return bDate.isAtSameMomentAs(tomorrow);
      }
      return true; // Mendatang/Semua
    }).toList();

    // Counts for status pills
    final countBaru =
        filtered.where((b) => b.status == BookingStatus.menunggu).length;
    final countProses = filtered
        .where((b) =>
            b.status == BookingStatus.diterima ||
            b.status == BookingStatus.dikerjakan)
        .length;
    final countSelesai =
        filtered.where((b) => b.status == BookingStatus.selesai).length;

    // Filter by status
    if (_statusFilter == 0) {
      filtered = filtered
          .where((b) => b.status == BookingStatus.menunggu)
          .toList();
    } else if (_statusFilter == 1) {
      filtered = filtered
          .where((b) =>
              b.status == BookingStatus.diterima ||
              b.status == BookingStatus.dikerjakan)
          .toList();
    } else if (_statusFilter == 2) {
      filtered = filtered
          .where((b) => b.status == BookingStatus.selesai)
          .toList();
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Text(
              'Booking',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Time filter tabs (Mendatang, Hari ini, Besok)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _buildTimeTab(0, 'Mendatang'),
                const SizedBox(width: 8),
                _buildTimeTab(1, 'Hari ini'),
                const SizedBox(width: 8),
                _buildTimeTab(2, 'Besok'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Status sub-tabs (Baru, Proses, Selesai)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _buildStatusSubTab(0, 'Baru ($countBaru)'),
                const SizedBox(width: 8),
                _buildStatusSubTab(1, 'Proses ($countProses)'),
                const SizedBox(width: 8),
                _buildStatusSubTab(2, 'Selesai ($countSelesai)'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Bookings List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada booking pada filter ini',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildBookingCard(context, state, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTab(int index, String label) {
    final isSelected = _timeFilter == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _timeFilter = index;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceSecondary
                : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentRose
                  : AppColors.borderCard,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.accentRoseLight
                  : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSubTab(int index, String label) {
    final isSelected = _statusFilter == index;
    return InkWell(
      onTap: () {
        setState(() {
          _statusFilter = index;
        });
      },
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentRose : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? AppColors.accentRose : AppColors.borderCard,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textDark : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(
      BuildContext context, BengkelState state, Booking item) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final itemDate = DateTime(item.date.year, item.date.month, item.date.day);

    String relativeDate = AppFormatters.formatDate(item.date);
    if (itemDate.isAtSameMomentAs(today)) {
      relativeDate = 'Hari ini';
    } else if (itemDate.isAtSameMomentAs(tomorrow)) {
      relativeDate = 'Besok';
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.timeSlot} $relativeDate',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildStatusChip(item.status),
            ],
          ),
          const SizedBox(height: 6),
          // Customer Name & Motor
          Text(
            item.customerName,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${item.motorcycle.brandAndModel} · ${item.service.name} · ${AppFormatters.formatRupiah(item.service.price)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          // Plate & Mechanic row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PlateBadge(plate: item.motorcycle.plateNumber),
              Text(
                'Montir ${item.mechanic.name} · ${item.paymentMethod == PaymentMethod.transfer ? 'Transfer' : 'Cash'}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Payment status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              item.paymentStatus == PaymentStatus.lunas
                  ? StatusChip.lunas()
                  : StatusChip.belumDibayar(),
              if (item.paymentStatus == PaymentStatus.belumDibayar)
                InkWell(
                  onTap: () {
                    state.markAsPaid(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pembayaran ditandai Lunas'),
                        backgroundColor: AppColors.surfaceSecondary,
                      ),
                    );
                  },
                  child: const Text(
                    'Tandai Lunas',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentRoseLight,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          // Action Buttons depending on status
          if (item.status == BookingStatus.menunggu) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: 'Tolak',
                    height: 38,
                    isOutline: true,
                    customFg: AppColors.chipRedFg,
                    onPressed: () {
                      state.rejectBooking(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking ditolak'),
                          backgroundColor: AppColors.chipRedBg,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    label: 'Terima',
                    height: 38,
                    onPressed: () {
                      state.acceptBooking(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking diterima'),
                          backgroundColor: AppColors.surfaceSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else if (item.status == BookingStatus.diterima) ...[
            const SizedBox(height: 12),
            GradientButton(
              label: 'Mulai Kerjakan',
              height: 38,
              onPressed: () {
                state.startService(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Status diubah ke Dikerjakan'),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                );
              },
            ),
          ] else if (item.status == BookingStatus.dikerjakan) ...[
            const SizedBox(height: 12),
            GradientButton(
              label: 'Tandai Selesai',
              height: 38,
              onPressed: () {
                state.completeService(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Servis selesai dan tercatat di riwayat'),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                );
              },
            ),
          ],
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
