// theme.dart
// Palet warna BengkelKu (gelap = tampilan utama, terang = pilihan).

import 'package:flutter/material.dart';

class Pal {
  final Color page, surface, card, ink, muted, line;
  final Color primary, primary2, onPrimary, soft, softInk;
  final Color ok, okBg, warn, warnBg, info, infoBg, bad, badBg;
  final Color plate, onPlate, tile1, tile2, tileLine, hd1, hd2, w1, w2, w3;

  const Pal({
    required this.page,
    required this.surface,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.primary,
    required this.primary2,
    required this.onPrimary,
    required this.soft,
    required this.softInk,
    required this.ok,
    required this.okBg,
    required this.warn,
    required this.warnBg,
    required this.info,
    required this.infoBg,
    required this.bad,
    required this.badBg,
    required this.plate,
    required this.onPlate,
    required this.tile1,
    required this.tile2,
    required this.tileLine,
    required this.hd1,
    required this.hd2,
    required this.w1,
    required this.w2,
    required this.w3,
  });

  static const Pal dark = Pal(
    page: Color(0xFF0E0A0C),
    surface: Color(0xFF150F12),
    card: Color(0xFF1F171B),
    ink: Color(0xFFF5EDF0),
    muted: Color(0xFFB6A5AB),
    line: Color(0xFF32262B),
    primary: Color(0xFFE59BB2),
    primary2: Color(0xFFD4849E),
    onPrimary: Color(0xFF2A1018),
    soft: Color(0xFF35232B),
    softInk: Color(0xFFF2BCCD),
    ok: Color(0xFFC9B8E8),
    okBg: Color(0xFF2E2542),
    warn: Color(0xFFE8C27A),
    warnBg: Color(0xFF3A2E17),
    info: Color(0xFFA9C6F2),
    infoBg: Color(0xFF1F2B42),
    bad: Color(0xFFF3A3A8),
    badBg: Color(0xFF3E1F25),
    plate: Color(0xFF0B0709),
    onPlate: Color(0xFFF5EDF0),
    tile1: Color(0xFF3B2831),
    tile2: Color(0xFF241A1F),
    tileLine: Color(0xFF5B3A47),
    hd1: Color(0xFF47293A),
    hd2: Color(0xFF2B1C24),
    w1: Color(0xFF3A262F),
    w2: Color(0xFF1A1317),
    w3: Color(0xFF110B0E),
  );

  static const Pal light = Pal(
    page: Color(0xFFF4EBEE),
    surface: Color(0xFFFBF6F7),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF2A1D22),
    muted: Color(0xFF7A6670),
    line: Color(0xFFEADBE0),
    primary: Color(0xFFB04F6A),
    primary2: Color(0xFF9C4059),
    onPrimary: Color(0xFFFFFFFF),
    soft: Color(0xFFF8E6EC),
    softInk: Color(0xFF8A3550),
    ok: Color(0xFF5F4A8B),
    okBg: Color(0xFFEEE7F8),
    warn: Color(0xFF85570F),
    warnBg: Color(0xFFFBEBCB),
    info: Color(0xFF2F5C99),
    infoBg: Color(0xFFE1ECFA),
    bad: Color(0xFFA33A3A),
    badBg: Color(0xFFFBE1E1),
    plate: Color(0xFF3A2A31),
    onPlate: Color(0xFFFBF1F4),
    tile1: Color(0xFFFFFFFF),
    tile2: Color(0xFFF8E6EC),
    tileLine: Color(0xFFEBCFD8),
    hd1: Color(0xFFC0607D),
    hd2: Color(0xFFA04460),
    w1: Color(0xFFF9E4EB),
    w2: Color(0xFFFBF6F7),
    w3: Color(0xFFF6EBEE),
  );
}

/// Mengambil palet sesuai tema yang sedang aktif.
Pal pal(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? Pal.dark : Pal.light;

ThemeData buildTheme(bool dark) {
  final p = dark ? Pal.dark : Pal.light;
  final base = ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    useMaterial3: true,
  );
  return base.copyWith(
    scaffoldBackgroundColor: p.surface,
    colorScheme: base.colorScheme.copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      surface: p.surface,
      onSurface: p.ink,
    ),
    textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
    dividerColor: p.line,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(color: p.surface, fontWeight: FontWeight.w600),
      behavior: SnackBarBehavior.floating,
    ),
  );
}