import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFFE64A19); // Pilo's Orange (Darkened for Contrast)
  static const backgroundColor = Color(0xFFF5F7F8); // Clean soft light background
  static const surfaceColor = Colors.white;
  static const accentColor = Color(0xFF2E7D32); // Deep Jungle Green
  static const darkBackgroundColor = Color(0xFF1A1C1E);
  static const darkSurfaceColor = Color(0xFF222427);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        onSurface: Colors.black87,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: const Color(0xFF1A1C1E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1C1E),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkSurfaceColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white10),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
