import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/protocols/tuya_protocol.dart';
import '../../di/injection.dart';
import '../../data/services/event_logger.dart';

final devicesProvider = StateNotifierProvider<DevicesNotifier, List<Device>>((ref) {
  return DevicesNotifier();
});

class DevicesNotifier extends StateNotifier<List<Device>> {
  final DeviceRepository _repository = getIt<DeviceRepository>();
  final TuyaProtocol _tuyaProtocol = getIt<TuyaProtocol>();

  /// Колбэк для сброса поллера при ручной команде
  void Function(String)? onCommandSent;

  DevicesNotifier() : super([]) {
    _loadDevices();
  }

  List<Device> get devices => state;

  void updateDeviceLocal(Device device) {
    state = state.map((d) => d.id == device.id ? device : d).toList();
  }

  void updateDeviceState(String id, bool isOn) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {
        ...device.properties,
        'isOn': isOn,
        // Если многоканальное — обновляем states
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

  Future<void> _loadDevices() async {
    final devices = await _repository.getAllDevices();
    // При старте все устройства считаем оффлайн
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
  }
  void updateDeviceProperties(String id, Map<String, dynamic> properties) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(properties: properties);
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  Future<void> addDevice(Device device) async {
    await _repository.saveDevice(device);
    state = [...state, device];
    EventLogger.log(event: 'deviceAdded', deviceId: device.id, deviceName: device.name);
  }

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
    _repository.updateDeviceState(id, isOn ? DeviceState.online : DeviceState.online);
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

  Future<void> updateDevice(Device device) async {
    await _repository.saveDevice(device);
    await _loadDevices();
  }

  Future<void> removeDevice(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(event: 'deviceRemoved', deviceId: id, deviceName: device.name);
    await _repository.deleteDevice(id);
    state = state.where((d) => d.id != id).toList();
  }
}