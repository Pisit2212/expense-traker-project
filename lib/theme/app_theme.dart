import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const seed = Color(0xFF0B6E4F); // เขียวเอมเมอรัลเข้ม
  static const income = Color(0xFF1E7D5A);
  static const expense = Color(0xFFA13D2E); // สีอิฐหม่น ดูนุ่มกว่าสีแดงสด
  static const incomeLight = Color(0xFFDCEFE6);
  static const expenseLight = Color(0xFFF3DEDA);

  static const lightBg = Color(0xFFF7F6F2); // ครีมอบอุ่น
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE7E4DC);

  static const darkBg = Color(0xFF15181A);
  static const darkSurface = Color(0xFF1D2124);
  static const darkBorder = Color(0xFF2C3033);
}

class AppTheme {
  static const _radius = 16.0;

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );
    final textTheme = GoogleFonts.ibmPlexSansThaiTextTheme();
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.lightBg,
      useMaterial3: true,
      textTheme: textTheme.apply(
        bodyColor: const Color(0xFF262A26),
        displayColor: const Color(0xFF1A1D1A),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.lightBg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.ibmPlexSansThai(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1D1A),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1D1A)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: base.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.seed,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.seed,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedColor: AppColors.incomeLight,
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF262A26)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    );
    final textTheme = GoogleFonts.ibmPlexSansThaiTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.darkBg,
      useMaterial3: true,
      textTheme: textTheme.apply(
        bodyColor: const Color(0xFFE9EBE9),
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkBg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.ibmPlexSansThai(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: base.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: base.primary,
          foregroundColor: base.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: base.primary,
        foregroundColor: base.onPrimary,
        elevation: 2,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: base.primaryContainer,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFFE9EBE9)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}