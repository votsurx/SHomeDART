/// Экран списка устройств в виде адаптивной сетки.
/// Поддерживает фильтрацию по комнатам через RoomSelector.
/// Кнопка "+" открывает диалог добавления нового устройства вручную.
/// При создании устройства подставляет default properties в зависимости от типа.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../widgets/device_card.dart';
import '../widgets/room_selector.dart';

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  /// Выбранная комната для фильтрации
  String _selectedRoomId = 'all';
  /// Тип устройства по умолчанию при добавлении
  DeviceType _selectedType = DeviceType.outlet;

  @override
  Widget build(BuildContext context) {
    final allDevices = ref.watch(devicesProvider);

    // Фильтруем устройства по выбранной комнате
    final devices = _selectedRoomId == 'all'
        ? allDevices
        : allDevices.where((d) => d.roomId == _selectedRoomId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои устройства'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDeviceDialog()),
        ],
      ),
      body: Column(
        children: [
          // Селектор комнат (горизонтальные чипсы)
          RoomSelector(
            selectedRoomId: _selectedRoomId,
            onRoomSelected: (room) => setState(() => _selectedRoomId = room.id),
          ),
          const Divider(),
          // Сетка устройств или заглушка
          Expanded(
            child: devices.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Нет устройств', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                // Адаптивная сетка: планшет 3 колонки, телефон 2
                final crossAxisCount = width > 600 ? 3 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) => DeviceCard(device: devices[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Диалог ручного добавления устройства.
  /// Позволяет ввести название, тип, Device ID, IP, Local Key.
  void _showAddDeviceDialog() {
    final nameController = TextEditingController();
    final deviceIdController = TextEditingController();
    final addressController = TextEditingController();
    final localKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить устройство'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
                const SizedBox(height: 8),
                DropdownButtonFormField<DeviceType>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Тип устройства', prefixIcon: Icon(Icons.category)),
                  items: const [
                    DropdownMenuItem(value: DeviceType.outlet, child: Text('Розетка')),
                    DropdownMenuItem(value: DeviceType.switch1, child: Text('Выключатель (1 кл.)')),
                    DropdownMenuItem(value: DeviceType.switch2, child: Text('Выключатель (2 кл.)')),
                    DropdownMenuItem(value: DeviceType.switch3, child: Text('Выключатель (3 кл.)')),
                    DropdownMenuItem(value: DeviceType.sensor, child: Text('Датчик')),
                    DropdownMenuItem(value: DeviceType.light, child: Text('Лампа')),
                    DropdownMenuItem(value: DeviceType.curtain, child: Text('Шторы')),
                    DropdownMenuItem(value: DeviceType.hvac, child: Text('Кондиционер')),
                  ],
                  onChanged: (value) => setDialogState(() => _selectedType = value ?? DeviceType.outlet),
                ),
                const SizedBox(height: 8),
                TextField(controller: deviceIdController, decoration: const InputDecoration(labelText: 'Device ID')),
                const SizedBox(height: 8),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'IP Адрес')),
                const SizedBox(height: 8),
                TextField(controller: localKeyController, decoration: const InputDecoration(labelText: 'Local Key')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && deviceIdController.text.isNotEmpty) {
                  final device = Device(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    type: _selectedType,
                    roomId: _selectedRoomId == 'all' ? 'living' : _selectedRoomId,
                    isOnline: false,
                    state: DeviceState.offline,
                    deviceId: deviceIdController.text,
                    localKey: localKeyController.text,
                    address: addressController.text,
                    version: 3.5,
                    properties: _getDefaultProperties(_selectedType),
                  );
                  ref.read(devicesProvider.notifier).addDevice(device);
                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  /// Возвращает default properties для каждого типа устройства.
  Map<String, dynamic> _getDefaultProperties(DeviceType type) {
    switch (type) {
      case DeviceType.switch1: return {'channels': 1, 'states': [false]};
      case DeviceType.switch2: return {'channels': 2, 'states': [false, false]};
      case DeviceType.switch3: return {'channels': 3, 'states': [false, false, false]};
      case DeviceType.curtain: return {'position': 100, 'isMoving': false};
      case DeviceType.hvac: return {'isOn': false, 'temperature': 22, 'targetTemp': 24, 'mode': 'auto', 'fanSpeed': 1};
      case DeviceType.light: return {'brightness': 255, 'isOn': false};
      default: return {'isOn': false};
    }
  }
}