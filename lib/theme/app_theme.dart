import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeddingThemePalette {
  final String id;
  final String name;
  final String subtitle;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color accent;
  final Color accentLight;
  final List<Color> previewColors;

  const WeddingThemePalette({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.accentLight,
    required this.previewColors,
  });

  static const WeddingThemePalette roseGold = WeddingThemePalette(
    id: 'rose_gold',
    name: 'Rose Gold & Champagne',
    subtitle: 'Romantis, manis, dan elegan',
    primary: Color(0xFFC88289),
    primaryDark: Color(0xFFA25B63),
    primaryLight: Color(0xFFF9EEF0),
    accent: Color(0xFFD4AF37),
    accentLight: Color(0xFFFAF4E1),
    previewColors: [Color(0xFFC88289), Color(0xFFD4AF37), Color(0xFFF9EEF0)],
  );

  static const WeddingThemePalette emeraldGold = WeddingThemePalette(
    id: 'emerald_gold',
    name: 'Emerald Green & Gold',
    subtitle: 'Mewah, royal, dan bernuansa alam',
    primary: Color(0xFF2E6F56),
    primaryDark: Color(0xFF1E4C3A),
    primaryLight: Color(0xFFE8F3EE),
    accent: Color(0xFFD4AF37),
    accentLight: Color(0xFFFAF4E1),
    previewColors: [Color(0xFF2E6F56), Color(0xFFD4AF37), Color(0xFFE8F3EE)],
  );

  static const WeddingThemePalette dustyBlue = WeddingThemePalette(
    id: 'dusty_blue',
    name: 'Dusty Blue & Slate',
    subtitle: 'Modern, aesthetic, dan sejuk',
    primary: Color(0xFF5B7E98),
    primaryDark: Color(0xFF3F596D),
    primaryLight: Color(0xFFEDF3F7),
    accent: Color(0xFFC5A059),
    accentLight: Color(0xFFF9F5EC),
    previewColors: [Color(0xFF5B7E98), Color(0xFFC5A059), Color(0xFFEDF3F7)],
  );

  static const WeddingThemePalette terracotta = WeddingThemePalette(
    id: 'terracotta',
    name: 'Terracotta & Warm Beige',
    subtitle: 'Rustic, hangat, dan earthy tone',
    primary: Color(0xFFC8644A),
    primaryDark: Color(0xFFA04B35),
    primaryLight: Color(0xFFFBF0EC),
    accent: Color(0xFFD99B4B),
    accentLight: Color(0xFFFAF3E7),
    previewColors: [Color(0xFFC8644A), Color(0xFFD99B4B), Color(0xFFFBF0EC)],
  );

  static const WeddingThemePalette burgundy = WeddingThemePalette(
    id: 'burgundy',
    name: 'Burgundy & Royal Gold',
    subtitle: 'Tradisional modern, glamor, dan berwibawa',
    primary: Color(0xFF8B263E),
    primaryDark: Color(0xFF651529),
    primaryLight: Color(0xFFF7EBF0),
    accent: Color(0xFFDAA520),
    accentLight: Color(0xFFFAF4E1),
    previewColors: [Color(0xFF8B263E), Color(0xFFDAA520), Color(0xFFF7EBF0)],
  );

  static const WeddingThemePalette lavender = WeddingThemePalette(
    id: 'lavender',
    name: 'Lavender & Soft Cream',
    subtitle: 'Pastel, lembut, dan manis',
    primary: Color(0xFF8E7AB5),
    primaryDark: Color(0xFF6E5699),
    primaryLight: Color(0xFFF4F0FB),
    accent: Color(0xFFE0A96D),
    accentLight: Color(0xFFFAF4ED),
    previewColors: [Color(0xFF8E7AB5), Color(0xFFE0A96D), Color(0xFFF4F0FB)],
  );

  static const List<WeddingThemePalette> allThemes = [
    roseGold,
    emeraldGold,
    dustyBlue,
    terracotta,
    burgundy,
    lavender,
  ];

  static WeddingThemePalette fromId(String? id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => roseGold,
    );
  }
}

class AppTheme {
  // Warna Netral & Status
  static const Color backgroundLight = Color(0xFFFBF9F9);
  static const Color surfaceLight = Colors.white;
  static const Color cardBorder = Color(0xFFEFE8E8);
  
  static const Color textDark = Color(0xFF2C2526);
  static const Color textMuted = Color(0xFF7A6F71);
  static const Color textLight = Color(0xFFB5A8AA);
  
  static const Color successGreen = Color(0xFF48A868);
  static const Color warningOrange = Color(0xFFE58F3B);
  static const Color errorRed = Color(0xFFD9534F);
  static const Color infoBlue = Color(0xFF4A90E2);

  // Fallback defaults
  static const Color primaryRose = Color(0xFFC88289);
  static const Color primaryRoseDark = Color(0xFFA25B63);
  static const Color primaryRoseLight = Color(0xFFF9EEF0);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFFAF4E1);

  static ThemeData buildTheme(WeddingThemePalette palette) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        primary: palette.primary,
        secondary: palette.accent,
        surface: surfaceLight,
        error: errorRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: textMuted,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(color: textLight, fontSize: 13),
        labelStyle: GoogleFonts.poppins(color: textMuted, fontSize: 13),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: palette.primary,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get lightTheme => buildTheme(WeddingThemePalette.roseGold);
}
