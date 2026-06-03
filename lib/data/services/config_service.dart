import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../local/database.dart';
import '../local/entities/device_entity.dart';
import '../local/entities/room_entity.dart';
import '../local/entities/scene_entity.dart';
import '../../domain/models/device_timer.dart';
import 'package:permission_handler/permission_handler.dart';

class ConfigService {
  /// Экспорт конфигурации в JSON и шаринг
  static Future<void> exportConfig() async {
    // Запрашиваем разрешение на запись
    if (await Permission.storage.request().isGranted) {
      final config = await _buildConfigJson();

      // Сохраняем в папку Downloads
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('${dir.path}/shome_backup.json');
      await file.writeAsString(config);

      // Шарим файл
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Резервная копия SHome',
      );
    } else {
      throw Exception('Нет разрешения на запись файлов');
    }
  }

  /// Импорт конфигурации из JSON файла
  static Future<void> importConfig() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      await _restoreFromJson(jsonString);
    }
  }

  /// Собираем JSON из всех данных БД
  static Future<String> _buildConfigJson() async {
    final devices = await AppDatabase.getAllDevices();
    final rooms = await AppDatabase.getAllRooms();
    final scenes = await AppDatabase.getAllScenes();
    final timers = await AppDatabase.getActiveTimers();

    final config = {
      'version': '2.6',
      'exported_at': DateTime.now().toIso8601String(),
      'devices': devices.map((d) => d.toMap()).toList(),
      'rooms': rooms.map((r) => r.toMap()).toList(),
      'scenes': scenes.map((s) => s.toMap()).toList(),
      'timers': timers.map((t) => {
        'id': t.id,
        'deviceId': t.deviceId,
        'deviceName': t.deviceName,
        'command': t.command,
        'executeAt': t.executeAt.toIso8601String(),
        'executed': t.executed,
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(config);
  }

  /// Восстанавливаем данные из JSON
  static Future<void> _restoreFromJson(String jsonString) async {
    final config = jsonDecode(jsonString) as Map<String, dynamic>;

    // Восстанавливаем комнаты
    if (config['rooms'] != null) {
      for (final room in config['rooms']) {
        await AppDatabase.insertRoom(RoomEntity.fromMap(room));
      }
    }

    // Восстанавливаем устройства
    if (config['devices'] != null) {
      for (final device in config['devices']) {
        await AppDatabase.insertDevice(DeviceEntity.fromMap(device));
      }
    }

    // Восстанавливаем сцены
    if (config['scenes'] != null) {
      for (final scene in config['scenes']) {
        await AppDatabase.insertScene(SceneEntity.fromMap(scene));
      }
    }

    // Восстанавливаем таймеры
    if (config['timers'] != null) {
      for (final timer in config['timers']) {
        await AppDatabase.insertTimer(DeviceTimer(
          id: timer['id'],
          deviceId: timer['deviceId'],
          deviceName: timer['deviceName'],
          command: timer['command'],
          executeAt: DateTime.parse(timer['executeAt']),
          executed: timer['executed'] == true,
        ));
      }
    }
  }
}