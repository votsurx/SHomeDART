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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  AdaptivePoller? _poller;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final isComplete = await OnboardingManager.isOnboardingComplete();
    if (!isComplete && mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Запускаем поллер один раз
    if (_poller == null) {
      _poller = AdaptivePoller(
        getIt<TuyaProtocol>(),
        getIt<Talker>(),
            (deviceId, isOn) {
          if (mounted) ref.read(devicesProvider.notifier).updateDeviceState(deviceId, isOn);
        },
            (deviceId, isOnline) {
          if (mounted) ref.read(devicesProvider.notifier).updateOnlineState(deviceId, isOnline);
        },
      );
      _poller!.start();

      // Пробрасываем forceReset в DevicesNotifier
      ref.read(devicesProvider.notifier).onCommandSent = (deviceId) {
        _poller?.forceReset(deviceId);
      };
    }

    final devices = ref.watch(devicesProvider);
    _poller?.updateDevices(devices);

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
                _buildTile(icon: Icons.bar_chart, label: 'Статистика', color: Colors.green, onTap: () {}),
                _buildTile(icon: Icons.timer, label: 'Таймеры', color: Colors.deepOrange, onTap: () => context.push('/timers')),
                _buildTile(icon: Icons.notifications, label: 'События', color: Colors.red, onTap: () => context.push('/events')),
              ],
            ),
          );
        },
      ),
    );
  }

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