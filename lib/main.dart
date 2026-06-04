/// Точка входа в приложение.
/// Инициализирует DI (GetIt), запускает фоновые сервисы (TimerEngine, AutomationEngine).
/// Создаёт комнаты по умолчанию при первом запуске.
/// Запускает корневой виджет SHomeApp.
import 'package:flutter/material.dart';
import 'di/injection.dart';
import 'domain/models/room.dart';
import 'domain/repositories/room_repository.dart';
import 'data/services/automation_engine.dart';
import 'data/services/timer_engine.dart';
import 'app.dart';

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

  // Запуск приложения
  runApp(const SHomeApp());
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