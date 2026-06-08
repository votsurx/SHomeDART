/// Сервис для приёма тревог от Frigate через MQTT.
/// Подписывается на топики shome/camera/+/alarm,
/// сохраняет события в БД и отправляет уведомления.
library;

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../local/database.dart';
import '../local/entities/event_entity.dart';
import '../../domain/services/mqtt_service_interface.dart';

class FrigateAlarmService {
  final MqttService _mqttService;
  StreamSubscription<MqttMessageData>? _subscription;

  /// Колбэк при новой тревоге (для UI-уведомлений)
  void Function(FrigateAlarm alarm)? onAlarm;

  FrigateAlarmService(this._mqttService);

  /// Запускает подписку на топики тревог Frigate.
  Future<void> start() async {
    // Подписываемся на все камеры
    await _mqttService.subscribe('shome/camera/+/alarm');

    _subscription = _mqttService.messageStream.listen((msg) {
      if (msg.topic.startsWith('shome/camera/') && msg.topic.endsWith('/alarm')) {
        _handleAlarm(msg);
      }
    });

    debugPrint('🔔 FrigateAlarmService started');
  }

  void _handleAlarm(MqttMessageData msg) {
    try {
      final cameraId = msg.topic.split('/')[2];
      final data = jsonDecode(msg.payload) as Map<String, dynamic>;

      final alarm = FrigateAlarm(
        cameraId: cameraId,
        label: data['label'] as String? ?? 'motion',
        score: (data['score'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
      );

      debugPrint('🚨 Тревога! ${alarm.cameraId}: ${alarm.label} (${(alarm.score * 100).round()}%)');

      // Сохраняем в БД
      _saveToDb(alarm);

      // Вызываем колбэк для UI
      onAlarm?.call(alarm);
    } catch (e) {
      debugPrint('❌ Ошибка обработки тревоги: $e');
    }
  }

  Future<void> _saveToDb(FrigateAlarm alarm) async {
    try {
      await AppDatabase.insertEvent(EventEntity(
        event: 'alarm_${alarm.label}',
        deviceId: alarm.cameraId,
        deviceName: 'Камера ${alarm.cameraId}',
        value: '${(alarm.score * 100).round()}%',
        timestamp: alarm.timestamp.toIso8601String(),
      ));
    } catch (_) {}
  }

  /// Останавливает подписку.
  void stop() {
    _subscription?.cancel();
  }
}

/// Модель тревоги от Frigate.
class FrigateAlarm {
  final String cameraId;
  final String label;   // person, car, cat, dog...
  final double score;   // 0.0 - 1.0
  final DateTime timestamp;

  FrigateAlarm({
    required this.cameraId,
    required this.label,
    required this.score,
    required this.timestamp,
  });
}