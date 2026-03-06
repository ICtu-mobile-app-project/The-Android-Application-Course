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
ThemeData appTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kBlueEnd,
      brightness: brightness,
    ),
    scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : kScaffoldBg,
    fontFamily: 'Roboto',
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kBlueEnd, width: 2),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
