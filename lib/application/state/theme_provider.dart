/// Провайдер темы на Riverpod.
/// Управляет переключением темы: Система → Светлая → Тёмная → Система.
/// Сохраняет выбор в SharedPreferences.
/// Предоставляет themeName и themeIcon для отображения на Dashboard.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Глобальный провайдер темы.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Управляет режимом темы с сохранением в SharedPreferences.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  /// Ключ для хранения темы в SharedPreferences
  static const _key = 'theme_mode';

  /// При создании загружает сохранённую тему
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Загружает тему из SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key) ?? 'system';
    state = _parseTheme(value);
  }

  /// Переключает тему по кругу: Система → Светлая → Тёмная → Система.
  /// Каждое переключение сохраняется в SharedPreferences.
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

  /// Преобразует строку из SharedPreferences в ThemeMode
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

  /// Человекочитаемое название текущей темы для отображения на кнопке
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

  /// Иконка текущей темы для отображения на кнопке
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