import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlateBadge extends StatelessWidget {
  final String plate;
  const PlateBadge({super.key, required this.plate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfacePlate,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderCard, width: 0.8),
      ),
      child: Text(
        plate,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const StatusChip({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  factory StatusChip.diterima() => const StatusChip(
        label: 'Diterima',
        bg: AppColors.chipBlueBg,
        fg: AppColors.chipBlueFg,
      );

  factory StatusChip.menunggu() => const StatusChip(
        label: 'Menunggu',
        bg: AppColors.chipAmberBg,
        fg: AppColors.chipAmberFg,
      );

  factory StatusChip.selesai() => const StatusChip(
        label: 'Selesai',
        bg: AppColors.chipPurpleBg,
        fg: AppColors.chipPurpleFg,
      );

  factory StatusChip.dikerjakan() => const StatusChip(
        label: 'Dikerjakan',
        bg: AppColors.chipBlueBg,
        fg: AppColors.chipBlueFg,
      );

  factory StatusChip.ditolak() => const StatusChip(
        label: 'Ditolak',
        bg: AppColors.chipRedBg,
        fg: AppColors.chipRedFg,
      );

  factory StatusChip.buka() => const StatusChip(
        label: 'Buka',
        bg: AppColors.chipPurpleBg,
        fg: AppColors.chipPurpleFg,
      );

  factory StatusChip.tutup() => const StatusChip(
        label: 'Tutup',
        bg: AppColors.chipRedBg,
        fg: AppColors.chipRedFg,
      );

  factory StatusChip.tersedia() => const StatusChip(
        label: 'Tersedia',
        bg: AppColors.chipPurpleBg,
        fg: AppColors.chipPurpleFg,
      );

  factory StatusChip.penuh() => const StatusChip(
        label: 'Sudah terisi di jam ini',
        bg: AppColors.chipRedBg,
        fg: AppColors.chipRedFg,
      );

  factory StatusChip.lunas() => const StatusChip(
        label: 'Lunas',
        bg: AppColors.chipPurpleBg,
        fg: AppColors.chipPurpleFg,
      );

  factory StatusChip.belumDibayar() => const StatusChip(
        label: 'Belum dibayar',
        bg: AppColors.chipAmberBg,
        fg: AppColors.chipAmberFg,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isOutline;
  final bool isSecondaryOutline;
  final double height;
  final double? width;
  final Color? customBg;
  final Color? customFg;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutline = false,
    this.isSecondaryOutline = false,
    this.height = 48,
    this.width,
    this.customBg,
    this.customFg,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    if (isOutline) {
      return SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: customFg ?? AppColors.accentRoseLight,
            backgroundColor: customBg ?? Colors.transparent,
            side: const BorderSide(color: AppColors.borderCard, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: height <= 40 ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  color: customFg ?? AppColors.accentRoseLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isSecondaryOutline) {
      return SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: customFg ?? AppColors.accentRoseLight,
            backgroundColor: customBg ?? AppColors.surfaceSecondary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: height <= 40 ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: customFg ?? AppColors.accentRoseLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: isEnabled ? AppColors.primaryGradient : null,
        color: isEnabled ? null : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.accentRose.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isEnabled ? AppColors.textDark : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? bg;
  final Border? border;
  final double radius;
  final bool hasShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.bg,
    this.border,
    this.radius = 16,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg ?? AppColors.bgSurface,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: AppColors.borderCard, width: 1),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class BackIconButton extends StatelessWidget {
  final VoidCallback onTap;
  const BackIconButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepName;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    required this.stepName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompletedOrActive = index < currentStep;
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
                decoration: BoxDecoration(
                  color: isCompletedOrActive
                      ? AppColors.accentRose
                      : AppColors.borderCard,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Langkah $currentStep dari $totalSteps · $stepName',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class AppMobileFrame extends StatelessWidget {
  final Widget child;
  const AppMobileFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          // On desktop / wide browser, wrap in an elegant iPhone-style preview frame
          return ColoredBox(
            color: const Color(0xFF0C080A),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 420,
                  maxHeight: constraints.maxHeight,
                ),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: const Color(0xFF2C2227),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 40,
                        spreadRadius: 4,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          );
        }

        // On mobile, fill full screen natively
        return child;
      },
    );
  }
}
