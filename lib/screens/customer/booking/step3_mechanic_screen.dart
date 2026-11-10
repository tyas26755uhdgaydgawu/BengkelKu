import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../state/bengkel_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_widgets.dart';
import 'step4_payment_screen.dart';

class Step3MechanicScreen extends StatefulWidget {
  const Step3MechanicScreen({super.key});

  @override
  State<Step3MechanicScreen> createState() => _Step3MechanicScreenState();
}

class _Step3MechanicScreenState extends State<Step3MechanicScreen> {
  Mechanic? _selectedMechanic;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = BengkelScope.of(context);
    final date = state.draftDate;
    final hour = state.draftTimeSlot;

    if (_selectedMechanic == null && date != null && hour != null) {
      // Find first available mechanic
      for (var m in state.mechanics) {
        if (m.isActive && !state.isMechanicBusy(m, date, hour)) {
          _selectedMechanic = m;
          break;
        }
      }
    }
  }

  void _next() {
    if (_selectedMechanic == null) return;
    final state = BengkelScope.of(context);
    state.draftMechanic = _selectedMechanic;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Step4PaymentScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final date = state.draftDate ?? DateTime.now();
    final hour = state.draftTimeSlot ?? '09.00';
    final mechanics = state.mechanics;

    int availableCount = 0;
    for (var m in mechanics) {
      if (m.isActive && !state.isMechanicBusy(m, date, hour)) {
        availableCount++;
      }
    }

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
                      'Pilih montir',
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
                  currentStep: 3,
                  totalSteps: 4,
                  stepName: 'Montir',
                ),
                const SizedBox(height: 14),
                // Time summary
                CustomCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppFormatters.formatDate(date)} · $hour',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$availableCount montir kosong',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: mechanics.length,
                    itemBuilder: (context, index) {
                      final item = mechanics[index];
                      final isBusy = state.isMechanicBusy(item, date, hour);
                      final isSelected = _selectedMechanic?.id == item.id && !isBusy;

                      return Opacity(
                        opacity: isBusy ? 0.45 : 1.0,
                        child: Padding(
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
                            onTap: isBusy
                                ? null
                                : () {
                                    setState(() {
                                      _selectedMechanic = item;
                                    });
                                  },
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surfaceSecondary,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.avatarInitial,
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
                                    item.name,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isBusy)
                                  StatusChip.penuh()
                                else
                                  StatusChip.tersedia(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                GradientButton(
                  label: 'Lanjut ke pembayaran',
                  onPressed: _selectedMechanic != null ? _next : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
