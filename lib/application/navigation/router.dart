/// Роутер приложения на GoRouter.
/// Определяет все маршруты и связывает их с соответствующими экранами.
/// Поддерживает онбординг с отдельным сканером (isOnboarding=true).
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

/// Главный роутер. Содержит все маршруты приложения.
/// initialLocation: '/' — главный экран (устройства).
final router = GoRouter(
  initialLocation: '/',
  routes: [
    // Главный экран — список устройств
    GoRoute(
      path: '/',
      builder: (context, state) => const DeviceListScreen(),
    ),
    // Меню — лаунчер с плитками (бывший HomeScreen)
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),
    // Облако — подключение Mail.ru, синхронизация бекапов
    GoRoute(
      path: '/cloud',
      builder: (context, state) => const CloudSettingsScreen(),
    ),
    // Настройки — экспорт/импорт конфигурации, интервал опроса
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    // Статистика — графики вкл/выкл, энергопотребление
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    // Таймеры — отложенное вкл/выкл устройств
    GoRoute(
      path: '/timers',
      builder: (context, state) => const TimersScreen(),
    ),
    // Журнал событий — история всех действий
    GoRoute(
      path: '/events',
      builder: (context, state) => const EventsScreen(),
    ),
    // Управление комнатами — добавить, переименовать, удалить
    GoRoute(
      path: '/rooms',
      builder: (context, state) => const RoomsManageScreen(),
    ),
    // Сканер устройств
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanDevicesScreen(),
    ),
    // Сцены — создание/редактирование, ручной и timed запуск
    GoRoute(
      path: '/scenes',
      builder: (context, state) => const ScenesScreen(),
    ),
    // Энергомониторинг — потребление kWh по устройствам
    GoRoute(
      path: '/energy',
      builder: (context, state) => const EnergyScreen(),
    ),
    // Онбординг — Welcome экран для новых пользователей
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