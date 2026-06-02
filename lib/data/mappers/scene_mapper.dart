import 'dart:convert';
import '../../domain/models/scene.dart';
import '../local/entities/scene_entity.dart';

class SceneMapper {
  static SceneEntity toEntity(Scene scene) => SceneEntity(
    id: scene.id,
    name: scene.name,
    icon: scene.icon,
    actions: jsonEncode(scene.actions.map((a) => a.toJson()).toList()),
    triggerType: scene.trigger?.type.name,
    triggerTime: scene.trigger?.time,
    triggerRepeat: scene.trigger?.repeat.name,
  );

  static Scene toDomain(SceneEntity entity) => Scene(
    id: entity.id,
    name: entity.name,
    icon: entity.icon,
    actions: (jsonDecode(entity.actions) as List).map((a) => SceneAction.fromJson(a)).toList(),
    trigger: entity.triggerType != null
        ? SceneTrigger(
      type: TriggerType.values.firstWhere((t) => t.name == entity.triggerType),
      time: entity.triggerTime,
      repeat: entity.triggerRepeat != null
          ? RepeatType.values.firstWhere((r) => r.name == entity.triggerRepeat)
          : RepeatType.once,
    )
        : null,
  );
}