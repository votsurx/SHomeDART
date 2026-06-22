/// Роутер приложения на GoRouter.
library;
import 'package:go_router/go_router.dart';
import '../../presentation/screens/menu_screen.dart';
import '../../presentation/screens/device_list_screen.dart';
import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/rooms_setup_screen.dart';
import '../../presentation/screens/energy_screen.dart';
import '../../presentation/screens/scenes_screen.dart';
import '../../presentation/screens/scan_devices_screen.dart';
import '../../presentation/screens/rooms_manage_screen.dart';
import '../../presentation/screens/events_screen.dart';
import '../../presentation/screens/timers_screen.dart';
import '../../presentation/screens/statistics_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/cloud_settings_screen.dart';
import '../../presentation/screens/nvr_settings_screen.dart'; // ✅ ДОБАВИТЬ

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // ============================================================
    // 📱 ОСНОВНЫЕ ЭКРАНЫ
    // ============================================================

    GoRoute(
      path: '/',
      builder: (context, state) => const DeviceListScreen(),
    ),

    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),

    // ============================================================
    // ⚙️ НАСТРОЙКИ
    // ============================================================

    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // ✅ ДОБАВЛЯЕМ МАРШРУТ ДЛЯ NVR
    GoRoute(
      path: '/nvr_settings',
      builder: (context, state) => const NvrSettingsScreen(),
    ),

    GoRoute(
      path: '/cloud',
      builder: (context, state) => const CloudSettingsScreen(),
    ),

    // ============================================================
    // 🏠 УПРАВЛЕНИЕ ДОМОМ
    // ============================================================

    GoRoute(
      path: '/rooms',
      builder: (context, state) => const RoomsManageScreen(),
    ),

    GoRoute(
      path: '/scenes',
      builder: (context, state) => const ScenesScreen(),
    ),

    GoRoute(
      path: '/timers',
      builder: (context, state) => const TimersScreen(),
    ),

    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),

    GoRoute(
      path: '/energy',
      builder: (context, state) => const EnergyScreen(),
    ),

    GoRoute(
      path: '/events',
      builder: (context, state) => const EventsScreen(),
    ),

    // ============================================================
    // 🔍 СКАНЕРЫ
    // ============================================================

    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanDevicesScreen(),
    ),

    // ============================================================
    // 🎓 ОНБОРДИНГ
    // ============================================================

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WelcomeScreen(),
      routes: [
        GoRoute(
          path: 'scan',
          builder: (context, state) => const ScanDevicesScreen(isOnboarding: true),
        ),
        GoRoute(
          path: 'rooms',
          builder: (context, state) => const RoomsSetupScreen(),
        ),
      ],
    ),
  ],
);