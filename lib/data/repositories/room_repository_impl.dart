import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../local/database.dart';
import '../mappers/room_mapper.dart';

class RoomRepositoryImpl implements RoomRepository {
  final Map<String, Room> _rooms = {};

  @override
  Future<List<Room>> getAllRooms() async {
    if (_rooms.isEmpty) {
      final entities = await AppDatabase.getAllRooms();
      for (final entity in entities) {
        _rooms[entity.id] = RoomMapper.toDomain(entity);
      }
    }
    return _rooms.values.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<Room?> getRoomById(String id) async {
    if (!_rooms.containsKey(id)) {
      await getAllRooms();
    }
    return _rooms[id];
  }

  @override
  Future<void> saveRoom(Room room) async {
    _rooms[room.id] = room;
    await AppDatabase.insertRoom(RoomMapper.toEntity(room));
  }

  @override
  Future<void> deleteRoom(String id) async {
    _rooms.remove(id);
    await AppDatabase.deleteRoom(id);
  }
}