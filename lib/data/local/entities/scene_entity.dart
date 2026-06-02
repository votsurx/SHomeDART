class SceneEntity {
  final String id;
  final String name;
  final String icon;
  final String actions;      // JSON
  final String? triggerType;
  final String? triggerTime;
  final String? triggerRepeat;

  SceneEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.actions,
    this.triggerType,
    this.triggerTime,
    this.triggerRepeat,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'icon': icon, 'actions': actions,
    'triggerType': triggerType, 'triggerTime': triggerTime, 'triggerRepeat': triggerRepeat,
  };

  factory SceneEntity.fromMap(Map<String, dynamic> map) => SceneEntity(
    id: map['id'], name: map['name'], icon: map['icon'], actions: map['actions'],
    triggerType: map['triggerType'], triggerTime: map['triggerTime'], triggerRepeat: map['triggerRepeat'],
  );
}