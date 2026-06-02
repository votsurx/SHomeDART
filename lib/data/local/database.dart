import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'entities/device_entity.dart';
import 'entities/room_entity.dart';
import 'entities/scene_entity.dart';
import 'entities/event_entity.dart';
import '../../domain/models/device_timer.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shome.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE timers (
            id TEXT PRIMARY KEY,
            deviceId TEXT NOT NULL,
            deviceName TEXT NOT NULL,
            command TEXT NOT NULL,
            executeAt TEXT NOT NULL,
            executed INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deviceId TEXT NOT NULL,
            deviceName TEXT NOT NULL,
            event TEXT NOT NULL,
            sceneName TEXT,
            timestamp TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE devices (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            roomId TEXT NOT NULL,
            isOnline INTEGER NOT NULL,
            state TEXT NOT NULL,
            deviceId TEXT,
            localKey TEXT,
            address TEXT,
            version REAL,
            dpsIndex INTEGER,
            properties TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE rooms (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT,
            sortOrder INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE scenes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            actions TEXT NOT NULL,
            triggerType TEXT,
            triggerTime TEXT,
            triggerRepeat TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE devices ADD COLUMN dpsIndex INTEGER');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE scenes (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              icon TEXT NOT NULL,
              actions TEXT NOT NULL,
              triggerType TEXT,
              triggerTime TEXT,
              triggerRepeat TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE events (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              deviceId TEXT NOT NULL,
              deviceName TEXT NOT NULL,
              event TEXT NOT NULL,
              sceneName TEXT,
              timestamp TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  //Events
  static Future<void> insertEvent(EventEntity event) async {
    final db = await database;
    await db.insert('events', event.toMap());
  }

  static Future<List<EventEntity>> getRecentEvents({int limit = 100}) async {
    final db = await database;
    final maps = await db.query('events', orderBy: 'id DESC', limit: limit);
    return maps.map((m) => EventEntity.fromMap(m)).toList();
  }

  static Future<void> clearEvents() async {
    final db = await database;
    await db.delete('events');
  }

  // Device CRUD
  static Future<List<DeviceEntity>> getAllDevices() async {
    final db = await database;
    final maps = await db.query('devices');
    return maps.map((map) => DeviceEntity.fromMap(map)).toList();
  }

  static Future<void> insertDevice(DeviceEntity device) async {
    final db = await database;
    await db.insert('devices', device.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateDevice(DeviceEntity device) async {
    final db = await database;
    await db.update('devices', device.toMap(), where: 'id = ?', whereArgs: [device.id]);
  }

  static Future<void> deleteDevice(String id) async {
    final db = await database;
    await db.delete('devices', where: 'id = ?', whereArgs: [id]);
  }

  // Room CRUD
  static Future<List<RoomEntity>> getAllRooms() async {
    final db = await database;
    final maps = await db.query('rooms', orderBy: 'sortOrder');
    return maps.map((map) => RoomEntity.fromMap(map)).toList();
  }

  static Future<void> insertRoom(RoomEntity room) async {
    final db = await database;
    await db.insert('rooms', room.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteRoom(String id) async {
    final db = await database;
    await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }

  // Scene CRUD
  static Future<List<SceneEntity>> getAllScenes() async {
    final db = await database;
    final maps = await db.query('scenes');
    return maps.map((map) => SceneEntity.fromMap(map)).toList();
  }

  static Future<void> insertScene(SceneEntity scene) async {
    final db = await database;
    await db.insert('scenes', scene.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteScene(String id) async {
    final db = await database;
    await db.delete('scenes', where: 'id = ?', whereArgs: [id]);
  }

  // timers
  static Future<void> insertTimer(DeviceTimer timer) async {
    final db = await database;
    await db.insert('timers', {
      'id': timer.id,
      'deviceId': timer.deviceId,
      'deviceName': timer.deviceName,
      'command': timer.command,
      'executeAt': timer.executeAt.toIso8601String(),
      'executed': timer.executed ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<DeviceTimer>> getActiveTimers() async {
    final db = await database;
    final maps = await db.query('timers', where: 'executed = 0', orderBy: 'executeAt ASC');
    return maps.map((m) => DeviceTimer(
      id: m['id'] as String,
      deviceId: m['deviceId'] as String,
      deviceName: m['deviceName'] as String,
      command: m['command'] as String,
      executeAt: DateTime.parse(m['executeAt'] as String),
      executed: (m['executed'] as int) == 1,
    )).toList();
  }

  static Future<void> markTimerExecuted(String id) async {
    final db = await database;
    await db.update('timers', {'executed': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteTimer(String id) async {
    final db = await database;
    await db.delete('timers', where: 'id = ?', whereArgs: [id]);
  }
}