import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/room.dart';
import '../../application/state/rooms_provider.dart';
import '../../application/state/devices_provider.dart';

class RoomsManageScreen extends ConsumerWidget {
  const RoomsManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Комнаты')),
      body: rooms.isEmpty
          ? const Center(child: Text('Нет комнат. Добавьте первую!', style: TextStyle(fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          final deviceCount = devices.where((d) => d.roomId == room.id).length;

          return Card(
            child: ListTile(
              leading: Text(room.icon ?? '🏠', style: const TextStyle(fontSize: 32)),
              title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text('Устройств: $deviceCount'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showRenameDialog(context, ref, room),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, ref, room, deviceCount),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoomDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить комнату'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Название', hintText: 'Гостиная'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(roomsProvider.notifier).addRoom(Room(
                  id: const Uuid().v4(),
                  name: controller.text,
                  sortOrder: ref.read(roomsProvider).length,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Room room) {
    final controller = TextEditingController(text: room.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Переименовать'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Название'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(roomsProvider.notifier).renameRoom(room.id, controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Room room, int deviceCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить комнату?'),
        content: Text(deviceCount > 0
            ? 'В комнате $deviceCount устройств. Они будут перенесены в «Все устройства». Продолжить?'
            : 'Удалить комнату «${room.name}»?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              ref.read(roomsProvider.notifier).deleteRoomAndMoveDevices(room.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Комната «${room.name}» удалена')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}