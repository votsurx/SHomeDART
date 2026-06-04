/// Корневой виджет приложения.
/// Оборачивает всё в ProviderScope (Riverpod).
/// Подписывается на themeProvider для переключения светлой/тёмной темы.
/// Использует GoRouter для навигации.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/navigation/router.dart';
import 'application/state/theme_provider.dart';
import 'presentation/theme/app_theme.dart';

class SHomeApp extends StatelessWidget {
  const SHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          // Слушаем провайдер темы
          final themeMode = ref.watch(themeProvider);

          return MaterialApp.router(
            title: 'SHome',
            theme: AppTheme.light(),           // Светлая тема
            darkTheme: AppTheme.dark(),        // Тёмная тема
            themeMode: themeMode,              // Система/Светлая/Тёмная
            routerConfig: router,              // GoRouter
            debugShowCheckedModeBanner: false, // Убираем баннер Debug
          );
        },
      ),
    );
  }
}