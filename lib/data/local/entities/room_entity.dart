// lib/data/local/entities/room_entity.dart
class RoomEntity {
  final String id;
  final String name;
  final String? icon;
  final int sortOrder;

  RoomEntity({
    required this.id,
    required this.name,
    this.icon,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
    };
  }

  factory RoomEntity.fromMap(Map<String, dynamic> map) {
    return RoomEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      sortOrder: map['sortOrder'] as int,
    );
  }
}