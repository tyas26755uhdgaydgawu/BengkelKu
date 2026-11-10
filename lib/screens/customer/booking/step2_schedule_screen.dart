import 'package:flutter/material.dart';
import '../../../state/bengkel_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_widgets.dart';
import 'step3_mechanic_screen.dart';

class Step2ScheduleScreen extends StatefulWidget {
  const Step2ScheduleScreen({super.key});

  @override
  State<Step2ScheduleScreen> createState() => _Step2ScheduleScreenState();
}

class _Step2ScheduleScreenState extends State<Step2ScheduleScreen> {
  DateTime? _selectedDate;
  String? _selectedHour;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = BengkelScope.of(context);
    final now = DateTime.now();
    _selectedDate ??= state.draftDate ??
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    _selectedHour ??= state.draftTimeSlot ?? '09.00';
  }

  void _next() {
    if (_selectedDate == null || _selectedHour == null) return;
    final state = BengkelScope.of(context);
    state.draftDate = _selectedDate;
    state.draftTimeSlot = _selectedHour;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Step3MechanicScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = BengkelScope.of(context);
    final service = state.draftService;
    final now = DateTime.now();
    final baseDate = DateTime(now.year, now.month, now.day);

    // Generate 7 days
    final daysList = List.generate(7, (i) => baseDate.add(Duration(days: i + 1)));

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
                      'Pilih jadwal',
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
                  currentStep: 2,
                  totalSteps: 4,
                  stepName: 'Jadwal',
                ),
                const SizedBox(height: 14),
                // Service summary chip
                if (service != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderCard),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${service.name} · ${service.durationMinutes} menit',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          AppFormatters.formatRupiah(service.price),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentRoseLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Tanggal',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                // Horizontal date picker
                SizedBox(
                  height: 68,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: daysList.length,
                    itemBuilder: (context, index) {
                      final d = daysList[index];
                      final isSunday = d.weekday == DateTime.sunday;
                      final isSelected = _selectedDate != null &&
                          _selectedDate!.year == d.year &&
                          _selectedDate!.month == d.month &&
                          _selectedDate!.day == d.day;

                      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                      final dayStr = days[d.weekday - 1];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: isSunday
                              ? null
                              : () {
                                  setState(() {
                                    _selectedDate = d;
                                  });
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentRose
                                  : (isSunday
                                      ? AppColors.surfacePlate
                                      : AppColors.bgSurface),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentRose
                                    : AppColors.borderCard,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayStr,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.textDark
                                        : (isSunday
                                            ? AppColors.chipRedFg
                                            : AppColors.textMuted),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isSunday ? 'Tutup' : '${d.day}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: isSunday ? 11 : 16,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.textDark
                                        : (isSunday
                                            ? AppColors.chipRedFg
                                            : AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Jam tersedia · 3 slot per jam · istirahat 12.00–13.00',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                // Time slots grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: BengkelState.availableHours.length,
                    itemBuilder: (context, index) {
                      final hour = BengkelState.availableHours[index];
                      final remainingSlots = _selectedDate == null
                          ? 3
                          : state.getRemainingSlots(_selectedDate!, hour);
                      final isFull = remainingSlots <= 0;
                      final isSelected = _selectedHour == hour && !isFull;

                      return InkWell(
                        onTap: isFull
                            ? null
                            : () {
                                setState(() {
                                  _selectedHour = hour;
                                });
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentRose
                                : (isFull
                                    ? AppColors.chipRedBg.withValues(alpha: 0.4)
                                    : AppColors.bgSurface),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentRose
                                  : (isFull
                                      ? AppColors.chipRedBg
                                      : AppColors.borderCard),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                hour,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.textDark
                                      : (isFull
                                          ? AppColors.chipRedFg
                                          : AppColors.textPrimary),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFull ? 'Penuh' : 'sisa $remainingSlots slot',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: isSelected
                                      ? AppColors.textDark
                                      : (isFull
                                          ? AppColors.chipRedFg
                                          : AppColors.textMuted),
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
                  'Jam berwarna merah sudah penuh. Pilih jam lain atau tanggal lain.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                GradientButton(
                  label: 'Lanjut pilih montir',
                  onPressed: (_selectedDate != null && _selectedHour != null)
                      ? _next
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
