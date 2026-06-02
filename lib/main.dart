import 'package:flutter/material.dart';
import 'di/injection.dart';
import 'domain/models/room.dart';
import 'domain/repositories/room_repository.dart';
import 'data/services/automation_engine.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  getIt<AutomationEngine>().start();
  _addDefaultRooms();

  runApp(const SHomeApp());
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