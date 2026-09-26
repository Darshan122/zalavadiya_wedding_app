import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeddingTheme {
  // Pinterest Luxury Wedding Palette (Derived from Darshan & Brijal logo)
  static const Color maroonPrimary = Color(0xFF7A1C2E);    // Deep Velvet Wine / Crimson
  static const Color maroonDeep = Color(0xFF550E1C);       // Dark Burgundy
  static const Color maroonLight = Color(0xFFFBF0F2);      // Soft Wine Tint for tags
  
  static const Color goldAccent = Color(0xFFC89B3C);       // Regal Royal Gold
  static const Color goldLight = Color(0xFFF9F3E5);        // Champagne Gold Tint
  static const Color goldBorder = Color(0xFFE6D2A9);       // Subtle Metallic Gold Border
  
  static const Color palmGreen = Color(0xFF386641);        // Botanical Eucalyptus Foliage
  static const Color greenLight = Color(0xFFEAF4EC);       // Soft Mint Sage
  
  static const Color ivoryBg = Color(0xFFFAF7F2);          // Creamy Handmade Paper
  static const Color cardBg = Colors.white;
  static const Color borderSubtle = Color(0xFFEDE6DA);     // Delicate Card Border
  
  static const Color textMain = Color(0xFF1E1715);
  static const Color textSub = Color(0xFF6B5E57);
  static const Color textLight = Color(0xFF9E8F87);

  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color whatsappDark = Color(0xFF128C7E);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ivoryBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: maroonPrimary,
        primary: maroonPrimary,
        secondary: goldAccent,
        surface: cardBg,
        onSurface: textMain,
      ),
      fontFamily: GoogleFonts.hindVadodara().fontFamily,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.playfairDisplay(
          color: maroonPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: maroonPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.hindVadodara(
          color: textMain,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.hindVadodara(
          color: textMain,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.hindVadodara(
          color: textSub,
          fontSize: 12.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: maroonPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.hindVadodara(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ivoryBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: maroonPrimary, width: 1.5),
        ),
      ),
    );
  }
}
