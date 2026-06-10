import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';

class DeviceSettings {
  static void show(BuildContext context, WidgetRef ref, Device device) {
    // ===================== КОНТРОЛЛЕРЫ =====================
    final nameController = TextEditingController(text: device.name);
    final rooms = ref.watch(roomsProvider);
    String selectedRoomId = device.roomId;

    // Проверяем что комната существует в списке
    final roomIds = rooms.map((r) => r.id).toList();
    if (!roomIds.contains(selectedRoomId) && rooms.isNotEmpty) {
      selectedRoomId = rooms.first.id;
    }

    // Поля для устройств Tuya (кроме камер)
    final localKeyController = TextEditingController(text: device.localKey ?? '');
    final addressController = TextEditingController(text: device.address ?? '');
    double selectedVersion = device.version ?? 3.3;

    // Поля для RTSP камер
    final rtspUrlController = TextEditingController(text: device.properties['rtspUrl'] as String? ?? '');

    // DPS контроллеры для многоканальных выключателей
    final channelCount = device.type == DeviceType.switch3 ? 3 : (device.type == DeviceType.switch2 ? 2 : 1);
    final dpsControllers = List.generate(
      channelCount,
          (i) => TextEditingController(text: '${(device.dpsIndex ?? 1) + i}'),
    );

    // ===================== BOTTOM SHEET =====================
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ═══════════════════════════════════════════
                // НАЗВАНИЕ (для всех устройств)
                // ═══════════════════════════════════════════
                Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название', prefixIcon: Icon(Icons.edit)),
                ),
                const SizedBox(height: 8),

                // ═══════════════════════════════════════════
                // КОМНАТА (для всех устройств)
                // ═══════════════════════════════════════════
                DropdownButtonFormField<String>(
                  value: selectedRoomId,
                  decoration: const InputDecoration(labelText: 'Комната', prefixIcon: Icon(Icons.meeting_room)),
                  items: rooms
                      .map((r) => DropdownMenuItem(
                    value: r.id,
                    child: Text('${r.icon ?? "🏠"} ${r.name}'),
                  ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedRoomId = v);
                  },
                ),

