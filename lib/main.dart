/// Точка входа в приложение.
library;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'di/injection.dart';
import 'domain/models/room.dart';
import 'domain/repositories/room_repository.dart';
import 'data/services/automation_engine.dart';
import 'data/services/timer_engine.dart';
import 'data/services/config_service.dart';
import 'data/services/mailru_cloud_service.dart';
import 'app.dart';
import 'domain/services/mqtt_service_interface.dart';
import 'data/services/frigate_alarm_service.dart';
import 'data/services/vk_notification_service.dart';
import 'application/state/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  ThemeNotifier.updateAutoCache();

  getIt<TimerEngine>().start();
  getIt<AutomationEngine>().start();

  _addDefaultRooms();
  _connectMqtt();

  runApp(const SHomeAppObserver(child: SHomeApp()));
}

class SHomeAppObserver extends StatefulWidget {
  final Widget child;
  const SHomeAppObserver({required this.child, super.key});

  @override
  State<SHomeAppObserver> createState() => _SHomeAppObserverState();
}

class _SHomeAppObserverState extends State<SHomeAppObserver> with WidgetsBindingObserver {
  Timer? _themeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoThemeTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeTimer?.cancel();
    super.dispose();
  }

  void _startAutoThemeTimer() {
    _themeTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkAutoTheme());
    _checkAutoTheme();
  }

  void _checkAutoTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final auto = prefs.getBool('auto_theme') ?? false;
    if (!auto) return;

    final hour = DateTime.now().hour;
    final newMode = (hour >= 6 && hour < 18) ? 'light' : 'dark';

    final currentMode = prefs.getString('theme_mode') ?? 'dark';
    if (newMode != currentMode) {
      await prefs.setString('theme_mode', newMode);
      ThemeNotifier.updateAutoCache();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ConfigService.autoBackup();
      ConfigService.buildConfigJson().then((json) {
        MailruCloudService.autoSync(json);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> _connectMqtt() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final broker = prefs.getString('mqtt_broker') ?? '192.168.1.100';
    final port = int.tryParse(prefs.getString('mqtt_port') ?? '1883') ?? 1883;

    final mqttService = getIt<MqttService>();
    await mqttService.connect(broker, port: port);

    final frigateService = FrigateAlarmService(mqttService);
    frigateService.onAlarm = (alarm) async {
      debugPrint('🚨 Тревога: ${alarm.cameraId} - ${alarm.label}');
      final vk = VkNotificationService();
      await vk.loadSettings();
      await vk.sendAlarm(cameraName: 'Камера ${alarm.cameraId}', label: alarm.label, score: alarm.score);
    };
    await frigateService.start();

    debugPrint('✅ MQTT подключён к $broker:$port');
  } catch (e) {
    debugPrint('❌ Ошибка MQTT: $e');
  }
}

void _addDefaultRooms() async {
  await Future.delayed(const Duration(milliseconds: 100));
  final roomRepo = getIt<RoomRepository>();
  final rooms = await roomRepo.getAllRooms();
  if (rooms.isEmpty) {
    await roomRepo.saveRoom(Room(id: 'living', name: 'Гостиная', icon: '🛋️', sortOrder: 0));
    await roomRepo.saveRoom(Room(id: 'bedroom', name: 'Спальня', icon: '🛏️', sortOrder: 1));
    await roomRepo.saveRoom(Room(id: 'kitchen', name: 'Кухня', icon: '🍳', sortOrder: 2));
    await roomRepo.saveRoom(Room(id: 'other', name: 'Техника', icon: '🔌', sortOrder: 3));
  }
}