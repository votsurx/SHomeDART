import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytuya/tinytuya.dart' hide Device;
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';

class DeviceCard extends ConsumerWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHeader(context, ref),
            Expanded(
              child: Center(child: _buildControls(ref)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Icon(_getIconData(), size: 20, color: Colors.blue),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            device.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        GestureDetector(
          onTap: () => _showDeviceSettings(context, ref),
          child: const Icon(Icons.settings, size: 18, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildControls(WidgetRef ref) {
    switch (device.type) {
      case DeviceType.outlet:
      case DeviceType.light:
        return _buildPowerButton(ref, device.id, device.properties['isOn'] == true, null);
      case DeviceType.switch1:
      case DeviceType.switch2:
      case DeviceType.switch3:
        return _buildMultiSwitch(ref);
      case DeviceType.sensorTemp:
      case DeviceType.sensorMotion:
      case DeviceType.sensorDoor:
        return _buildSensorInfo(ref);
      case DeviceType.curtain:
        return _buildCurtainInfo(ref);
      default:
        return _buildPowerButton(ref, device.id, device.properties['isOn'] == true, null);
    }
  }

  Widget _buildPowerButton(WidgetRef ref, String deviceId, bool isOn, String? label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (isOn) {
              ref.read(devicesProvider.notifier).turnOff(deviceId);
            } else {
              ref.read(devicesProvider.notifier).turnOn(deviceId);
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.power_settings_new,
              size: 28,
              color: isOn ? Colors.green : Colors.grey,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ],
    );
  }

  Widget _buildMultiSwitch(WidgetRef ref) {
    final channels = device.properties['channels'] as int? ?? 1;
    final states = List<bool>.from(device.properties['states'] ?? List.filled(channels, false));
    final isThreeChannel = channels == 3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Первый ряд: каналы 1 и 2 (для 2-3 каналов) или только 1 (для 1 канала)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(isThreeChannel ? 2 : channels, (i) {
            final isOn = i < states.length ? states[i] : false;
            return Expanded(
              child: _buildChannelButton(ref, i + 1, isOn, channels > 1),
            );
          }),
        ),
        // Второй ряд: канал 3 (только для 3-канальных)
        if (isThreeChannel) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChannelButton(ref, 3, states.length > 2 ? states[2] : false, true),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildChannelButton(WidgetRef ref, int channel, bool isOn, bool showLabel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            ref.read(devicesProvider.notifier).setSwitchChannel(device.id, channel, !isOn);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.power_settings_new,
              size: 24,
              color: isOn ? Colors.green : Colors.grey,
            ),
          ),
        ),
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('Кан.$channel', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
          ),
      ],
    );
  }

  Widget _buildSensorInfo(WidgetRef ref) {
    final temp = device.properties['temperature'];
    final hum = device.properties['humidity'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (temp != null)
          Text('${(temp as num).toDouble()}°C', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (hum != null)
          Text('${(hum as num).toDouble()}%', style: const TextStyle(fontSize: 14, color: Colors.blue)),
        if (temp == null && hum == null)
          const Text('---', style: TextStyle(fontSize: 22, color: Colors.grey)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _refreshSensorData(ref),
          child: const Icon(Icons.refresh, size: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCurtainInfo(WidgetRef ref) {
    final pos = device.properties['position'] as int? ?? 100;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$pos%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(pos == 0 ? 'Закрыто' : pos == 100 ? 'Открыто' : '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  void _showDeviceSettings(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: device.name);
    final localKeyController = TextEditingController(text: device.localKey ?? '');
    final addressController = TextEditingController(text: device.address ?? '');
    final rooms = ref.watch(roomsProvider);
    String selectedRoomId = device.roomId;

    // Контроллеры для DPS каналов
    final channelCount = device.type == DeviceType.switch3 ? 3 : (device.type == DeviceType.switch2 ? 2 : 1);
    final dpsControllers = List.generate(
      channelCount,
          (i) => TextEditingController(text: '${(device.dpsIndex ?? 1) + i}'),
    );

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
                Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Название
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название', prefixIcon: Icon(Icons.edit))),
                const SizedBox(height: 8),

                // Device ID — открытый
                TextField(
                  controller: TextEditingController(text: device.deviceId ?? ''),
                  decoration: const InputDecoration(labelText: 'Device ID', prefixIcon: Icon(Icons.fingerprint)),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // IP Адрес
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'IP Адрес', prefixIcon: Icon(Icons.wifi))),
                const SizedBox(height: 8),

                // Local Key — открытый
                TextField(controller: localKeyController, decoration: const InputDecoration(labelText: 'Local Key', prefixIcon: Icon(Icons.vpn_key))),
                const SizedBox(height: 8),

                // Комната
                DropdownButtonFormField<String>(
                  value: selectedRoomId,
                  decoration: const InputDecoration(labelText: 'Комната', prefixIcon: Icon(Icons.meeting_room)),
                  items: rooms.map((room) => DropdownMenuItem(value: room.id, child: Text('${room.icon ?? "🏠"} ${room.name}'))).toList(),
                  onChanged: (value) {
                    if (value != null) setModalState(() => selectedRoomId = value);
                  },
                ),
                const SizedBox(height: 8),

                // DPS поля в зависимости от типа
                if (device.type == DeviceType.switch1 || device.type == DeviceType.switch2 || device.type == DeviceType.switch3) ...[
                  Text('DPS каналов:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 4),
                  ...List.generate(
                    channelCount,
                        (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: dpsControllers[i],
                        decoration: InputDecoration(
                          labelText: 'DPS канала ${i + 1}',
                          prefixIcon: const Icon(Icons.tune),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: dpsControllers.first,
                    decoration: const InputDecoration(labelText: 'DPS Индекс', hintText: '1', prefixIcon: Icon(Icons.tune)),
                    keyboardType: TextInputType.number,
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final updated = device.copyWith(
                            name: nameController.text,
                            address: addressController.text.isNotEmpty ? addressController.text : null,
                            localKey: localKeyController.text.isNotEmpty ? localKeyController.text : null,
                            dpsIndex: int.tryParse(dpsControllers.first.text) ?? 1,
                            roomId: selectedRoomId,
                          );
                          ref.read(devicesProvider.notifier).updateDevice(updated);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.save), label: const Text('Сохранить'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: ctx,
                            builder: (dlgCtx) => AlertDialog(
                              title: const Text('Удалить?'),
                              content: Text('Удалить "${device.name}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dlgCtx), child: const Text('Отмена')),
                                ElevatedButton(
                                  onPressed: () { ref.read(devicesProvider.notifier).removeDevice(device.id); Navigator.pop(dlgCtx); Navigator.pop(ctx); },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  child: const Text('Удалить'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete), label: const Text('Удалить'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshSensorData(WidgetRef ref) async {
    try {
      final outlet = OutletDevice(
        deviceId: device.deviceId ?? '',
        address: device.address ?? '',
        localKey: device.localKey ?? '',
        version: device.version ?? 3.3,
      );
      final result = await outlet.status();
      if (result['dps'] != null) {
        final dps = result['dps'] as Map<String, dynamic>;
        final updated = device.copyWith(
          properties: {
            ...device.properties,
            'temperature': dps['21'] != null ? (dps['21'] as num) / 10.0 : null,
            'humidity': dps['22'] != null ? (dps['22'] as num).toDouble() : null,
          },
        );
        ref.read(devicesProvider.notifier).updateDevice(updated);
      }
    } catch (e) {
      // ignore
    }
  }

  IconData _getIconData() {
    switch (device.type) {
      case DeviceType.outlet: return Icons.power;
      case DeviceType.light: return Icons.lightbulb;
      case DeviceType.switch1:
      case DeviceType.switch2:
      case DeviceType.switch3: return Icons.toggle_on;
      case DeviceType.sensorTemp: return Icons.thermostat;
      case DeviceType.sensorMotion: return Icons.sensors;
      case DeviceType.sensorDoor: return Icons.door_sliding;
      case DeviceType.curtain: return Icons.blinds;
      case DeviceType.hvac: return Icons.ac_unit;
      default: return Icons.devices;
    }
  }
}