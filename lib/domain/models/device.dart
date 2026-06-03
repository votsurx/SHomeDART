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
    String? deviceId,
    String? localKey,
    String? address,
    double? version,
    int? dpsIndex,
    // Для датчиков
    String? mqttTopic,
    double? temperature,
    double? humidity,
    bool? motion,
    bool? doorOpen,
    double? battery,
    @Default({}) Map<String, dynamic> properties,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}
enum DeviceType {
  outlet,
  switch1,
  switch2,
  switch3,
  sensor,          // ← Единый тип для всех датчиков!
  curtain,
  hvac,
  light,
  camera,
  button,
}

enum SensorType {
  temperature,
  humidity,
  power,
  current,
  voltage,
  motion,
  door,
}

enum DeviceState {
  online,
  offline,
  pending,
  error
}