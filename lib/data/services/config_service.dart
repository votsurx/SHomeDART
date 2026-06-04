/// Сервис экспорта/импорта/автобекапа конфигурации.
/// Экспорт: собирает все данные из БД в JSON, шарит через Share (пользователь сам выбирает куда сохранить).
/// Импорт: читает JSON через FilePicker (видит Downloads, облака, почту).
/// Автобекап: сохраняет копию локально, можно восстановить без выбора файла.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../local/database.dart';
import '../local/entities/device_entity.dart';
import '../local/entities/room_entity.dart';
import '../local/entities/scene_entity.dart';
import '../../domain/models/device_timer.dart';

class ConfigService {
  static const String _backupFileName = 'auto_backup.json';
  static const String _backupDirName = 'backups';

  // ────────────────────────────────────────────────────────
  // ЭКСПОРТ
  // ────────────────────────────────────────────────────────

  /// Экспорт: собирает JSON, сохраняет локальный бекап и открывает «Поделиться».
  /// Пользователь сам выбирает куда отправить: облако, почта, Telegram.
  static Future<void> exportConfig() async {
    final json = await buildConfigJson();

    // 1. Сохраняем локальный бекап (для кнопки «Восстановить»)
    await _saveLocalBackup(json);

    // 2. Сохраняем во временный файл для шаринга
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/shome_backup_$timestamp.json');
    await file.writeAsString(json);

    // 3. Открываем share sheet
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Резервная копия SHome',
    );
  }

  // ────────────────────────────────────────────────────────
  // ИМПОРТ
  // ────────────────────────────────────────────────────────

  /// Импорт через FilePicker (пользователь может выбрать из Downloads, облака, почты).
  static Future<void> importConfig() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return; // пользователь отменил

    final file = File(result.files.single.path!);
    final json = await file.readAsString();
    await restoreFromJson(json);

    // После успешного импорта обновляем локальный бекап
    await _saveLocalBackup(json);
  }

  /// Быстрый импорт из локального бекапа (кнопка «Восстановить»).
  static Future<void> quickImport() async {
    final json = await _loadLocalBackup();

    if (json == null) {
      throw Exception('Локальный бекап не найден. Сделайте импорт из облака.');
    }

    await restoreFromJson(json);
  }

  // ────────────────────────────────────────────────────────
  // ЛОКАЛЬНЫЙ АВТОБЕКАП
  // ────────────────────────────────────────────────────────

  /// Директория для хранения бекапов
  static Future<Directory> get _backupDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/$_backupDirName');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Сохраняет JSON локально (автобекап)
  static Future<void> _saveLocalBackup(String json) async {
    try {
      final dir = await _backupDir;
      final file = File('${dir.path}/$_backupFileName');
      await file.writeAsString(json);
      debugPrint('✅ Локальный бекап сохранён');
    } catch (e) {
      debugPrint('❌ Ошибка сохранения локального бекапа: $e');
    }
  }

  /// Загружает локальный бекап. Возвращает null, если файла нет.
  static Future<String?> _loadLocalBackup() async {
    try {
      final dir = await _backupDir;
      final file = File('${dir.path}/$_backupFileName');

      if (!await file.exists()) return null;

      return await file.readAsString();
    } catch (e) {
      debugPrint('❌ Ошибка загрузки локального бекапа: $e');
      return null;
    }
  }

  /// Есть ли локальный бекап? (для UI)
  static Future<bool> hasLocalBackup() async {
    try {
      final dir = await _backupDir;
      final file = File('${dir.path}/$_backupFileName');
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  /// Дата последнего бекапа (для UI)
  static Future<DateTime?> lastBackupDate() async {
    try {
      final dir = await _backupDir;
      final file = File('${dir.path}/$_backupFileName');
      if (!await file.exists()) return null;
      return await file.lastModified();
    } catch (_) {
      return null;
    }
  }

  /// Автобекап с ротацией (сохраняет последние 3 копии)
  static Future<void> autoBackup() async {
    try {
      final json = await buildConfigJson();
      final dir = await _backupDir;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newBackup = File('${dir.path}/backup_$timestamp.json');
      await newBackup.writeAsString(json);

      // Ротация: оставляем только 3 последних
      final files = await dir.list().toList();
      final backups = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));

      if (backups.length > 3) {
        for (final old in backups.skip(3)) {
          await old.delete();
        }
      }

      // Обновляем основной auto_backup.json
      await _saveLocalBackup(json);

      debugPrint('✅ Автобекап выполнен (${backups.length} копий)');
    } catch (e) {
      debugPrint('❌ Ошибка автобекапа: $e');
    }
  }

  // ────────────────────────────────────────────────────────
  // СБОРКА / ВОССТАНОВЛЕНИЕ JSON
  // ────────────────────────────────────────────────────────

  /// Собирает все данные из БД в JSON-строку.
  /// Публичный — используется CloudSettingsScreen для загрузки в облако.
  static Future<String> buildConfigJson() async {
    final devices = await AppDatabase.getAllDevices();
    final rooms = await AppDatabase.getAllRooms();
    final scenes = await AppDatabase.getAllScenes();
    final timers = await AppDatabase.getActiveTimers();

    final config = {
      'version': '2.11',
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
  /// Публичный — используется CloudSettingsScreen при скачивании из облака.
  static Future<void> restoreFromJson(String jsonString) async {
    final config = jsonDecode(jsonString) as Map<String, dynamic>;

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