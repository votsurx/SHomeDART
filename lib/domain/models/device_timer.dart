import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_timer.freezed.dart';
part 'device_timer.g.dart';

@freezed
class DeviceTimer with _$DeviceTimer {
  const factory DeviceTimer({
    required String id,
    required String deviceId,
    required String deviceName,
    required String command,    // 'turnOn', 'turnOff'
    required DateTime executeAt,
    required bool executed,
  }) = _DeviceTimer;

  factory DeviceTimer.fromJson(Map<String, dynamic> json) => _$DeviceTimerFromJson(json);
}