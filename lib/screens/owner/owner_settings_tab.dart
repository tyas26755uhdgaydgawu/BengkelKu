import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/bengkel_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../customer/customer_main_nav.dart';

class OwnerSettingsTab extends StatefulWidget {
  const OwnerSettingsTab({super.key});

  @override
  State<OwnerSettingsTab> createState() => _OwnerSettingsTabState();
}

class _OwnerSettingsTabState extends State<OwnerSettingsTab> {

  void _showAddServiceDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: const Text(
          'Tambah Layanan Baru',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Nama Layanan', nameCtrl, 'Contoh: Bersih Karburator'),
              const SizedBox(height: 10),
              _buildField('Harga (Rp)', priceCtrl, '50000', isNumber: true),
              const SizedBox(height: 10),
              _buildField('Durasi (menit)', durationCtrl, '30', isNumber: true),
              const SizedBox(height: 10),
              _buildField('Deskripsi (opsional)', descCtrl, 'Keterangan'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = int.tryParse(priceCtrl.text.trim()) ?? 50000;
              final dur = int.tryParse(durationCtrl.text.trim()) ?? 30;
              if (name.isNotEmpty) {
                BengkelScope.of(context).addService(
                  name: name,
                  price: price,
                  durationMinutes: dur,
                  description: descCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Layanan "$name" ditambahkan'),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRose,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, ServiceItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: '${item.price}');
    final durationCtrl = TextEditingController(text: '${item.durationMinutes}');
    final descCtrl = TextEditingController(text: item.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderCard),
        ),
        title: Text(
          'Ubah ${item.name}',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Nama Layanan', nameCtrl, ''),
              const SizedBox(height: 10),
              _buildField('Harga (Rp)', priceCtrl, '', isNumber: true),
              const SizedBox(height: 10),
              _buildField('Durasi (menit)', durationCtrl, '', isNumber: true),
              const SizedBox(height: 10),
              _buildField('Deskripsi', descCtrl, ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = int.tryParse(priceCtrl.text.trim()) ?? item.price;
              final dur =
                  int.tryParse(durationCtrl.text.trim()) ?? item.durationMinutes;
              if (name.isNotEmpty) {
                BengkelScope.of(context).updateService(
                  id: item.id,
                  name: name,
                  price: price,
                  durationMinutes: dur,
                  description: descCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Layanan "$name" diperbarui'),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRose,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showWorkshopInfoModal(BuildContext context, BengkelState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Bengkel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _buildInfoRow('Nama Bengkel', state.workshopName),
            const SizedBox(height: 8),
            _buildInfoRow('Alamat', state.workshopAddress),
            const SizedBox(height: 8),
            _buildInfoRow('Jam Buka', state.workshopHours),
            const SizedBox(height: 8),
            _buildInfoRow(
                'Rekening', 'BCA ${state.bcaAccountNumber} (${state.bcaAccountName})'),
            const SizedBox(height: 8),
            _buildInfoRow('No Telepon', state.workshopPhone),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Tutup',
              isSecondaryOutline: true,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildField(
      String label, TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderCard),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final services = state.services;
    final mechanics = state.mechanics;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atur bengkel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Layanan dan harga',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            // Services List
            ...services.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${AppFormatters.formatRupiah(item.price)} · ${item.durationMinutes} menit',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => _showEditServiceDialog(context, item),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            GradientButton(
              label: 'Tambah layanan',
              height: 42,
              isOutline: true,
              customFg: AppColors.textPrimary,
              icon: const Icon(Icons.add_rounded,
                  size: 18, color: AppColors.textPrimary),
              onPressed: () => _showAddServiceDialog(context),
            ),
            const SizedBox(height: 24),
            // Montir section
            const Text(
              'Montir',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Setiap montir aktif = 1 slot per jam. Saat ini ${state.activeMechanicsCount} slot per jam.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            ...mechanics.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceSecondary,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          m.avatarInitial,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentRoseLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          m.name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Switch(
                        value: m.isActive,
                        activeThumbColor: AppColors.accentRose,
                        activeTrackColor: AppColors.surfaceSecondary,
                        inactiveThumbColor: AppColors.textMuted,
                        inactiveTrackColor: AppColors.surfacePlate,
                        onChanged: (val) {
                          state.toggleMechanicActive(m.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),
            GradientButton(
              label: 'Jam buka, pembayaran, dan info bengkel',
              height: 44,
              isSecondaryOutline: true,
              icon: const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.accentRoseLight),
              onPressed: () => _showWorkshopInfoModal(context, state),
            ),
            const SizedBox(height: 12),
            GradientButton(
              label: 'Beralih ke Mode Pelanggan',
              height: 44,
              isOutline: true,
              customFg: AppColors.accentRoseLight,
              icon: const Icon(Icons.person_pin_outlined,
                  size: 18, color: AppColors.accentRoseLight),
              onPressed: () {
                state.switchRole(UserRole.customer);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerMainNav(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
