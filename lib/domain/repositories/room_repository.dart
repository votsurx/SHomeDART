import '../models/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getAllRooms();
  Future<Room?> getRoomById(String id);
  Future<void> saveRoom(Room room);
  Future<void> deleteRoom(String id);
}