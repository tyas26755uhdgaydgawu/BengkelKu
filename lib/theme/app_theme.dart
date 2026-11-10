import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const Color bgPrimary = Color(0xFF150F12);
  static const Color bgSurface = Color(0xFF1F171B);
  static const Color borderCard = Color(0xFF32262B);
  static const Color surfaceSecondary = Color(0xFF35232B);
  static const Color surfacePlate = Color(0xFF0B0709);

  // Accent Rose/Plum
  static const Color accentRose = Color(0xFFE59BB2);
  static const Color accentRoseDark = Color(0xFFD4849E);
  static const Color accentRoseLight = Color(0xFFF2BCCD);

  // Text colors
  static const Color textPrimary = Color(0xFFF5EDF0);
  static const Color textMuted = Color(0xFFB6A5AB);
  static const Color textDark = Color(0xFF2A1018);

  // Chip Badges
  static const Color chipBlueBg = Color(0xFF1F2B42);
  static const Color chipBlueFg = Color(0xFFA9C6F2);

  static const Color chipPurpleBg = Color(0xFF2E2542);
  static const Color chipPurpleFg = Color(0xFFC9B8E8);

  static const Color chipAmberBg = Color(0xFF3A2E17);
  static const Color chipAmberFg = Color(0xFFE8C27A);

  static const Color chipRedBg = Color(0xFF3E1F25);
  static const Color chipRedFg = Color(0xFFF3A3A8);

  static const Color chipGreenBg = Color(0xFF1A3326);
  static const Color chipGreenFg = Color(0xFF86E2A5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentRose, accentRoseDark],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF47293A), Color(0xFF2B1C24)],
  );

  static const RadialGradient welcomeGradient = RadialGradient(
    center: Alignment(0.0, -0.6),
    radius: 1.25,
    colors: [
      Color(0xFF3A262F),
      Color(0xFF1A1317),
      Color(0xFF110B0E),
    ],
  );
}

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String formatRupiah(int amount) {
    return _currencyFormat.format(amount).replaceAll(' ', '');
  }

  static String formatDate(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final dayName = days[(date.weekday - 1) % 7];
    final monthName = months[(date.month - 1) % 12];
    return '$dayName, ${date.day} $monthName';
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      primaryColor: AppColors.accentRose,
      canvasColor: AppColors.bgSurface,
      cardColor: AppColors.bgSurface,
      dividerColor: AppColors.borderCard,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentRose,
        surface: AppColors.bgSurface,
        onPrimary: AppColors.textDark,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: const TextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
