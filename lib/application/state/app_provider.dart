import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../../di/injection.dart';

// Провайдер списка устройств
final devicesProvider = StateNotifierProvider<DevicesNotifier, List<Device>>((ref) {
  return DevicesNotifier();
});

class DevicesNotifier extends StateNotifier<List<Device>> {
  final DeviceRepository _repository = getIt<DeviceRepository>();

  DevicesNotifier() : super([]) {
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final devices = await _repository.getAllDevices();
    state = devices;
  }

  Future<void> addDevice(Device device) async {
    await _repository.saveDevice(device);
    state = [...state, device];
  }

  Future<bool> turnOn(String id) async {
    final success = await _repository.turnOn(id);
    if (success) {
      await _loadDevices();
    }
    return success;
  }

  Future<bool> turnOff(String id) async {
    final success = await _repository.turnOff(id);
    if (success) {
      await _loadDevices();
    }
    return success;
  }

  Future<bool> pingDevice(String id) async {
    return await _repository.pingDevice(id);
  }
}