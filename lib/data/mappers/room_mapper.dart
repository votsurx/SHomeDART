// lib/data/mappers/room_mapper.dart
import '../../domain/models/room.dart';
import '../local/entities/room_entity.dart';

class RoomMapper {
  static Room toDomain(RoomEntity entity) {
    return Room(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      sortOrder: entity.sortOrder,
    );
  }

  static RoomEntity toEntity(Room room) {
    return RoomEntity(
      id: room.id,
      name: room.name,
      icon: room.icon,
      sortOrder: room.sortOrder,
    );
  }
}