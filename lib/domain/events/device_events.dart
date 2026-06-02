import '../models/device.dart';

sealed class DeviceEvent {
  final String deviceId;
  final DateTime timestamp;

  DeviceEvent(this.deviceId) : timestamp = DateTime.now();
}

class DeviceStateChanged extends DeviceEvent {
  final DeviceState newState;
  DeviceStateChanged(String deviceId, this.newState) : super(deviceId);
}

class DeviceTelemetryReceived extends DeviceEvent {
  final Map<String, dynamic> data;
  DeviceTelemetryReceived(String deviceId, this.data) : super(deviceId);
}

class DeviceOffline extends DeviceEvent {
  DeviceOffline(String deviceId) : super(deviceId);
}

class DeviceOnline extends DeviceEvent {
  DeviceOnline(String deviceId) : super(deviceId);
}