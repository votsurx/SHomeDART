// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curtain_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CurtainDeviceImpl _$$CurtainDeviceImplFromJson(Map<String, dynamic> json) =>
    _$CurtainDeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      position: (json['position'] as num).toInt(),
      isMoving: json['isMoving'] as bool,
      deviceId: json['deviceId'] as String,
      localKey: json['localKey'] as String,
      address: json['address'] as String,
      version: (json['version'] as num).toDouble(),
    );

Map<String, dynamic> _$$CurtainDeviceImplToJson(_$CurtainDeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'position': instance.position,
      'isMoving': instance.isMoving,
      'deviceId': instance.deviceId,
      'localKey': instance.localKey,
      'address': instance.address,
      'version': instance.version,
    };
