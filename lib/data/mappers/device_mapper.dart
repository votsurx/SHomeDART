// lib/data/mappers/device_mapper.dart
import 'dart:convert';
import '../../domain/models/device.dart';
import '../local/entities/device_entity.dart';

class DeviceMapper {
  static Device toDomain(DeviceEntity entity) {
    return Device(
      id: entity.id,
      name: entity.name,
      type: DeviceType.values.firstWhere((t) => t.name == entity.type),
      roomId: entity.roomId,
      isOnline: entity.isOnline == 1,
      state: DeviceState.values.firstWhere((s) => s.name == entity.state),
      deviceId: entity.deviceId,
      localKey: entity.localKey,
      address: entity.address,
      version: entity.version,
      dpsIndex: entity.dpsIndex,
      properties: Map<String, dynamic>.from(jsonDecode(entity.properties)),
    );
  }

  static DeviceEntity toEntity(Device device) {
    return DeviceEntity(
      id: device.id,
      name: device.name,
      type: device.type.name,
      roomId: device.roomId,
      isOnline: device.isOnline ? 1 : 0,
      state: device.state.name,
      deviceId: device.deviceId,
      localKey: device.localKey,
      address: device.address,
      version: device.version,
      dpsIndex: device.dpsIndex,
      properties: jsonEncode(device.properties),
    );
  }
}