import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tinytuya/tinytuya.dart' hide Device;
import 'package:uuid/uuid.dart';
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _scanning = false;
  List<dynamic> _foundDevices = [];
  final Set<String> _addedDevices = {};
  DeviceType _selectedType = DeviceType.outlet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск устройств')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text(
                    'Найдём ваши устройства',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажмите + чтобы добавить устройство',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  if (_scanning)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Сканируем сеть...'),
                      ],
                    ),
                  if (_foundDevices.isNotEmpty) ...[
                    Text('Найдено устройств: ${_foundDevices.length}'),
                    const SizedBox(height: 16),
                    ..._foundDevices.map((device) {
                      final deviceId = device.gwId?.toString() ?? '';
                      final isAdded = _addedDevices.contains(deviceId);

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            isAdded ? Icons.check_circle : Icons.devices,
                            color: isAdded ? Colors.green : null,
                          ),
                          title: Text(device.gwId?.toString() ?? 'Неизвестно'),
                          subtitle: Text('IP: ${device.ip} | v${device.version}'),
                          trailing: isAdded
                              ? const Icon(Icons.check, color: Colors.green)
                              : IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.blue),
                            onPressed: () => _showAddDialog(device),
                          ),
                        ),
                      );
                    }),
                  ],
                  if (!_scanning && _foundDevices.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('Устройства не найдены'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _scanning ? null : _startScan,
                    icon: const Icon(Icons.search),
                    label: Text(_scanning ? 'Сканирование...' : 'Сканировать', style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.push('/onboarding/rooms'),
                    child: const Text('Продолжить', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(dynamic device) {
    final nameController = TextEditingController(text: 'Устройство ${device.ip}');
    final localKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить устройство'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Device ID: ${device.gwId}'),
              const SizedBox(height: 4),
              Text('IP: ${device.ip}'),
              const SizedBox(height: 4),
              Text('Версия: ${device.version}'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DeviceType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Тип устройства',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: DeviceType.outlet, child: Text('Розетка')),
                  DropdownMenuItem(value: DeviceType.switch1, child: Text('Выключатель')),
                  DropdownMenuItem(value: DeviceType.sensorTemp, child: Text('Датчик температуры')),
                  DropdownMenuItem(value: DeviceType.sensorMotion, child: Text('Датчик движения')),
                  DropdownMenuItem(value: DeviceType.light, child: Text('Лампа')),
                  DropdownMenuItem(value: DeviceType.curtain, child: Text('Шторы')),
                ],
                onChanged: (value) {
                  setState(() => _selectedType = value ?? DeviceType.outlet);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: localKeyController,
                decoration: const InputDecoration(
                  labelText: 'Local Key',
                  hintText: 'Введите localKey из Tuya IoT',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (localKeyController.text.isNotEmpty) {
                final newDevice = Device(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  type: _selectedType,
                  roomId: 'living',
                  isOnline: true,
                  state: DeviceState.online,
                  deviceId: device.gwId?.toString() ?? '',
                  localKey: localKeyController.text,
                  address: device.ip?.toString() ?? '',
                  version: double.tryParse(device.version?.toString() ?? '3.3') ?? 3.3,
                  properties: {'isOn': false},
                );

                ref.read(devicesProvider.notifier).addDevice(newDevice);
                setState(() => _addedDevices.add(device.gwId?.toString() ?? ''));
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${nameController.text} добавлено!')),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _foundDevices.clear();
    });

    try {
      final devices = await deviceScan(scanTime: 10, verbose: true);

      if (mounted) {
        setState(() {
          _foundDevices = devices;
          _scanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сканирования: $e')),
        );
      }
    }
  }
}