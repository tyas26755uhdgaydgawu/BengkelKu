import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/bengkel_state.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_widgets.dart';
import 'customer/customer_main_nav.dart';
import 'owner/owner_main_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController(text: 'Budi Santoso');
  final _phoneController = TextEditingController(text: '0812 3456 7890');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final state = BengkelScope.of(context);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    state.loginWithPhone(name, phone);

    if (state.currentUser?.role == UserRole.owner) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OwnerMainNav()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerMainNav()),
        (route) => false,
      );
    }
  }

  void _demoCustomer() {
    _nameController.text = 'Budi Santoso';
    _phoneController.text = '0812 3456 7890';
    _submit();
  }

  void _demoOwner() {
    _nameController.text = 'Pemilik Revora';
    _phoneController.text = '0811 1111 1111';
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackIconButton(
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Masuk',
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
              const Text(
                'Cukup isi nama dan nomor HP. Data diingat di perangkat ini, jadi lain kali langsung masuk.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              // Nama field
              const Text(
                'Nama',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderCard),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Masukkan nama',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Nomor HP field
              const Text(
                'Nomor HP',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderCard),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: '08xx xxxx xxxx',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Masuk',
                onPressed: _submit,
              ),
              const Spacer(),
              // Demo Box
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coba cepat (demo)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Pelanggan demo',
                            height: 38,
                            isSecondaryOutline: true,
                            onPressed: _demoCustomer,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GradientButton(
                            label: 'Pemilik demo',
                            height: 38,
                            isSecondaryOutline: true,
                            onPressed: _demoOwner,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Menu pemilik muncul otomatis saat nomor pemilik dipakai: 0811 1111 1111.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.textMuted,
                      ),
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
}
