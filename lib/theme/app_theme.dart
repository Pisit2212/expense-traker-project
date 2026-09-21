import 'package:flutter/material.dart';

class AppColors {
  static const seed = Color(0xFF00897B);
  static const income = Color(0xFF2E7D32);
  static const expense = Color(0xFFC62828);
  static const incomeLight = Color(0xFFC8E6C9);
  static const expenseLight = Color(0xFFFFCDD2);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        colorSchemeSeed: AppColors.seed,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      );
}