import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF039BE5);
  static const border = Color(0xFFD9D9D9);
  static const disabled = Color(0xFFDCDCDC);
  static const disabledText = Color(0xFFA8A8A8);
  static const chipBg = Color(0xFFF2F2F2);
}

OutlineInputBorder _border(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: BorderSide(color: c),
);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary)
      .copyWith(primary: AppColors.primary);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16),
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.disabledText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _border(AppColors.border),
      enabledBorder: _border(AppColors.border),
      focusedBorder: _border(AppColors.primary),
      errorBorder: _border(Colors.red),
      focusedErrorBorder: _border(Colors.red),
    ),
  );
}