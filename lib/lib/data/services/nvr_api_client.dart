/// REST API клиент для LegionNVR
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/nvr_models.dart';

class NvrApiClient {
  final String _host;
  final int _port;
  final http.Client _client;
  final Duration _timeout;

  NvrApiClient({
    required String host,
    int port = 8080,
    http.Client? client,
    Duration timeout = const Duration(seconds: 5),
  })  : _host = host,
        _port = port,
        _client = client ?? http.Client(),
        _timeout = timeout;

  // ✅ ДОБАВЛЯЕМ ПУБЛИЧНЫЙ ГЕТТЕР
  String get host => _host;
  int get port => _port;

  String get _baseUrl => 'http://$_host:$_port';

  // ============================================================
  // 🏥 HEALTH CHECK
  // ============================================================

  Future<bool> isAlive() async {
    try {
      final response = await _client
          .get(
        Uri.parse('$_baseUrl/api/health'),
      )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // 📷 CAMERAS
  // ============================================================

  /// Получить список всех камер
  Future<List<NvrCamera>> getCameras() async {
    final response = await _client
        .get(
      Uri.parse('$_baseUrl/api/cameras'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load cameras: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final cameras = data['cameras'] as List? ?? [];

    return cameras.map((c) => NvrCamera.fromJson(c as Map<String, dynamic>)).toList();
  }

  /// Получить детали одной камеры
  Future<NvrCamera> getCamera(int id) async {
    final response = await _client
        .get(
      Uri.parse('$_baseUrl/api/cameras/$id'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load camera: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return NvrCamera.fromJson(data['camera'] as Map<String, dynamic>);
  }

  /// Обновить камеру (частичное обновление)
  Future<void> updateCamera(int id, Map<String, dynamic> data) async {
    final response = await _client
        .put(
      Uri.parse('$_baseUrl/api/cameras/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to update camera: ${response.statusCode}');
    }
  }

  /// Применить настройки (перезагрузить конфиг)
  Future<void> applyCamera(int id) async {
    final response = await _client
        .post(
      Uri.parse('$_baseUrl/api/cameras/$id/apply'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to apply camera config: ${response.statusCode}');
    }
  }

  /// Удалить камеру
  Future<void> deleteCamera(int id) async {
    final response = await _client
        .delete(
      Uri.parse('$_baseUrl/api/cameras/$id'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete camera: ${response.statusCode}');
    }
  }

  /// Перезапустить все стримы
  Future<void> restartStreams() async {
    final response = await _client
        .post(
      Uri.parse('$_baseUrl/api/streams/restart'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to restart streams: ${response.statusCode}');
    }
  }

  // ============================================================
  // 📼 RECORDINGS
  // ============================================================

  /// Получить список записей с фильтрацией
  Future<List<NvrRecording>> getRecordings({
    int? cameraId,
    String? date,
    int limit = 100,
  }) async {
    final params = <String, String>{};
    if (cameraId != null) params['camera_id'] = cameraId.toString();
    if (date != null) params['date'] = date;
    params['limit'] = limit.toString();

    final uri = Uri.parse('$_baseUrl/api/recordings').replace(queryParameters: params);

    final response = await _client.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load recordings: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final recordings = data['recordings'] as List? ?? [];

    return recordings.map((r) => NvrRecording.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Удалить запись
  Future<void> deleteRecording(int id) async {
    final response = await _client
        .delete(
      Uri.parse('$_baseUrl/api/recordings/$id'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recording: ${response.statusCode}');
    }
  }

  /// Массовое удаление записей
  Future<void> deleteRecordingsBulk({
    int? cameraId,
    String? date,
    String? dateBefore,
    bool all = false,
  }) async {
    final params = <String, String>{};
    if (cameraId != null) params['camera_id'] = cameraId.toString();
    if (date != null) params['date'] = date;
    if (dateBefore != null) params['date_before'] = dateBefore;
    if (all) params['all'] = 'true';

    final uri = Uri.parse('$_baseUrl/api/recordings').replace(queryParameters: params);

    final response = await _client.delete(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recordings: ${response.statusCode}');
    }
  }

  // ============================================================
  // 🎯 ZONES
  // ============================================================

  /// Получить зоны детекции для камеры
  Future<List<NvrZone>> getZones(int cameraId) async {
    final response = await _client
        .get(
      Uri.parse('$_baseUrl/api/cameras/$cameraId/zones'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load zones: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final zones = data['zones'] as List? ?? [];

    return zones.map((z) => NvrZone.fromJson(z as Map<String, dynamic>)).toList();
  }

  /// Сохранить зону
  Future<void> saveZone(
      int cameraId, {
        String? id,
        required String name,
        required String zoneType,
        required List<NvrPoint> points,
        bool enabled = true,
      }) async {
    final body = {
      'name': name,
      'zone_type': zoneType,
      'points_json': jsonEncode(points.map((p) => p.toJson()).toList()),
      'enabled': enabled ? 1 : 0,
    };

    if (id != null) {
      body['id'] = int.parse(id);
    }

    final response = await _client
        .post(
      Uri.parse('$_baseUrl/api/cameras/$cameraId/zones'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to save zone: ${response.statusCode}');
    }
  }

  /// Удалить зону
  Future<void> deleteZone(int cameraId, int zoneId) async {
    final response = await _client
        .delete(
      Uri.parse('$_baseUrl/api/cameras/$cameraId/zones/$zoneId'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete zone: ${response.statusCode}');
    }
  }

  // ============================================================
  // 📡 MQTT SETTINGS
  // ============================================================

  /// Получить MQTT настройки
  Future<Map<String, dynamic>> getMqttSettings() async {
    final response = await _client
        .get(
      Uri.parse('$_baseUrl/api/settings/mqtt'),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load MQTT settings: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['config'] as Map<String, dynamic>? ?? {};
  }

  /// Обновить MQTT настройки
  Future<void> updateMqttSettings({
    required String broker,
    required int port,
    String username = '',
    String password = '',
  }) async {
    final response = await _client
        .post(
      Uri.parse('$_baseUrl/api/settings/mqtt'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'broker': broker,
        'port': port,
        'username': username,
        'password': password,
      }),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to update MQTT settings: ${response.statusCode}');
    }
  }

  // ============================================================
  // 🖼️ STREAM URLS
  // ============================================================

  String getMjpegUrl(int cameraId) {
    return '$_baseUrl/camera/$cameraId/mjpeg';
  }

  String getHlsUrl(int cameraId) {
    return '$_baseUrl/camera/$cameraId/stream.m3u8';
  }
}