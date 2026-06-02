import 'package:freezed_annotation/freezed_annotation.dart';

part 'hvac_device.freezed.dart';
part 'hvac_device.g.dart';

@freezed
class HvacDevice with _$HvacDevice {
  const factory HvacDevice({
    required String id,
    required String name,
    required bool isOn,
    required double temperature, // Текущая температура
    required double targetTemp,  // Целевая температура
    required HvacMode mode,      // Режим работы
    required int fanSpeed,       // Скорость вентилятора (1-5)
    required String deviceId,
    required String localKey,
    required String address,
    required double version,
  }) = _HvacDevice;

  factory HvacDevice.fromJson(Map<String, dynamic> json) => _$HvacDeviceFromJson(json);
}

enum HvacMode {
  auto,
  cool,
  heat,
  dry,
  fan,
}