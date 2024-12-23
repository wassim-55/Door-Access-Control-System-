import 'package:flutter/material.dart';

class ThemeUtils {
  static ThemeMode toggleTheme(ThemeMode currentMode) {
    return currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  static Icon themeIcon(ThemeMode mode) {
    return Icon(
      mode == ThemeMode.light ? Icons.light_mode : Icons.dark_mode,
      color: mode == ThemeMode.light ? Colors.yellow : Colors.grey,
    );
  }

  static String themeText(ThemeMode mode) {
    return mode == ThemeMode.light ? "Light Mode" : "Dark Mode";
  }
}
