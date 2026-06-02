// lib/data/local/entities/device_entity.dart
class DeviceEntity {
  final String id;
  final String name;
  final String type;
  final String roomId;
  final int isOnline;
  final String state;
  final String? deviceId;
  final String? localKey;
  final String? address;
  final double? version;
  final int? dpsIndex;
  final String properties; // JSON строка

  DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.roomId,
    required this.isOnline,
    required this.state,
    this.deviceId,
    this.localKey,
    this.address,
    this.version,
    this.dpsIndex,
    required this.properties,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'roomId': roomId,
      'isOnline': isOnline,
      'state': state,
      'deviceId': deviceId,
      'localKey': localKey,
      'address': address,
      'version': version,
      'dpsIndex': dpsIndex,
      'properties': properties,
    };
  }

  factory DeviceEntity.fromMap(Map<String, dynamic> map) {
    return DeviceEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      roomId: map['roomId'] as String,
      isOnline: map['isOnline'] as int,
      state: map['state'] as String,
      deviceId: map['deviceId'] as String?,
      localKey: map['localKey'] as String?,
      address: map['address'] as String?,
      version: map['version'] as double?,
      dpsIndex: map['dpsIndex'] as int?,
      properties: map['properties'] as String,
    );
  }
}