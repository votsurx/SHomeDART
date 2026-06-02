import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key) ?? 'system';
    state = _parseTheme(value);
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();

    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setString(_key, 'light');
    } else if (state == ThemeMode.light) {
      state = ThemeMode.system;
      await prefs.setString(_key, 'system');
    } else {
      state = ThemeMode.dark;
      await prefs.setString(_key, 'dark');
    }
  }

  ThemeMode _parseTheme(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get themeName {
    switch (state) {
      case ThemeMode.dark:
        return 'Ночь';
      case ThemeMode.light:
        return 'День';
      default:
        return 'Система';
    }
  }

  IconData get themeIcon {
    switch (state) {
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.light:
        return Icons.wb_sunny;
      default:
        return Icons.brightness_auto;
    }
  }
}