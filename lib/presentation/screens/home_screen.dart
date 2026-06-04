/// Главный экран (Dashboard) с адаптивной сеткой плиток.
/// Запускает AdaptivePoller для фонового опроса устройств.
/// Проверяет онбординг при старте.
/// Позволяет переключать тему.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker/talker.dart';
import '../../application/onboarding_manager.dart';
import '../../application/state/theme_provider.dart';
import '../../application/state/devices_provider.dart';
import '../../di/injection.dart';
import '../../data/protocols/tuya_protocol.dart';
import '../../data/services/adaptive_poller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Адаптивный поллер для опроса устройств
  AdaptivePoller? _poller;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _initPoller();
  }

  /// Инициализирует AdaptivePoller с интервалом из настроек.
  Future<void> _initPoller() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt('poll_interval') ?? 2;
    final interval = Duration(seconds: seconds);

    if (!mounted) return;

    setState(() {
      _poller = AdaptivePoller(
        getIt<TuyaProtocol>(),    // Протокол Tuya
        getIt<Talker>(),          // Логгер
        // Колбэк при изменении состояния одноканального
            (deviceId, isOn) {
          if (mounted) ref.read(devicesProvider.notifier).updateDeviceState(deviceId, isOn);
        },
        // Колбэк при изменении онлайн-статуса
            (deviceId, isOnline) {
          if (mounted) ref.read(devicesProvider.notifier).updateOnlineState(deviceId, isOnline);
        },
        // Колбэк при изменении многоканального
            (deviceId, states) {
          if (mounted) ref.read(devicesProvider.notifier).updateDeviceStates(deviceId, states);
        },
        // Колбэк для датчиков
        onSensorUpdate: (deviceId, properties) {
          if (mounted) ref.read(devicesProvider.notifier).updateDeviceProperties(deviceId, properties);
        },
        normalInterval: interval,
      );
      _poller!.start();
    });
  }

  /// Проверяет, пройден ли онбординг.
  Future<void> _checkOnboarding() async {
    final isComplete = await OnboardingManager.isOnboardingComplete();
    if (!isComplete && mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Обновляем список устройств в поллере
    final devices = ref.watch(devicesProvider);
    _poller?.updateDevices(devices);

    // Тема
    final themeNotifier = ref.watch(themeProvider.notifier);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Добро пожаловать!'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Адаптивная сетка: 2, 3 или 4 колонки
          final crossAxisCount = width > 600 ? 4 : (width > 400 ? 3 : 2);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildTile(icon: Icons.devices, label: 'Устройства', color: Colors.blue, onTap: () => context.push('/devices')),
                _buildTile(icon: Icons.bolt, label: 'Энергия', color: Colors.amber, onTap: () => context.push('/energy')),
                _buildTile(icon: Icons.movie, label: 'Сцены', color: Colors.purple, onTap: () => context.push('/scenes')),
                _buildTile(icon: Icons.search, label: 'Сканировать', color: Colors.teal, onTap: () => context.push('/scan')),
                _buildTile(icon: themeNotifier.themeIcon, label: 'Тема: ${themeNotifier.themeName}', color: isDark ? Colors.indigo : Colors.orange, onTap: () => themeNotifier.toggle()),
                _buildTile(icon: Icons.meeting_room, label: 'Комнаты', color: Colors.brown, onTap: () => context.push('/rooms')),
                _buildTile(icon: Icons.bar_chart, label: 'Статистика', color: Colors.green, onTap: () => context.push('/statistics')),
                _buildTile(icon: Icons.timer, label: 'Таймеры', color: Colors.deepOrange, onTap: () => context.push('/timers')),
                _buildTile(icon: Icons.notifications, label: 'События', color: Colors.red, onTap: () => context.push('/events')),
                _buildTile(icon: Icons.videocam, label: 'Видео', color: Colors.red, onTap: () {}),
                _buildTile(icon: Icons.cloud, label: 'Облако', color: Colors.lightBlue, onTap: () => context.push('/cloud')),  // ← НОВАЯ ПЛИТКА
                _buildTile(icon: Icons.settings, label: 'Настройки', color: Colors.grey, onTap: () => context.push('/settings')),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Строит одну плитку Dashboard.
  Widget _buildTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}