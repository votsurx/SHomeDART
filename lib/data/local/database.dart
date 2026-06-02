// lib/data/local/database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'entities/device_entity.dart';
import 'entities/room_entity.dart';

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
      version: 2,
      onCreate: (db, version) async {
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE devices ADD COLUMN dpsIndex INTEGER');
        }
      },
    );
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
}