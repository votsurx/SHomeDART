import 'package:freezed_annotation/freezed_annotation.dart';

part 'curtain_device.freezed.dart';
part 'curtain_device.g.dart';

@freezed
class CurtainDevice with _$CurtainDevice {
  const factory CurtainDevice({
    required String id,
    required String name,
    required int position, // 0-100 (% открытия)
    required bool isMoving,
    required String deviceId,
    required String localKey,
    required String address,
    required double version,
  }) = _CurtainDevice;

  factory CurtainDevice.fromJson(Map<String, dynamic> json) => _$CurtainDeviceFromJson(json);
}