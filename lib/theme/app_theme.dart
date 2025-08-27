import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static Color get neonGreen => const Color(0xFF00FF9C);
  static Color get neonBlue => const Color(0xFF00D1FF);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: neonGreen,
        secondary: neonBlue,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0E12),
      textTheme: GoogleFonts.robotoMonoTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0E141A),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF121820),
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}
