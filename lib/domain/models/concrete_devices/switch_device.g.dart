// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SwitchDeviceImpl _$$SwitchDeviceImplFromJson(Map<String, dynamic> json) =>
    _$SwitchDeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      channels: (json['channels'] as num).toInt(),
      states: (json['states'] as List<dynamic>).map((e) => e as bool).toList(),
      deviceId: json['deviceId'] as String,
      localKey: json['localKey'] as String,
      address: json['address'] as String,
      version: (json['version'] as num).toDouble(),
    );

Map<String, dynamic> _$$SwitchDeviceImplToJson(_$SwitchDeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'channels': instance.channels,
      'states': instance.states,
      'deviceId': instance.deviceId,
      'localKey': instance.localKey,
      'address': instance.address,
      'version': instance.version,
    };
