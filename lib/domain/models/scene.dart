import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene.freezed.dart';
part 'scene.g.dart';

@freezed
class Scene with _$Scene {
  const factory Scene({
    required String id,
    required String name,
    required String icon,
    required List<SceneAction> actions,
    SceneTrigger? trigger,
  }) = _Scene;

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
}

@freezed
class SceneAction with _$SceneAction {
  const factory SceneAction({
    required String deviceId,
    required String command, // 'turnOn', 'turnOff', 'setBrightness'
    dynamic value,
  }) = _SceneAction;

  factory SceneAction.fromJson(Map<String, dynamic> json) => _$SceneActionFromJson(json);
}

@freezed
class SceneTrigger with _$SceneTrigger {
  const factory SceneTrigger({
    required TriggerType type,
    String? time,       // 'HH:mm' для time триггера
    String? deviceId,   // для device_state триггера
    String? condition,  // 'on', 'off'
    @Default(RepeatType.once) RepeatType repeat,
    List<int>? repeatDays,
  }) = _SceneTrigger;

  factory SceneTrigger.fromJson(Map<String, dynamic> json) => _$SceneTriggerFromJson(json);
}

enum TriggerType { time, deviceState, manual }
enum RepeatType { once, daily, weekly, interval }