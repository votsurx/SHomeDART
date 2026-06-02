import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/device.dart';
import '../../domain/models/device_timer.dart';
import '../../data/local/database.dart';
import '../../application/state/devices_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimersScreen extends ConsumerStatefulWidget {
  const TimersScreen({super.key});

  @override
  ConsumerState<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends ConsumerState<TimersScreen> {
  List<DeviceTimer> _timers = [];

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  Future<void> _loadTimers() async {
    final timers = await AppDatabase.getActiveTimers();
    setState(() => _timers = timers);
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final controllableDevices = devices.where((d) =>
    d.type == DeviceType.outlet || d.type == DeviceType.light).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Таймеры')),
      body: _timers.isEmpty
          ? const Center(child: Text('Нет активных таймеров'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _timers.length,
        itemBuilder: (context, index) {
          final timer = _timers[index];
          return Card(
            child: ListTile(
              leading: Icon(
                timer.command == 'turnOn' ? Icons.power_settings_new : Icons.power_off,
                color: timer.command == 'turnOn' ? Colors.green : Colors.red,
              ),
              title: Text(timer.deviceName),
              subtitle: Text('${timer.command == 'turnOn' ? "Включить" : "Выключить"} в ${_formatTime(timer.executeAt)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await AppDatabase.deleteTimer(timer.id);
                  _loadTimers();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTimerDialog(context, controllableDevices),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTimerDialog(BuildContext context, List<Device> devices) {
    Device? selectedDevice;
    String command = 'turnOff';
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Новый таймер'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Device>(
                  decoration: const InputDecoration(labelText: 'Устройство'),
                  items: devices.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                  onChanged: (value) => setDialogState(() => selectedDevice = value),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'turnOff', label: Text('ВЫКЛ')),
                    ButtonSegment(value: 'turnOn', label: Text('ВКЛ')),
                  ],
                  selected: {command},
                  onSelectionChanged: (v) => setDialogState(() => command = v.first),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(_formatTime(DateTime(2024, 1, 1, selectedTime.hour, selectedTime.minute))),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(context: ctx, initialTime: selectedTime);
                    if (time != null) setDialogState(() => selectedTime = time);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (selectedDevice != null) {
                  final now = DateTime.now();
                  final executeAt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                  final timer = DeviceTimer(
                    id: const Uuid().v4(),
                    deviceId: selectedDevice!.id,
                    deviceName: selectedDevice!.name,
                    command: command,
                    executeAt: executeAt.isBefore(now) ? executeAt.add(const Duration(days: 1)) : executeAt,
                    executed: false,
                  );
                  AppDatabase.insertTimer(timer);
                  _loadTimers();
                  Navigator.pop(ctx);
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