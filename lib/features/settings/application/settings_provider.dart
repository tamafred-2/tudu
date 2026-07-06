import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _soundEffectsEnabled = true;

  SettingsProvider() {
    _loadSettings();
  }

  bool get soundEffectsEnabled => _soundEffectsEnabled;

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  Future<void> toggleSoundEffects(bool value) async {
    if (_soundEffectsEnabled != value) {
      _soundEffectsEnabled = value;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('sound_effects_enabled', value);
      } catch (e) {
        debugPrint('Failed to save settings: $e');
      }
    }
  }
}
