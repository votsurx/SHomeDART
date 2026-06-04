/// Карточка устройства — основной виджет для отображения устройства в сетке.
/// Поддерживает все типы устройств: розетки, выключатели, датчики, шторы, HVAC, лампы.
/// Для каждого типа — свой набор контролов (power-иконка, многоканальные, данные датчиков).
/// Шестерёнка открывает настройки: редактирование параметров, создание датчика, удаление.
library;
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
  /// Заголовок карточки: иконка типа + название + шестерёнка настроек.
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
  /// Выбирает тип контролов в зависимости от типа устройства.
  Widget _buildControls(WidgetRef ref) {
    switch (device.type) {
      case DeviceType.outlet:
      case DeviceType.light:
        return _buildPowerButton(ref, device.id, device.properties['isOn'] == true, null);
      case DeviceType.switch1:
      case DeviceType.switch2:
      case DeviceType.switch3:
        return _buildMultiSwitch(ref);
      case DeviceType.sensor:
        return _buildSensorInfo(ref);
      case DeviceType.curtain:
        return _buildCurtainInfo(ref);
      default:
        return _buildPowerButton(ref, device.id, device.properties['isOn'] == true, null);
    }
  }
  /// Кнопка питания для одноканальных устройств.
  /// Зелёная — включено, серая — выключено, красная — оффлайн.
  Widget _buildPowerButton(WidgetRef ref, String deviceId, bool isOn, String? label) {
    final isOnline = device.state != DeviceState.offline && device.state != DeviceState.offline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (!isOnline) {
              ScaffoldMessenger.of(ref.context).showSnackBar(
                const SnackBar(content: Text('Устройство не в сети'), duration: Duration(seconds: 1)),
              );
              return;
            }
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
              color: isOnline
                  ? (isOn ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1))
                  : Colors.red.withValues(alpha: 0.1),
            ),
            child: Icon(
              isOnline ? Icons.power_settings_new : Icons.wifi_off,
              size: 28,
              color: isOnline ? (isOn ? Colors.green : Colors.grey) : Colors.red,
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
  /// Многоканальный выключатель. 3 канала — в два ряда.
  Widget _buildMultiSwitch(WidgetRef ref) {
    final channels = device.properties['channels'] as int? ?? 1;
    final states = List<bool>.from(device.properties['states'] ?? List.filled(channels, false));
    final isThreeChannel = channels == 3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(isThreeChannel ? 2 : channels, (i) {
            final isOn = i < states.length ? states[i] : false;
            return Expanded(
              child: _buildChannelButton(ref, i + 1, isOn, channels > 1),
            );
          }),
        ),
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
  /// Кнопка одного канала многоканального выключателя.
  Widget _buildChannelButton(WidgetRef ref, int channel, bool isOn, bool showLabel) {
    final isOnline = device.state != DeviceState.offline && device.state != DeviceState.offline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (!isOnline) {
              ScaffoldMessenger.of(ref.context).showSnackBar(
                const SnackBar(content: Text('Устройство не в сети'), duration: Duration(seconds: 1)),
              );
              return;
            }
            ref.read(devicesProvider.notifier).setSwitchChannel(device.id, channel, !isOn);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline
                  ? (isOn ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1))
                  : Colors.red.withValues(alpha: 0.1),
            ),
            child: Icon(
              isOnline ? Icons.power_settings_new : Icons.wifi_off,
              size: 24,
              color: isOnline ? (isOn ? Colors.green : Colors.grey) : Colors.red,
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
  /// Отображение данных датчика: температура, влажность, мощность, ток, напряжение.
  Widget _buildSensorInfo(WidgetRef ref) {
    final temp = device.properties['temperature'];
    final hum = device.properties['humidity'];
    final power = device.properties['power'];
    final current = device.properties['current'];
    final voltage = device.properties['voltage'];
    final sensorType = device.properties['sensorType'] as String?;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (temp != null)
          Text('${(temp as num).toDouble()}°C', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (hum != null)
          Text('${(hum as num).toDouble()}%', style: const TextStyle(fontSize: 14, color: Colors.blue)),
        if (power != null)
          Text('${(power as num).toDouble()} W', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (current != null)
          Text('${(current as num).toDouble()} mA', style: const TextStyle(fontSize: 14, color: Colors.orange)),
        if (voltage != null)
          Text('${(voltage as num).toDouble()} V', style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
        if (temp == null && hum == null && power == null && current == null && voltage == null)
          Text(sensorType ?? '---', style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _refreshSensorData(ref),
          child: const Icon(Icons.refresh, size: 16, color: Colors.grey),
        ),
      ],
    );
  }
  /// Шторы: процент открытия.
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
  /// Шестерёнка — настройки устройства.
  /// Открывает bottom sheet с настройками устройства.
  /// Позволяет редактировать: название, IP, localKey, версию протокола, комнату, DPS индексы.
  /// Для многоканальных — поля DPS для каждого канала.
  /// Для обычных устройств — кнопка "Создать датчик".
  void _showDeviceSettings(BuildContext context, WidgetRef ref) {
    // Контроллеры для редактирования
    final nameController = TextEditingController(text: device.name);
    final localKeyController = TextEditingController(text: device.localKey ?? '');
    final addressController = TextEditingController(text: device.address ?? '');
    final dpsController = TextEditingController(text: device.dpsIndex?.toString() ?? '1');
    final rooms = ref.watch(roomsProvider);
    String selectedRoomId = device.roomId;
    double selectedVersion = device.version ?? 3.3;

    // Контроллеры DPS для каждого канала многоканального устройства
    final channelCount = device.type == DeviceType.switch3 ? 3 : (device.type == DeviceType.switch2 ? 2 : 1);
    final dpsControllers = List.generate(
      channelCount,
          (i) => TextEditingController(text: '${(device.dpsIndex ?? 1) + i}'),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,  // Поднимается над клавиатурой
      builder: (ctx) => StatefulBuilder(  // Позволяет обновлять состояние внутри bottom sheet
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ====== Название устройства ======
                Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // ====== Название (редактируемое) ======
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название', prefixIcon: Icon(Icons.edit))),
                const SizedBox(height: 8),

                // ====== Device ID (только чтение) ======
                TextField(
                  controller: TextEditingController(text: device.deviceId ?? ''),
                  decoration: const InputDecoration(labelText: 'Device ID', prefixIcon: Icon(Icons.fingerprint)),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // ====== IP Адрес ======
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'IP Адрес', prefixIcon: Icon(Icons.wifi))),
                const SizedBox(height: 8),

                // ====== Local Key ======
                TextField(controller: localKeyController, decoration: const InputDecoration(labelText: 'Local Key', prefixIcon: Icon(Icons.vpn_key))),
                const SizedBox(height: 8),

                // ====== Версия протокола Tuya ======
                DropdownButtonFormField<double>(
                  initialValue: selectedVersion,
                  decoration: const InputDecoration(labelText: 'Версия протокола', prefixIcon: Icon(Icons.info_outline)),
                  items: const [
                    DropdownMenuItem(value: 3.1, child: Text('3.1')),
                    DropdownMenuItem(value: 3.3, child: Text('3.3')),
                    DropdownMenuItem(value: 3.4, child: Text('3.4')),
                    DropdownMenuItem(value: 3.5, child: Text('3.5')),
                  ],
                  onChanged: (value) {
                    if (value != null) setModalState(() => selectedVersion = value);
                  },
                ),
                const SizedBox(height: 8),

                // ====== Комната ======
                DropdownButtonFormField<String>(
                  initialValue: selectedRoomId,
                  decoration: const InputDecoration(labelText: 'Комната', prefixIcon: Icon(Icons.meeting_room)),
                  items: rooms.map((room) => DropdownMenuItem(value: room.id, child: Text('${room.icon ?? "🏠"} ${room.name}'))).toList(),
                  onChanged: (value) {
                    if (value != null) setModalState(() => selectedRoomId = value);
                  },
                ),
                const SizedBox(height: 8),

                // ====== DPS индексы ======
                if (device.type == DeviceType.switch1 || device.type == DeviceType.switch2 || device.type == DeviceType.switch3) ...[
                  Text('DPS каналов:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 4),
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

                const SizedBox(height: 16),
                // ====== Кнопки Сохранить / Удалить ======
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
                            version: selectedVersion,
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

                // ====== Кнопка "Создать датчик" (только для не-датчиков) ======
                if (device.type != DeviceType.sensor) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCreateSensorDialog(context, ref);
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
  /// Диалог создания датчика из текущего устройства.
  /// Позволяет выбрать тип датчика (температура, влажность, мощность, ток, напряжение),
  /// указать название, DPS индекс и делитель.
  /// Создаёт новое устройство с типом DeviceType.sensor,
  /// копируя IP, localKey, deviceId от родительского устройства.
  void _showCreateSensorDialog(BuildContext context, WidgetRef ref) {
    // По умолчанию — датчик температуры
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Из устройства: ${device.name}'),
                const SizedBox(height: 12),

                // ====== Тип датчика ======
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
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedSensorType = value;
                        // Автозаполнение DPS и делителя в зависимости от типа
                        switch (value) {
                          case SensorType.temperature:
                            dpsController.text = '21';    // DPS 21 — температура
                            dividerController.text = '10';  // ÷10 для °C
                            nameController.text = '${device.name} t°';
                            break;
                          case SensorType.humidity:
                            dpsController.text = '22';    // DPS 22 — влажность
                            dividerController.text = '10';
                            nameController.text = '${device.name} h%';
                            break;
                          case SensorType.power:
                            dpsController.text = '23';    // DPS 23 — мощность
                            dividerController.text = '10';  // ÷10 для W
                            nameController.text = '${device.name} W';
                            break;
                          case SensorType.current:
                            dpsController.text = '21';    // DPS 21 — ток (mA)
                            dividerController.text = '1';   // без деления
                            nameController.text = '${device.name} mA';
                            break;
                          case SensorType.voltage:
                            dpsController.text = '22';    // DPS 22 — напряжение
                            dividerController.text = '10';  // ÷10 для V
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
                // ====== Название датчика ======
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
                const SizedBox(height: 8),
                // ====== DPS индекс ======
                TextField(controller: dpsController, decoration: const InputDecoration(labelText: 'DPS индекс'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                // ====== Делитель ======
                TextField(controller: dividerController, decoration: const InputDecoration(labelText: 'Делитель'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                // Парсим введённые значения
                final dpsIndex = int.tryParse(dpsController.text) ?? 21;
                final divider = double.tryParse(dividerController.text) ?? 10;

                // Создаём новое устройство-датчик с теми же сетевыми параметрами
                final sensor = Device(
                  id: '${device.id}_sensor_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  type: DeviceType.sensor,
                  roomId: device.roomId,
                  isOnline: false,
                  state: DeviceState.offline,
                  deviceId: device.deviceId,       // Тот же Tuya ID
                  localKey: device.localKey,       // Тот же ключ
                  address: device.address,         // Тот же IP
                  version: device.version,
                  dpsIndex: dpsIndex,
                  properties: {
                    'sensorDps': dpsIndex,          // Какой DPS читать
                    'sensorDivider': divider,       // На сколько делить
                    'sensorType': selectedSensorType.name,  // Тип датчика
                  },
                );

                ref.read(devicesProvider.notifier).addDevice(sensor);
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

  /// Ручное обновление данных датчика по кнопке "Обновить".
  /// Отправляет запрос status() к устройству Tuya,
  /// читает нужный DPS (температура/влажность/мощность),
  /// делит на sensorDivider и сохраняет в properties.
  /// UI автоматически обновится через Riverpod.
  Future<void> _refreshSensorData(WidgetRef ref) async {
    try {
      // Создаём OutletDevice с параметрами датчика
      final outlet = OutletDevice(
        deviceId: device.deviceId ?? '',
        address: device.address ?? '',
        localKey: device.localKey ?? '',
        version: device.version ?? 3.3,
      );

      // Запрашиваем полный статус (все DPS)
      final result = await outlet.status();

      // Если DPS получены — обрабатываем
      if (result['dps'] != null) {
        final dps = result['dps'] as Map<String, dynamic>;

        // Берем DPS индекс из настроек датчика (по умолчанию 21)
        final sensorDps = device.properties['sensorDps'] ?? device.dpsIndex ?? 21;
        // Берем делитель (по умолчанию 10)
        final divider = device.properties['sensorDivider'] ?? 10;
        // Читаем значение DPS (поддерживает int и string ключи)
        final rawValue = dps[sensorDps] ?? dps[sensorDps.toString()];

        if (rawValue != null) {
          // Вычисляем реальное значение
          final value = (rawValue as num).toDouble() / divider;
          final sensorType = device.properties['sensorType'] as String?;

          // Обновляем properties устройства через провайдер
          final updated = device.copyWith(
            properties: {
              ...device.properties,
              if (sensorType == 'temperature') 'temperature': value,
              if (sensorType == 'humidity') 'humidity': value,
              if (sensorType == 'power') 'power': value,
            },
          );
          ref.read(devicesProvider.notifier).updateDevice(updated);
        }
      }
    } catch (e) {
      // Ошибки игнорируем — датчик может быть оффлайн
    }
  }

  /// Возвращает иконку Material Icons в зависимости от типа устройства.
  /// Для датчиков (DeviceType.sensor) иконка зависит от sensorType в properties:
  ///   temperature → термометр, humidity → капля, power → молния.
  /// Для остальных типов — стандартные иконки.
  IconData _getIconData() {
    switch (device.type) {
    // ====== Розетка ======
      case DeviceType.outlet:
        return Icons.power;

    // ====== Лампа ======
      case DeviceType.light:
        return Icons.lightbulb;

    // ====== Выключатели (1, 2, 3 клавиши) ======
      case DeviceType.switch1:
      case DeviceType.switch2:
      case DeviceType.switch3:
        return Icons.toggle_on;

    // ====== Датчик (универсальный тип) ======
      case DeviceType.sensor:
        final sensorType = device.properties['sensorType'] as String?;
        switch (sensorType) {
          case 'temperature':
            return Icons.thermostat;    // Термометр
          case 'humidity':
            return Icons.water_drop;    // Капля
          case 'power':
            return Icons.bolt;          // Молния
          default:
            return Icons.sensors;       // Общий значок датчика
        }

    // ====== Шторы ======
      case DeviceType.curtain:
        return Icons.blinds;

    // ====== Кондиционер ======
      case DeviceType.hvac:
        return Icons.ac_unit;

    // ====== Неизвестный тип ======
      default:
        return Icons.devices;
    }
  }
}