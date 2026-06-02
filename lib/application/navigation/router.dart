import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/device_list_screen.dart';
import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/scan_screen.dart';
import '../../presentation/screens/onboarding/rooms_setup_screen.dart';
import '../../presentation/screens/energy_screen.dart';
import '../../presentation/screens/scenes_screen.dart';
import '../../presentation/screens/scan_devices_screen.dart';
import '../../presentation/screens/rooms_manage_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/rooms',
      builder: (context, state) => const RoomsManageScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanDevicesScreen(),
    ),
    GoRoute(
      path: '/onboarding/scan',
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: '/scenes',
      builder: (context, state) => const ScenesScreen(),
    ),
    GoRoute(
      path: '/energy',
      builder: (context, state) => const EnergyScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/devices',
      builder: (context, state) => const DeviceListScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WelcomeScreen(),
      routes: [
        GoRoute(
          path: 'scan',
          builder: (context, state) => const ScanScreen(),
        ),
        GoRoute(
          path: 'rooms',
          builder: (context, state) => const RoomsSetupScreen(),
        ),
      ],
    ),
  ],
);