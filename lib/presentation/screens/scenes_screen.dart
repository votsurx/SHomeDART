import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/scene.dart';
import '../../application/state/scenes_provider.dart';
import '../../application/state/devices_provider.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Сцены')),
      body: scenes.isEmpty
          ? const Center(child: Text('Нет сцен. Создайте первую!'))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: scenes.length,
        itemBuilder: (context, index) {
          final scene = scenes[index];
          return Card(
            child: InkWell(
              onTap: () => ref.read(scenesProvider.notifier).executeScene(scene.id),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(scene.icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(scene.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (scene.trigger != null && scene.trigger!.type != TriggerType.manual)
                    Text(
                      scene.trigger!.type == TriggerType.time
                          ? '⏰ ${scene.trigger!.time}'
                          : '📡 По состоянию',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSceneDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateSceneDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final devices = ref.read(devicesProvider);
    final selectedActions = <SceneAction>[];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Новая сцена'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название', hintText: 'Ухожу из дома'),
                ),
                const SizedBox(height: 16),
                const Text('Выберите действия:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...devices.map((device) => CheckboxListTile(
                  title: Text(device.name),
                  subtitle: Text('Включить'),
                  value: selectedActions.any((a) => a.deviceId == device.id),
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked == true) {
                        selectedActions.add(SceneAction(deviceId: device.id, command: 'turnOff'));
                      } else {
                        selectedActions.removeWhere((a) => a.deviceId == device.id);
                      }
                    });
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedActions.isNotEmpty) {
                  final scene = Scene(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    icon: '🎬',
                    actions: selectedActions,
                  );
                  ref.read(scenesProvider.notifier).addScene(scene);
                  Navigator.pop(context);
                }
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }
}