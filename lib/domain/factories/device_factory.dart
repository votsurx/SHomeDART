import '../models/device.dart';

class DeviceFactory {
  /// Создать устройство нужного типа
  static Device createDevice({
    required String id,
    required String name,
    required DeviceType type,
    required String roomId,
    required String deviceId,
    required String localKey,
    required String address,
    double version = 3.5,
    Map<String, dynamic>? properties,
  }) {
    // Базовые свойства для каждого типа
    final defaultProperties = _getDefaultProperties(type);
    final allProperties = {...defaultProperties, ...?properties};

    return Device(
      id: id,
      name: name,
      type: type,
      roomId: roomId,
      isOnline: false,
      state: DeviceState.offline,
      deviceId: deviceId,
      localKey: localKey,
      address: address,
      version: version,
      properties: allProperties,
    );
  }

  static Map<String, dynamic> _getDefaultProperties(DeviceType type) {
    switch (type) {
      case DeviceType.switch1:
        return {'channels': 1, 'states': [false]};
      case DeviceType.switch2:
        return {'channels': 2, 'states': [false, false]};
      case DeviceType.switch3:
        return {'channels': 3, 'states': [false, false, false]};
      case DeviceType.curtain:
        return {'position': 100, 'isMoving': false};
      case DeviceType.hvac:
        return {
          'isOn': false,
          'temperature': 22,
          'targetTemp': 24,
          'mode': 'auto',
          'fanSpeed': 1,
        };
      case DeviceType.light:
        return {'brightness': 255, 'isOn': false};
      default:
        return {'isOn': false};
    }
  }
}