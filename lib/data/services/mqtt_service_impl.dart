import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:talker/talker.dart';
import '../../domain/services/mqtt_service_interface.dart';

class MqttServiceImpl implements MqttService {
  final Talker _talker;
  MqttServerClient? _client;
  final _messageController = StreamController<MqttMessageData>.broadcast();

  MqttServiceImpl(this._talker);

  @override
  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  @override
  Stream<MqttMessageData> get messageStream => _messageController.stream;

  @override
  Future<void> connect(String broker, {int port = 1883}) async {
    try {
      _talker.info('Connecting to MQTT broker: $broker:$port');

      _client = MqttServerClient(broker, 'shome_client');
      _client!.port = port;
      _client!.keepAlivePeriod = 20;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('shome_flutter_${DateTime.now().millisecondsSinceEpoch}')
          .startClean();

      _client!.connectionMessage = connMessage;

      await _client!.connect();

      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
        for (final msg in messages) {
          final recMessage = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

          final mqttMessage = MqttMessageData(
            topic: msg.topic,
            payload: payload,
          );
          _talker.debug('MQTT received: ${msg.topic} = $payload');
          _messageController.add(mqttMessage);
        }
      });

      _talker.info('Connected to MQTT broker');
    } catch (e, stackTrace) {
      _talker.error('Failed to connect to MQTT broker', e, stackTrace);
    }
  }

  @override
  Future<void> disconnect() async {
    _client?.disconnect();
  }

  @override
  Future<void> subscribe(String topic) async {
    if (_client != null && isConnected) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
      _talker.info('Subscribed to topic: $topic');
    }
  }

  @override
  Future<void> publish(String topic, String message) async {
    if (_client != null && isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
  }
}