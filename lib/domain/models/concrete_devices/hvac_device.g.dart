// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hvac_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HvacDeviceImpl _$$HvacDeviceImplFromJson(Map<String, dynamic> json) =>
    _$HvacDeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      isOn: json['isOn'] as bool,
      temperature: (json['temperature'] as num).toDouble(),
      targetTemp: (json['targetTemp'] as num).toDouble(),
      mode: $enumDecode(_$HvacModeEnumMap, json['mode']),
      fanSpeed: (json['fanSpeed'] as num).toInt(),
      deviceId: json['deviceId'] as String,
      localKey: json['localKey'] as String,
      address: json['address'] as String,
      version: (json['version'] as num).toDouble(),
    );

Map<String, dynamic> _$$HvacDeviceImplToJson(_$HvacDeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isOn': instance.isOn,
      'temperature': instance.temperature,
      'targetTemp': instance.targetTemp,
      'mode': _$HvacModeEnumMap[instance.mode]!,
      'fanSpeed': instance.fanSpeed,
      'deviceId': instance.deviceId,
      'localKey': instance.localKey,
      'address': instance.address,
      'version': instance.version,
    };

const _$HvacModeEnumMap = {
  HvacMode.auto: 'auto',
  HvacMode.cool: 'cool',
  HvacMode.heat: 'heat',
  HvacMode.dry: 'dry',
  HvacMode.fan: 'fan',
};
