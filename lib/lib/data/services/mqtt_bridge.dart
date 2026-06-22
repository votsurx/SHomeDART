/// MQTT мост для приёма событий от LegionNVR
/// Подписывается на топики spartan/+/motion и spartan/+/status
library;

import 'dart:async';
import 'dart:convert';
import 'package:talker/talker.dart';
import '../../domain/services/mqtt_service_interface.dart';
import '../../domain/models/nvr_models.dart';
import '../local/database.dart';
import '../local/entities/event_entity.dart';

class MqttBridge {
  final MqttService _mqttService;
  final Talker _talker;

  /// Колбэк при получении события движения
  void Function(NvrMqttEvent event)? onMotionEvent;

  /// Колбэк при получении статуса камеры
  void Function(int cameraId, bool isOnline)? onStatusEvent;

  /// Колбэк при получении события записи
  void Function(int cameraId, bool isRecording)? onRecordingEvent;

  StreamSubscription<MqttMessageData>? _subscription;
  bool _isRunning = false;

  MqttBridge({
    required MqttService mqttService,
    required Talker talker,
  })  : _mqttService = mqttService,
        _talker = talker;

  /// Запустить MQTT мост
  Future<void> start() async {
    if (_isRunning) return;

    try {
      // Подписываемся на топики LegionNVR
      await _mqttService.subscribe('spartan/+/motion');
      await _mqttService.subscribe('spartan/+/status');
      await _mqttService.subscribe('spartan/+/recording');
      await _mqttService.subscribe('spartan/+/error');

      // Слушаем сообщения
      _subscription = _mqttService.messageStream.listen(
        _handleMessage,
        onError: (error) {
          _talker.error('❌ MQTT Bridge error', error);
        },
      );

      _isRunning = true;
      _talker.info('📡 MQTT Bridge started (listening: spartan/+/motion, spartan/+/status)');
    } catch (e) {
      _talker.error('❌ Failed to start MQTT Bridge', e);
      rethrow;
    }
  }

  /// Остановить MQTT мост
  void stop() {
    _subscription?.cancel();
    _isRunning = false;
    _talker.info('📡 MQTT Bridge stopped');
  }

  // ============================================================
  // ОБРАБОТКА СООБЩЕНИЙ
  // ============================================================

  void _handleMessage(MqttMessageData msg) {
    try {
      final topic = msg.topic;

      if (topic.endsWith('/motion')) {
        _handleMotion(msg);
      } else if (topic.endsWith('/status')) {
        _handleStatus(msg);
      } else if (topic.endsWith('/recording')) {
        _handleRecording(msg);
      } else if (topic.endsWith('/error')) {
        _handleError(msg);
      }
    } catch (e) {
      _talker.error('❌ Error handling MQTT message', e);
    }
  }

  // ============================================================
  // 📨 ОБРАБОТКА ДВИЖЕНИЯ
  // ============================================================

  void _handleMotion(MqttMessageData msg) {
    final event = NvrMqttEvent.fromMqtt(msg.topic, msg.payload);

    _talker.info(
      '🔴 MOTION: ${event.cameraName} → ${event.event} (${event.percent?.toStringAsFixed(1)}%)',
    );

    // Сохраняем в БД
    _saveEventToDb(event);

    // Вызываем колбэк для UI
    onMotionEvent?.call(event);
  }

  // ============================================================
  // 📡 ОБРАБОТКА СТАТУСА
  // ============================================================

  void _handleStatus(MqttMessageData msg) {
    try {
      final data = jsonDecode(msg.payload) as Map<String, dynamic>;
      final cameraId = data['camera_id'] as int? ?? 0;
      final status = data['status'] as String? ?? 'offline';
      final isOnline = status == 'online';

      _talker.debug('📡 Camera $cameraId is ${isOnline ? "ONLINE" : "OFFLINE"}');

      onStatusEvent?.call(cameraId, isOnline);
    } catch (e) {
      _talker.error('❌ Error handling status', e);
    }
  }

  // ============================================================
  // 📼 ОБРАБОТКА ЗАПИСИ
  // ============================================================

  void _handleRecording(MqttMessageData msg) {
    try {
      final data = jsonDecode(msg.payload) as Map<String, dynamic>;
      final cameraId = data['camera_id'] as int? ?? 0;
      final isRecording = data['recording'] as bool? ?? false;

      _talker.debug('📼 Camera $cameraId recording: ${isRecording ? "ON" : "OFF"}');

      onRecordingEvent?.call(cameraId, isRecording);
    } catch (e) {
      _talker.error('❌ Error handling recording', e);
    }
  }

  // ============================================================
  // ⚠️ ОБРАБОТКА ОШИБОК
  // ============================================================

  void _handleError(MqttMessageData msg) {
    try {
      final data = jsonDecode(msg.payload) as Map<String, dynamic>;
      final cameraId = data['camera_id'] as int? ?? 0;
      final error = data['error'] as String? ?? 'Unknown error';

      _talker.error('⚠️ Camera $cameraId error: $error');

      // Сохраняем в БД как событие
      final event = EventEntity(
        event: 'error',
        deviceId: 'nvr_$cameraId',
        deviceName: 'Camera $cameraId',
        value: error,
        timestamp: DateTime.now().toIso8601String(),
      );
      AppDatabase.insertEvent(event);
    } catch (e) {
      _talker.error('❌ Error handling error', e);
    }
  }

  // ============================================================
  // 💾 СОХРАНЕНИЕ В БД
  // ============================================================

  Future<void> _saveEventToDb(NvrMqttEvent event) async {
    try {
      final eventType = event.isMotionStart
          ? 'motion_start'
          : event.isMotionEnd
          ? 'motion_end'
          : event.event;

      final entity = EventEntity(
        event: eventType,
        deviceId: 'nvr_${event.cameraId}',
        deviceName: event.cameraName,
        value: event.percent?.toStringAsFixed(1) ?? '',
        timestamp: event.timestamp.toIso8601String(),
      );

      await AppDatabase.insertEvent(entity);
    } catch (e) {
      _talker.error('❌ Failed to save event to DB', e);
    }
  }

  /// Проверяет, запущен ли мост
  bool get isRunning => _isRunning;
}