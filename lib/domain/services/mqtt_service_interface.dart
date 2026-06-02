import 'dart:async';

abstract class MqttService {
  Future<void> connect(String broker, {int port = 1883});
  Future<void> disconnect();
  Future<void> subscribe(String topic);
  Future<void> publish(String topic, String message);
  Stream<MqttMessageData> get messageStream;
  bool get isConnected;
}

class MqttMessageData {
  final String topic;
  final String payload;
  final DateTime timestamp;

  MqttMessageData({
    required this.topic,
    required this.payload,
  }) : timestamp = DateTime.now();
}