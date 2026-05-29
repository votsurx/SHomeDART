// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceImpl _$$DeviceImplFromJson(Map<String, dynamic> json) => _$DeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$DeviceTypeEnumMap, json['type']),
      roomId: json['roomId'] as String,
      isOnline: json['isOnline'] as bool,
      state: $enumDecode(_$DeviceStateEnumMap, json['state']),
      properties: json['properties'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$DeviceImplToJson(_$DeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$DeviceTypeEnumMap[instance.type]!,
      'roomId': instance.roomId,
      'isOnline': instance.isOnline,
      'state': _$DeviceStateEnumMap[instance.state]!,
      'properties': instance.properties,
    };

const _$DeviceTypeEnumMap = {
  DeviceType.switch1: 'switch1',
  DeviceType.switch2: 'switch2',
  DeviceType.switch3: 'switch3',
  DeviceType.sensor: 'sensor',
  DeviceType.curtain: 'curtain',
  DeviceType.hvac: 'hvac',
  DeviceType.camera: 'camera',
};

const _$DeviceStateEnumMap = {
  DeviceState.online: 'online',
  DeviceState.offline: 'offline',
  DeviceState.pending: 'pending',
  DeviceState.error: 'error',
};
