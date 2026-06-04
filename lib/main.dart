/// Точка входа в приложение.
/// Инициализирует DI (GetIt), запускает фоновые сервисы (TimerEngine, AutomationEngine).
/// Создаёт комнаты по умолчанию при первом запуске.
/// Запускает корневой виджет SHomeApp.
library;
import 'package:flutter/material.dart';
import 'di/injection.dart';
import 'domain/models/room.dart';
import 'domain/repositories/room_repository.dart';
import 'data/services/automation_engine.dart';
import 'data/services/timer_engine.dart';
import 'data/services/config_service.dart';
import 'data/services/mailru_cloud_service.dart';
import 'app.dart';
import 'data/services/test_data_generator.dart';

void main() {
  // Инициализация Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Регистрация всех зависимостей (GetIt)
  configureDependencies();

  // Запуск фоновых сервисов
  getIt<TimerEngine>().start();           // Движок отложенных команд
  getIt<AutomationEngine>().start();      // Движок сцен по времени

  // Создание комнат по умолчанию (если БД пустая)
  _addDefaultRooms();

  // Генерируем тестовые данные один раз
  TestDataGenerator.generateSensorData();

  // Запуск приложения с Observer'ом для автобекапа
  runApp(const SHomeAppObserver(child: SHomeApp()));
}

/// Observer, который отслеживает жизненный цикл приложения
/// и делает автобекап + облачную синхронизацию при сворачивании.
class SHomeAppObserver extends StatefulWidget {
  final Widget child;
  const SHomeAppObserver({required this.child, super.key});

  @override
  State<SHomeAppObserver> createState() => _SHomeAppObserverState();
}

class _SHomeAppObserverState extends State<SHomeAppObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Локальный автобекап
      ConfigService.autoBackup();

      // Облачная синхронизация (если подключено и тумблер вкл)
      ConfigService.buildConfigJson().then((json) {
        MailruCloudService.autoSync(json);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Добавляет 4 комнаты по умолчанию при первом запуске.
/// Если в БД уже есть комнаты — ничего не делает.
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