import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/bengkel_state.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_widgets.dart';

class MotorScreen extends StatefulWidget {
  final bool isEdit;
  const MotorScreen({super.key, this.isEdit = false});

  @override
  State<MotorScreen> createState() => _MotorScreenState();
}

class _MotorScreenState extends State<MotorScreen> {
  late final TextEditingController _brandController;
  late final TextEditingController _plateController;
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController();
    _plateController = TextEditingController();
    _yearController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motor = BengkelScope.of(context).currentUser?.motorcycle;
    if (_brandController.text.isEmpty && motor != null) {
      _brandController.text = motor.brandAndModel;
      _plateController.text = motor.plateNumber;
      _yearController.text = motor.year;
    } else if (_brandController.text.isEmpty) {
      _brandController.text = 'Honda Beat';
      _plateController.text = 'AB 1234 XY';
      _yearController.text = '2020';
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _save() {
    final state = BengkelScope.of(context);
    final brand = _brandController.text.trim();
    final plate = _plateController.text.trim().toUpperCase();
    final year = _yearController.text.trim();

    state.updateMotorcycle(
      Motorcycle(
        brandAndModel: brand.isEmpty ? 'Honda Beat' : brand,
        plateNumber: plate.isEmpty ? 'AB 1234 XY' : plate,
        year: year.isEmpty ? '2020' : year,
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data motor berhasil disimpan'),
        backgroundColor: AppColors.surfaceSecondary,
        duration: Duration(seconds: 2),
      ),
    );
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
                    'Data motor',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Dipakai otomatis setiap kali kamu booking.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              // Merek dan tipe
              const Text(
                'Merek dan tipe',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              _buildInput(_brandController, 'Contoh: Honda Beat, Yamaha NMAX'),
              const SizedBox(height: 16),
              // Plat nomor
              const Text(
                'Plat nomor',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              _buildInput(_plateController, 'AB 1234 XY', isCaps: true),
              const SizedBox(height: 16),
              // Tahun
              const Text(
                'Tahun',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              _buildInput(_yearController, '2020', isNumber: true),
              const Spacer(),
              GradientButton(
                label: widget.isEdit ? 'Simpan perubahan' : 'Simpan dan mulai',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    bool isCaps = false,
    bool isNumber = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderCard),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        textCapitalization:
            isCaps ? TextCapitalization.characters : TextCapitalization.words,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