                // ═══════════════════════════════════════════
                // RTSP URL (только для RTSP камер)
                // ═══════════════════════════════════════════
                if (device.type == DeviceType.camera && device.properties['cameraType'] == 'rtsp') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: rtspUrlController,
                    decoration: const InputDecoration(labelText: 'RTSP URL', prefixIcon: Icon(Icons.link)),
                  ),
                ],

                // ═══════════════════════════════════════════
                // СТАНДАРТНЫЕ ПОЛЯ TUYA (для всех кроме камер)
                // ═══════════════════════════════════════════
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
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'IP Адрес', prefixIcon: Icon(Icons.wifi)),
                  ),
                  const SizedBox(height: 8),

                  // Local Key
                  TextField(
                    controller: localKeyController,
                    decoration: const InputDecoration(labelText: 'Local Key', prefixIcon: Icon(Icons.vpn_key)),
                  ),
                  const SizedBox(height: 8),

                  // Версия протокола Tuya
                  DropdownButtonFormField<double>(
                    initialValue: selectedVersion,
                    decoration: const InputDecoration(labelText: 'Версия протокола', prefixIcon: Icon(Icons.info_outline)),
                    items: const [
                      DropdownMenuItem(value: 3.1, child: Text('3.1')),
                      DropdownMenuItem(value: 3.3, child: Text('3.3')),
                      DropdownMenuItem(value: 3.4, child: Text('3.4')),
                      DropdownMenuItem(value: 3.5, child: Text('3.5')),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedVersion = v);
                    },
                  ),
                ],

                // ═══════════════════════════════════════════
                // DPS ИНДЕКСЫ (выключатели и обычные устройства)
                // Скрыто для: камер, пылесосов (у них dps_map)
                // ═══════════════════════════════════════════
                if (device.type != DeviceType.camera && device.type != DeviceType.robotVacuum) ...[
                  const SizedBox(height: 8),
                  if (device.type == DeviceType.switch1 ||
                      device.type == DeviceType.switch2 ||
                      device.type == DeviceType.switch3) ...[
                    // Многоканальные — DPS для каждого канала
                    Text('DPS каналов:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                    const SizedBox(height: 4),
                    ...List.generate(channelCount, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: dpsControllers[i],
                        decoration: InputDecoration(
                            labelText: 'DPS канала ${i + 1}', prefixIcon: const Icon(Icons.tune)),
                        keyboardType: TextInputType.number,
                      ),
                    )),
                  ] else ...[
                    // Одноканальные — один DPS индекс
                    TextField(
                      controller: dpsControllers.first,
                      decoration: const InputDecoration(labelText: 'DPS Индекс', hintText: '1', prefixIcon: Icon(Icons.tune)),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],

                // ═══════════════════════════════════════════
                // DPS КАРТА (для робота-пылесоса)
                // ═══════════════════════════════════════════
                if (device.type == DeviceType.robotVacuum) ...[
                  const SizedBox(height: 8),
                  Text('DPS карта:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 4),
                  ..._buildDpsMapEditor(device, setModalState, context, ref),
                  // Кнопка добавления DPS
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showDpsEditor(ctx, setModalState, device, null, ref),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Добавить DPS'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                    ),
                  ),
                ],

                // ═══════════════════════════════════════════
                // КНОПКИ: СОХРАНИТЬ / УДАЛИТЬ
                // ═══════════════════════════════════════════
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Map<String, dynamic> newProperties = {...device.properties};

                        // Обновляем RTSP URL для камер
                        if (device.type == DeviceType.camera &&
                            device.properties['cameraType'] == 'rtsp') {
                          newProperties['rtspUrl'] = rtspUrlController.text;
                        }

                        final updated = device.copyWith(
                          name: nameController.text,
                          roomId: selectedRoomId,
                          address: device.type != DeviceType.camera && addressController.text.isNotEmpty
                              ? addressController.text
                              : device.address,
                          localKey: device.type != DeviceType.camera && localKeyController.text.isNotEmpty
                              ? localKeyController.text
                              : device.localKey,
                          dpsIndex: device.type != DeviceType.camera && device.type != DeviceType.robotVacuum
                              ? (int.tryParse(dpsControllers.first.text) ?? device.dpsIndex)
                              : device.dpsIndex,
                          version: device.type != DeviceType.camera ? selectedVersion : device.version,
                          properties: newProperties,
                        );
                        ref.read(devicesProvider.notifier).updateDevice(updated);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Сохранить'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.delete),
                      label: const Text('Удалить'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    ),
                  ),
                ]),

                // ═══════════════════════════════════════════
                // СОЗДАТЬ ДАТЧИК (только для НЕ-камер, НЕ-датчиков, НЕ-пылесосов)
                // ═══════════════════════════════════════════
                if (device.type != DeviceType.sensor &&
                    device.type != DeviceType.camera &&
                    device.type != DeviceType.robotVacuum) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCreateSensorDialog(context, ref, device);
                      },
                      icon: const Icon(Icons.add_chart, size: 18),
                      label: const Text('Создать датчик'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DPS КАРТА РЕДАКТОР ====================

  /// Отображает список DPS из dps_map с иконками по ролям.
  static List<Widget> _buildDpsMapEditor(
      Device device,
      void Function(VoidCallback) setModalState,
      BuildContext ctx,
      WidgetRef ref,
      ) {
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});

    // Сортируем ключи по числовому значению
    final sortedKeys = dpsMap.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    return sortedKeys.map((key) {
      final cfg = dpsMap[key] as Map<String, dynamic>;
      final label = cfg['label'] as String? ?? '';
      final type = cfg['type'] as String? ?? '';
      final role = cfg['role'] as String? ?? '';

      return ListTile(
        dense: true,
        leading: _dpsRoleIcon(role),
        title: Text('DPS $key: $label', style: const TextStyle(fontSize: 12)),
        subtitle: Text('$type / $role', style: const TextStyle(fontSize: 10)),
        trailing: const Icon(Icons.edit, size: 16),
        onTap: () {
          Navigator.pop(ctx);
          _showDpsEditor(ctx, setModalState, device, key, ref);
        },
      );
    }).toList();
  }

  /// Возвращает иконку в зависимости от роли DPS.
  static Icon _dpsRoleIcon(String role) {
    switch (role) {
      case 'main':
        return const Icon(Icons.power_settings_new, size: 16, color: Colors.green);
      case 'action':
        return const Icon(Icons.play_circle, size: 16, color: Colors.blue);
      case 'toggle':
        return const Icon(Icons.toggle_on, size: 16, color: Colors.orange);
      case 'info':
        return const Icon(Icons.info_outline, size: 16, color: Colors.grey);
      case 'status':
        return const Icon(Icons.info, size: 16, color: Colors.teal);
      case 'slider':
        return const Icon(Icons.tune, size: 16, color: Colors.purple);
      default:
        return const Icon(Icons.help_outline, size: 16);
    }
  }
  /// Диалог добавления/редактирования одного DPS в dps_map.
  static void _showDpsEditor(
      BuildContext context,
      void Function(VoidCallback) setModalState,
      Device device,
      String? dpsKey, // null = новый DPS
      WidgetRef ref,
      ) {
    final isNew = dpsKey == null;
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});

    final keyController = TextEditingController(text: dpsKey ?? '');
    final labelController = TextEditingController(text: isNew ? '' : dpsMap[dpsKey]?['label'] ?? '');
    String selectedType = isNew ? 'bool' : dpsMap[dpsKey]?['type'] ?? 'bool';
    String selectedRole = isNew ? 'action' : dpsMap[dpsKey]?['role'] ?? 'action';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isNew ? 'Добавить DPS' : 'Редактировать DPS $dpsKey'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: keyController,
                decoration: const InputDecoration(labelText: 'Номер DPS'),
                keyboardType: TextInputType.number,
                enabled: true, // всегда можно редактировать
              ),
              const SizedBox(height: 8),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Тип'),
                items: const [
                  DropdownMenuItem(value: 'bool', child: Text('bool (вкл/выкл)')),
                  DropdownMenuItem(value: 'value', child: Text('value (число)')),
                  DropdownMenuItem(value: 'enum', child: Text('enum (текст)')),
                  DropdownMenuItem(value: 'slider', child: Text('slider (ползунок)')),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedType = v);
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Роль'),
                items: const [
                  DropdownMenuItem(value: 'main', child: Text('main (главная кнопка)')),
                  DropdownMenuItem(value: 'action', child: Text('action (действие)')),
                  DropdownMenuItem(value: 'toggle', child: Text('toggle (переключатель)')),
                  DropdownMenuItem(value: 'info', child: Text('info (информация)')),
                  DropdownMenuItem(value: 'status', child: Text('status (статус)')),
                  DropdownMenuItem(value: 'slider', child: Text('slider (ползунок)')),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedRole = v);
                },
              ),
            ]),
          ),
          actions: [
            if (!isNew)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteDps(device, dpsKey!, ref);
                },
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                final newKey = keyController.text.trim();
                if (newKey.isEmpty || labelController.text.isEmpty) return;

                final newDpsMap = Map<String, dynamic>.from(dpsMap);

                // Если ключ изменился — удаляем старый
                if (!isNew && dpsKey != newKey) {
                  newDpsMap.remove(dpsKey);
                }

                newDpsMap[newKey] = {
                  'label': labelController.text,
                  'type': selectedType,
                  'role': selectedRole,
                };

                final updated = device.copyWith(
                  properties: {...device.properties, 'dps_map': newDpsMap},
                );
                ref.read(devicesProvider.notifier).updateDevice(updated);
                Navigator.pop(ctx);

                // Переоткрываем настройки с обновлённым устройством
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  DeviceSettings.show(context, ref, updated);
                });
              },
              child: Text(isNew ? 'Добавить' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  /// Удаляет DPS из dps_map.
  static void _deleteDps(Device device, String dpsKey, WidgetRef ref) {
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});
    dpsMap.remove(dpsKey);

    final updated = device.copyWith(
      properties: {...device.properties, 'dps_map': dpsMap},
    );
    ref.read(devicesProvider.notifier).updateDevice(updated);
  }

  // ==================== СОЗДАТЬ ДАТЧИК ====================

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
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Из устройства: ${device.name}'),
              const SizedBox(height: 12),
              DropdownButtonFormField<SensorType>(
                initialValue: selectedSensorType,
                decoration: const InputDecoration(labelText: 'Тип датчика'),
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
                        case SensorType.temperature:
                          dpsController.text = '21';
                          dividerController.text = '10';
                          nameController.text = '${device.name} t°';
                          break;
                        case SensorType.humidity:
                          dpsController.text = '22';
                          dividerController.text = '10';
                          nameController.text = '${device.name} h%';
                          break;
                        case SensorType.power:
                          dpsController.text = '23';
                          dividerController.text = '10';
                          nameController.text = '${device.name} W';
                          break;
                        case SensorType.current:
                          dpsController.text = '21';
                          dividerController.text = '1';
                          nameController.text = '${device.name} mA';
                          break;
                        case SensorType.voltage:
                          dpsController.text = '22';
                          dividerController.text = '10';
                          nameController.text = '${device.name} V';
                          break;
                        default:
                          break;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
              const SizedBox(height: 8),
              TextField(controller: dpsController, decoration: const InputDecoration(labelText: 'DPS индекс'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: dividerController, decoration: const InputDecoration(labelText: 'Делитель'), keyboardType: TextInputType.number),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Датчик "${nameController.text}" создан!')),
                );
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }
}