import 'dart:async';
import 'device_events.dart';

class DeviceEventBus {
  static final DeviceEventBus _instance = DeviceEventBus._();
  factory DeviceEventBus() => _instance;
  DeviceEventBus._();

  final _controller = StreamController<DeviceEvent>.broadcast();
  Stream<DeviceEvent> get stream => _controller.stream;

  void fire(DeviceEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}