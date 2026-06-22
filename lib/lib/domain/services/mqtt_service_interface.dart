/// Интерфейс MQTT сервиса для работы с LegionNVR
library;

import 'dart:async';

abstract class MqttService {
  /// Подключается к MQTT брокеру
  Future<void> connect(String broker, {int port = 1883});

  /// Отключается от брокера
  Future<void> disconnect();

  /// Подписывается на топик
  Future<void> subscribe(String topic);

  /// Публикует сообщение
  Future<void> publish(String topic, String message);

  /// Поток входящих сообщений
  Stream<MqttMessageData> get messageStream;

  /// Проверяет, подключён ли клиент
  bool get isConnected;
}

/// Данные входящего MQTT сообщения
class MqttMessageData {
  final String topic;
  final String payload;
  final DateTime timestamp;

  MqttMessageData({
    required this.topic,
    required this.payload,
  }) : timestamp = DateTime.now();
}