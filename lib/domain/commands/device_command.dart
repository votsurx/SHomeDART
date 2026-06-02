enum DeviceCommandType { turnOn, turnOff, setSwitchChannel, setCurtainPosition, setBrightness }

class DeviceCommand {
  final String id;
  final String deviceId;
  final DeviceCommandType type;
  final Map<String, dynamic>? params;
  final DateTime createdAt;
  int retries;

  DeviceCommand({
    required this.id,
    required this.deviceId,
    required this.type,
    this.params,
    DateTime? createdAt,
    this.retries = 0,
  }) : createdAt = createdAt ?? DateTime.now();
}