import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeName = prefs.getString('theme_mode');
      if (modeName != null) {
        _themeMode = ThemeMode.values.byName(modeName);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load theme preference: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('theme_mode', mode.name);
      } catch (e) {
        debugPrint('Failed to save theme preference: $e');
      }
    }
  }
}
