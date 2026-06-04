/// Сервис экспорта/импорта конфигурации.
/// Экспорт: собирает все данные из БД в JSON, сохраняет в Downloads, шарит через Share.
/// Импорт: читает JSON через FilePicker, восстанавливает все таблицы БД.
/// Требует разрешения на запись (Permission.storage).
library;
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
//import 'package:permission_handler/permission_handler.dart';

class ConfigService {
  /// Экспортирует конфигурацию в JSON-файл и открывает системный диалог "Поделиться".
  /// Запрашивает разрешение на запись файлов.
  /// Сохраняет файл в папку Downloads как shome_backup.json.
  static Future<void> exportConfig() async {
    final config = await _buildConfigJson();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/shome_backup.json');
    await file.writeAsString(config);

    print('File saved to: ${file.path}');
    print('File exists: ${await file.exists()}');
    print('File size: ${await file.length()} bytes');

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Резервная копия SHome',
    );
  }
  /// Быстрый импорт из папки приложения (без выбора файла)
  static Future<void> quickImport() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/shome_backup.json');

    print('Looking for file at: ${file.path}');
    print('File exists: ${await file.exists()}');

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      await _restoreFromJson(jsonString);
    } else {
      throw Exception('Файл резервной копии не найден в папке приложения');
    }
  }

  /// Импортирует конфигурацию из выбранного пользователем JSON-файла.
  /// Открывает FilePicker для выбора файла.
  /// Восстанавливает комнаты, устройства, сцены и таймеры.
  static Future<void> importConfig() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      await _restoreFromJson(jsonString);
    }
  }

  /// Собирает все данные из БД и формирует JSON-строку с отступами.
  /// Включает: устройства, комнаты, сцены, активные таймеры.
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

  /// Восстанавливает все данные из JSON-строки.
  /// Последовательно вставляет комнаты, устройства, сцены, таймеры.
  static Future<void> _restoreFromJson(String jsonString) async {
    final config = jsonDecode(jsonString) as Map<String, dynamic>;

    // Порядок важен: сначала комнаты, потом устройства (ссылаются на комнаты)
    if (config['rooms'] != null) {
      for (final room in config['rooms']) {
        await AppDatabase.insertRoom(RoomEntity.fromMap(room));
      }
    }

    if (config['devices'] != null) {
      for (final device in config['devices']) {
        await AppDatabase.insertDevice(DeviceEntity.fromMap(device));
      }
    }

    if (config['scenes'] != null) {
      for (final scene in config['scenes']) {
        await AppDatabase.insertScene(SceneEntity.fromMap(scene));
      }
    }

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