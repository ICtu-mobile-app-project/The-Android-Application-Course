import 'package:flutter/material.dart';

// ── Brand colours ──────────────────────────────────────────────────────────
const Color kOrangeStart = Color(0xFFFF6B35); // warm orange
const Color kOrangeMid = Color(0xFFFF8C42);
const Color kBlueMid = Color(0xFF4A90D9);
const Color kBlueEnd = Color(0xFF1A73E8); // vivid blue
const Color kScaffoldBg = Color(0xFFF5F6FA);

// ── Shared gradient ────────────────────────────────────────────────────────
const LinearGradient kAppGradient = LinearGradient(
  colors: [kOrangeStart, kOrangeMid, kBlueMid, kBlueEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ── Button gradient (slightly richer) ────────────────────────────────────
const LinearGradient kButtonGradient = LinearGradient(
  colors: [kOrangeStart, kBlueEnd],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ── App theme ─────────────────────────────────────────────────────────────
ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kBlueEnd,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: kScaffoldBg,
    fontFamily: 'Roboto',
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBlueEnd, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
