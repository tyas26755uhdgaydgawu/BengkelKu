import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../state/bengkel_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_widgets.dart';
import 'step2_schedule_screen.dart';

class Step1ServiceScreen extends StatefulWidget {
  const Step1ServiceScreen({super.key});

  @override
  State<Step1ServiceScreen> createState() => _Step1ServiceScreenState();
}

class _Step1ServiceScreenState extends State<Step1ServiceScreen> {
  ServiceItem? _selectedService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = BengkelScope.of(context);
    _selectedService ??= state.draftService ?? state.services.first;
  }

  void _next() {
    if (_selectedService == null) return;
    final state = BengkelScope.of(context);
    state.draftService = _selectedService;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Step2ScheduleScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final services = state.services;

    return AppMobileFrame(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackIconButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 14),
                    const Text(
                      'Pilih layanan',
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
                  currentStep: 1,
                  totalSteps: 4,
                  stepName: 'Layanan',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final item = services[index];
                      final isSelected = _selectedService?.id == item.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                          bg: isSelected
                              ? AppColors.surfaceSecondary
                              : AppColors.bgSurface,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentRose
                                : AppColors.borderCard,
                            width: isSelected ? 1.6 : 1,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedService = item;
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.accentRoseLight
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${item.durationMinutes} menit',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                AppFormatters.formatRupiah(item.price),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  'Harga adalah estimasi jasa. Suku cadang dihitung terpisah jika diperlukan.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                GradientButton(
                  label: 'Lanjut pilih jadwal',
                  onPressed: _selectedService != null ? _next : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
