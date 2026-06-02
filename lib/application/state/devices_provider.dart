import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../domain/commands/device_command.dart';
import '../../domain/commands/device_command_handler.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/protocols/tuya_protocol.dart';
import '../../di/injection.dart';
import 'package:uuid/uuid.dart';
import '../../data/services/event_logger.dart';

final devicesProvider = StateNotifierProvider<DevicesNotifier, List<Device>>((ref) {
  return DevicesNotifier();
});

class DevicesNotifier extends StateNotifier<List<Device>> {
  final DeviceRepository _repository = getIt<DeviceRepository>();
  final DeviceCommandHandler _commandHandler = getIt<DeviceCommandHandler>();
  final TuyaProtocol _tuyaProtocol = getIt<TuyaProtocol>();
  final _uuid = const Uuid();

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
      properties: {...device.properties, 'isOn': isOn},
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
    state = devices;
  }

  Future<void> addDevice(Device device) async {
    await _repository.saveDevice(device);
    state = [...state, device];
  }

  // ✅ ВКЛ — оптимистично
  Future<bool> turnOn(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOn');
    onCommandSent?.call(id);
    _updateLocalState(id, true);

    final success = await _commandHandler.execute(DeviceCommand(
      id: _uuid.v4(),
      deviceId: id,
      type: DeviceCommandType.turnOn,
    ));

    if (!success) {
      _updateLocalState(id, false);
    }
    return success;
  }

  // ✅ ВЫКЛ — оптимистично
  Future<bool> turnOff(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOff');
    onCommandSent?.call(id);
    _updateLocalState(id, false);

    final success = await _commandHandler.execute(DeviceCommand(
      id: _uuid.v4(),
      deviceId: id,
      type: DeviceCommandType.turnOff,
    ));

    if (!success) {
      _updateLocalState(id, true);
    }
    return success;
  }

  // ✅ Многоканальные — оптимистично
  Future<bool> setSwitchChannel(String id, int channel, bool state) async {
    onCommandSent?.call(id);
    _updateChannelState(id, channel, state);

    final success = await _commandHandler.execute(DeviceCommand(
      id: _uuid.v4(),
      deviceId: id,
      type: DeviceCommandType.setSwitchChannel,
      params: {'channel': channel, 'state': state},
    ));

    if (!success) {
      _updateChannelState(id, channel, !state);
    }
    return success;
  }

  // ✅ Вспомогательные методы
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

  // Остальные методы
  Future<bool> pingDevice(String id) async {
    return await _repository.pingDevice(id);
  }

  Future<bool> setCurtainPosition(String id, int position) async {
    final success = await _commandHandler.execute(DeviceCommand(
      id: _uuid.v4(),
      deviceId: id,
      type: DeviceCommandType.setCurtainPosition,
      params: {'position': position},
    ));
    if (success) {
      final device = state.firstWhere((d) => d.id == id);
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
    final success = await _commandHandler.execute(DeviceCommand(
      id: _uuid.v4(),
      deviceId: id,
      type: DeviceCommandType.setBrightness,
      params: {'brightness': brightness},
    ));
    if (success) {
      final device = state.firstWhere((d) => d.id == id);
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
    await _repository.deleteDevice(id);
    state = state.where((d) => d.id != id).toList();
  }
}