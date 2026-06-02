import 'package:freezed_annotation/freezed_annotation.dart';

part 'switch_device.freezed.dart';
part 'switch_device.g.dart';

@freezed
class SwitchDevice with _$SwitchDevice {
  const factory SwitchDevice({
    required String id,
    required String name,
    required int channels, // 1, 2, 3
    required List<bool> states, // Состояние каждого канала
    required String deviceId,
    required String localKey,
    required String address,
    required double version,
  }) = _SwitchDevice;

  factory SwitchDevice.fromJson(Map<String, dynamic> json) => _$SwitchDeviceFromJson(json);
}