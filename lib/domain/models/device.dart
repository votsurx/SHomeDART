import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
class Device with _$Device {
  const factory Device({
    required String id,
    required String name,
    required DeviceType type,
    required String roomId,
    required bool isOnline,
    required DeviceState state,
    @Default({}) Map<String, dynamic> properties,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}

enum DeviceType {
  switch1,
  switch2,
  switch3,
  sensor,
  curtain,
  hvac,
  camera
}

enum DeviceState {
  online,
  offline,
  pending,
  error
}