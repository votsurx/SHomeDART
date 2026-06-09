import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';

class DeviceSettings {
  static void show(BuildContext context, WidgetRef ref, Device device) {
    final nameController = TextEditingController(text: device.name);
    final rooms = ref.watch(roomsProvider);
    String selectedRoomId = device.roomId;
    // Проверяем что selectedRoomId существует в списке комнат
    final roomIds = rooms.map((r) => r.id).toList();
    if (!roomIds.contains(selectedRoomId) && rooms.isNotEmpty) {
      selectedRoomId = rooms.first.id;
    }

    // Поля для не-камер
    final localKeyController = TextEditingController(text: device.localKey ?? '');
    final addressController = TextEditingController(text: device.address ?? '');
    double selectedVersion = device.version ?? 3.3;

    // Поля для RTSP камер
    final rtspUrlController = TextEditingController(text: device.properties['rtspUrl'] as String? ?? '');

    // DPS контроллеры для выключателей
    final channelCount = device.type == DeviceType.switch3 ? 3 : (device.type == DeviceType.switch2 ? 2 : 1);
    final dpsControllers = List.generate(channelCount, (i) => TextEditingController(text: '${(device.dpsIndex ?? 1) + i}'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ═══════ НАЗВАНИЕ ═══════
                Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название', prefixIcon: Icon(Icons.edit))),
                const SizedBox(height: 8),

                // ═══════ КОМНАТА (для всех) ═══════
                DropdownButtonFormField<String>(
                  value: selectedRoomId,
                  decoration: const InputDecoration(labelText: 'Комната', prefixIcon: Icon(Icons.meeting_room)),
                  items: rooms.map((r) => DropdownMenuItem(value: r.id, child: Text('${r.icon ?? "🏠"} ${r.name}'))).toList(),
                  onChanged: (v) { if (v != null) setModalState(() => selectedRoomId = v); },
                ),

                // ═══════ RTSP URL (только для RTSP камер) ═══════
                if (device.type == DeviceType.camera && device.properties['cameraType'] == 'rtsp') ...[
                  const SizedBox(height: 8),
                  TextField(controller: rtspUrlController, decoration: const InputDecoration(labelText: 'RTSP URL', prefixIcon: Icon(Icons.link))),
                ],

                // ═══════ СТАНДАРТНЫЕ ПОЛЯ (только для НЕ-камер) ═══════
                if (device.type != DeviceType.camera) ...[
                  const SizedBox(height: 8),

                  // Device ID (только чтение)
                  TextField(
                    controller: TextEditingController(text: device.deviceId ?? ''),
                    decoration: const InputDecoration(labelText: 'Device ID', prefixIcon: Icon(Icons.fingerprint)),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // IP Адрес
                  TextField(controller: addressController, decoration: const InputDecoration(labelText: 'IP Адрес', prefixIcon: Icon(Icons.wifi))),
                  const SizedBox(height: 8),

                  // Local Key
                  TextField(controller: localKeyController, decoration: const InputDecoration(labelText: 'Local Key', prefixIcon: Icon(Icons.vpn_key))),
                  const SizedBox(height: 8),

                  // Версия протокола
                  DropdownButtonFormField<double>(
                    initialValue: selectedVersion,
                    decoration: const InputDecoration(labelText: 'Версия протокола', prefixIcon: Icon(Icons.info_outline)),
                    items: const [
                      DropdownMenuItem(value: 3.1, child: Text('3.1')),
                      DropdownMenuItem(value: 3.3, child: Text('3.3')),
                      DropdownMenuItem(value: 3.4, child: Text('3.4')),
                      DropdownMenuItem(value: 3.5, child: Text('3.5')),
                    ],
                    onChanged: (v) { if (v != null) setModalState(() => selectedVersion = v); },
                  ),

                  // ═══════ DPS ИНДЕКСЫ (только для выключателей) ═══════
                  const SizedBox(height: 8),
                  if (device.type == DeviceType.switch1 || device.type == DeviceType.switch2 || device.type == DeviceType.switch3) ...[
                    Text('DPS каналов:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                    ...List.generate(channelCount, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: dpsControllers[i],
                        decoration: InputDecoration(labelText: 'DPS канала ${i + 1}', prefixIcon: const Icon(Icons.tune)),
                        keyboardType: TextInputType.number,
                      ),
                    )),
                  ] else ...[
                    TextField(
                      controller: dpsControllers.first,
                      decoration: const InputDecoration(labelText: 'DPS Индекс', hintText: '1', prefixIcon: Icon(Icons.tune)),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],

                // ═══════ КНОПКИ СОХРАНИТЬ / УДАЛИТЬ ═══════
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () {
                      Map<String, dynamic> newProperties = {...device.properties};

                      // Обновляем RTSP URL для камер
                      if (device.type == DeviceType.camera && device.properties['cameraType'] == 'rtsp') {
                        newProperties['rtspUrl'] = rtspUrlController.text;
                      }

                      final updated = device.copyWith(
                        name: nameController.text,
                        roomId: selectedRoomId,
                        address: device.type != DeviceType.camera && addressController.text.isNotEmpty ? addressController.text : device.address,
                        localKey: device.type != DeviceType.camera && localKeyController.text.isNotEmpty ? localKeyController.text : device.localKey,
                        dpsIndex: device.type != DeviceType.camera ? (int.tryParse(dpsControllers.first.text) ?? device.dpsIndex) : device.dpsIndex,
                        version: device.type != DeviceType.camera ? selectedVersion : device.version,
                        properties: newProperties,
                      );
                      ref.read(devicesProvider.notifier).updateDevice(updated);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.save), label: const Text('Сохранить'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: ctx,
                      builder: (dCtx) => AlertDialog(
                        title: const Text('Удалить?'),
                        content: Text('Удалить "${device.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Отмена')),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(devicesProvider.notifier).removeDevice(device.id);
                              Navigator.pop(dCtx);
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.delete), label: const Text('Удалить'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  )),
                ]),

                // ═══════ СОЗДАТЬ ДАТЧИК (только для НЕ-камер и НЕ-датчиков) ═══════
                if (device.type != DeviceType.sensor && device.type != DeviceType.camera) ...[
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(ctx); _showCreateSensorDialog(context, ref, device); },
                    icon: const Icon(Icons.add_chart, size: 18),
                    label: const Text('Создать датчик'),
                  )),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showCreateSensorDialog(BuildContext context, WidgetRef ref, Device device) {
    SensorType selectedSensorType = SensorType.temperature;
    final dpsController = TextEditingController(text: '21');
    final dividerController = TextEditingController(text: '10');
    final nameController = TextEditingController(text: '${device.name} t°');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Создать датчик'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Из устройства: ${device.name}'), const SizedBox(height: 12),
            DropdownButtonFormField<SensorType>(
              initialValue: selectedSensorType, decoration: const InputDecoration(labelText: 'Тип датчика'),
              items: const [
                DropdownMenuItem(value: SensorType.temperature, child: Text('Температура')),
                DropdownMenuItem(value: SensorType.humidity, child: Text('Влажность')),
                DropdownMenuItem(value: SensorType.power, child: Text('Мощность')),
                DropdownMenuItem(value: SensorType.current, child: Text('Ток')),
                DropdownMenuItem(value: SensorType.voltage, child: Text('Напряжение')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setDialogState(() {
                    selectedSensorType = v;
                    switch (v) {
                      case SensorType.temperature: dpsController.text = '21'; dividerController.text = '10'; nameController.text = '${device.name} t°'; break;
                      case SensorType.humidity: dpsController.text = '22'; dividerController.text = '10'; nameController.text = '${device.name} h%'; break;
                      case SensorType.power: dpsController.text = '23'; dividerController.text = '10'; nameController.text = '${device.name} W'; break;
                      case SensorType.current: dpsController.text = '21'; dividerController.text = '1'; nameController.text = '${device.name} mA'; break;
                      case SensorType.voltage: dpsController.text = '22'; dividerController.text = '10'; nameController.text = '${device.name} V'; break;
                      default: break;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 8), TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
            const SizedBox(height: 8), TextField(controller: dpsController, decoration: const InputDecoration(labelText: 'DPS индекс'), keyboardType: TextInputType.number),
            const SizedBox(height: 8), TextField(controller: dividerController, decoration: const InputDecoration(labelText: 'Делитель'), keyboardType: TextInputType.number),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(onPressed: () {
              final dps = int.tryParse(dpsController.text) ?? 21;
              final div = double.tryParse(dividerController.text) ?? 10;
              ref.read(devicesProvider.notifier).addDevice(Device(
                id: '${device.id}_sensor_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text,
                type: DeviceType.sensor,
                roomId: device.roomId,
                isOnline: false,
                state: DeviceState.offline,
                deviceId: device.deviceId,
                localKey: device.localKey,
                address: device.address,
                version: device.version,
                dpsIndex: dps,
                properties: {'sensorDps': dps, 'sensorDivider': div, 'sensorType': selectedSensorType.name},
              ));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Датчик "${nameController.text}" создан!')));
            }, child: const Text('Создать')),
          ],
        ),
      ),
    );
  }
}