import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../../di/injection.dart';
import 'devices_provider.dart';

final roomsProvider = StateNotifierProvider<RoomsNotifier, List<Room>>((ref) {
  return RoomsNotifier();
});

class RoomsNotifier extends StateNotifier<List<Room>> {
  final RoomRepository _repository = getIt<RoomRepository>();

  RoomsNotifier() : super([]) {
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final rooms = await _repository.getAllRooms();
    state = rooms;
  }

  Future<void> addRoom(Room room) async {
    await _repository.saveRoom(room);
    state = [...state, room];
  }

  Future<void> deleteRoom(String id) async {
    await _repository.deleteRoom(id);
    state = state.where((r) => r.id != id).toList();
  }

  Future<void> renameRoom(String id, String newName) async {
    final room = state.firstWhere((r) => r.id == id);
    final updated = room.copyWith(name: newName);
    await _repository.saveRoom(updated);
    state = state.map((r) => r.id == id ? updated : r).toList();
  }

  void deleteRoomAndMoveDevices(String roomId) async {
    // Используем getIt для доступа к DevicesNotifier
    final devicesNotifier = getIt<DevicesNotifier>();
    final devices = devicesNotifier.devices;
    for (final device in devices.where((d) => d.roomId == roomId)) {
      devicesNotifier.updateDevice(device.copyWith(roomId: 'all'));
    }
    await _repository.deleteRoom(roomId);
    state = state.where((r) => r.id != roomId).toList();
  }
}