/// Провайдер списка устройств на Riverpod.
/// Центральный узел управления устройствами: вкл/выкл, многоканальные, датчики.
/// Использует прямое управление через TuyaProtocol (без CommandHandler).
/// Логирует все действия через EventLogger.
/// При старте все устройства переводятся в offline — AdaptivePoller актуализирует состояние.
library;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/protocols/tuya_protocol.dart';
import '../../di/injection.dart';
import '../../data/services/event_logger.dart';

/// Глобальный провайдер списка устройств.
/// Все виджеты, подписанные через ref.watch, перестраиваются при изменении state.
final devicesProvider = StateNotifierProvider<DevicesNotifier, List<Device>>((ref) {
  return DevicesNotifier();
});

/// Управляет списком устройств: загрузка, добавление, удаление, вкл/выкл, перестановка.
/// Поддерживает многоканальные устройства и датчики.
class DevicesNotifier extends StateNotifier<List<Device>> {
  final DeviceRepository _repository = getIt<DeviceRepository>();
  final TuyaProtocol _tuyaProtocol = getIt<TuyaProtocol>();

  void Function(String)? onCommandSent;

  DevicesNotifier() : super([]) {
    _loadDevices();
  }

  List<Device> get devices => state;

  // ═══════════ ЗАГРУЗКА И ПОРЯДОК ═══════════

  Future<void> _loadDevices() async {
    final devices = await _repository.getAllDevices();
    state = devices.map((d) => d.copyWith(
      isOnline: false,
      state: DeviceState.offline,
      properties: {
        ...d.properties,
        'isOn': false,
        if (d.properties['states'] != null)
          'states': List<bool>.filled((d.properties['channels'] as int?) ?? 1, false),
      },
    )).toList();
    _restoreOrder();
  }

  /// Переставляет устройства и сохраняет порядок.
  void reorderDevices(int oldIndex, int newIndex) {
    final list = [...state];
    if (oldIndex < newIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _saveOrder();
  }

  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = state.map((d) => d.id).toList();
    await prefs.setString('device_order', jsonEncode(ids));
  }

  Future<void> _restoreOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderJson = prefs.getString('device_order');
    if (orderJson == null) return;

    final orderIds = (jsonDecode(orderJson) as List).cast<String>();
    final list = [...state];

    list.sort((a, b) {
      final aIndex = orderIds.indexOf(a.id);
      final bIndex = orderIds.indexOf(b.id);
      if (aIndex == -1 && bIndex == -1) return 0;
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });

    state = list;
  }

  // ═══════════ ОБНОВЛЕНИЕ СОСТОЯНИЙ ═══════════

  void updateDeviceLocal(Device device) {
    state = state.map((d) => d.id == device.id ? device : d).toList();
  }

  void updateDeviceState(String id, bool isOn) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {
        ...device.properties,
        'isOn': isOn,
        if (device.properties['states'] != null)
          'states': device.properties['states'],
      },
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  void updateDeviceStates(String id, List<bool> states) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {...device.properties, 'states': states, 'isOn': states.any((s) => s)},
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  void updateOnlineState(String id, bool isOnline) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      isOnline: isOnline,
      state: isOnline ? DeviceState.online : DeviceState.offline,
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  void updateDeviceProperties(String id, Map<String, dynamic> properties) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(properties: properties);
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  // ═══════════ CRUD ═══════════

  Future<void> addDevice(Device device) async {
    await _repository.saveDevice(device);
    state = [...state, device];
    _saveOrder();
    EventLogger.log(event: 'deviceAdded', deviceId: device.id, deviceName: device.name);
  }

  Future<void> updateDevice(Device device) async {
    await _repository.saveDevice(device);
    await _loadDevices();
    onCommandSent?.call(device.id);
  }

  Future<void> removeDevice(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(event: 'deviceRemoved', deviceId: id, deviceName: device.name);
    await _repository.deleteDevice(id);
    state = state.where((d) => d.id != id).toList();
    _saveOrder();
  }

  // ═══════════ КОМАНДЫ ═══════════

  Future<bool> turnOn(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOn');
    onCommandSent?.call(id);
    _updateLocalState(id, true);
    final success = await _tuyaProtocol.turnOn(device);
    if (!success) _updateLocalState(id, false);
    return success;
  }

  Future<bool> turnOff(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOff');
    onCommandSent?.call(id);
    _updateLocalState(id, false);
    final success = await _tuyaProtocol.turnOff(device);
    if (!success) _updateLocalState(id, true);
    return success;
  }

  Future<bool> setSwitchChannel(String id, int channel, bool value) async {
    final device = state.firstWhere((d) => d.id == id);
    onCommandSent?.call(id);
    _updateChannelState(id, channel, value);
    final success = await _tuyaProtocol.setSwitchChannel(device, channel, value);
    if (!success) _updateChannelState(id, channel, !value);
    return success;
  }

  void _updateLocalState(String id, bool isOn) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {...device.properties, 'isOn': isOn},
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  void _updateChannelState(String id, int channel, bool value) {
    final device = state.firstWhere((d) => d.id == id);
    final states = List<bool>.from(device.properties['states'] ?? [false, false]);
    if (channel <= states.length) {
      states[channel - 1] = value;
    }
    final updated = device.copyWith(
      properties: {...device.properties, 'states': states},
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  Future<bool> pingDevice(String id) async {
    return await _repository.pingDevice(id);
  }

  Future<bool> setCurtainPosition(String id, int position) async {
    final device = state.firstWhere((d) => d.id == id);
    final success = await _tuyaProtocol.setCurtainPosition(device, position);
    if (success) {
      final updated = device.copyWith(
        properties: {...device.properties, 'position': position},
      );
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
    return success;
  }

  Future<bool> setHvac(String id, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async {
    return await _repository.setHvac(id, power: power, targetTemp: targetTemp, mode: mode, fanSpeed: fanSpeed);
  }

  Future<bool> setBrightness(String id, int brightness) async {
    final device = state.firstWhere((d) => d.id == id);
    final success = await _tuyaProtocol.setBrightness(device, brightness);
    if (success) {
      final updated = device.copyWith(
        properties: {...device.properties, 'brightness': brightness, 'isOn': brightness > 0},
      );
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
    return success;
  }

  Future<Map<String, dynamic>?> getDeviceDps(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    return await _tuyaProtocol.getStatus(device);
  }
}