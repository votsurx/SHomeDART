import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../protocols/tuya_protocol.dart';
import '../local/database.dart';
import '../mappers/device_mapper.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final TuyaProtocol _tuyaProtocol;
  final Map<String, Device> _devices = {};

  DeviceRepositoryImpl(this._tuyaProtocol);

  @override
  Future<Map<String, dynamic>?> getDeviceDps(String id) async {
    final device = _devices[id];
    if (device == null) return null;
    return await _tuyaProtocol.getStatus(device);
  }

  @override
  Future<void> updateDeviceProperties(String id, Map<String, dynamic> properties) async {
    final device = _devices[id];
    if (device != null) {
      _devices[id] = device.copyWith(properties: properties);
    }
  }

  @override
  Future<List<Device>> getAllDevices() async {
    if (_devices.isEmpty) {
      final entities = await AppDatabase.getAllDevices();
      for (final entity in entities) {
        _devices[entity.id] = DeviceMapper.toDomain(entity);
      }
    }
    return _devices.values.toList();
  }

  @override
  Future<Device?> getDeviceById(String id) async {
    if (!_devices.containsKey(id)) {
      await getAllDevices();
    }
    return _devices[id];
  }

  @override
  Future<void> saveDevice(Device device) async {
    _devices[device.id] = device;
    await AppDatabase.insertDevice(DeviceMapper.toEntity(device));
  }

  @override
  Future<void> updateDeviceState(String id, DeviceState state) async {
    final device = _devices[id];
    if (device != null) {
      _devices[id] = device.copyWith(state: state);
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
  }

  @override
  Future<void> deleteDevice(String id) async {
    _devices.remove(id);
    await AppDatabase.deleteDevice(id);
  }

  @override
  Future<bool> turnOn(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.turnOn(device);
    if (success) await updateDeviceState(id, DeviceState.online);
    return success;
  }

  @override
  Future<bool> turnOff(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.turnOff(device);
    if (success) await updateDeviceState(id, DeviceState.online);
    return success;
  }

  @override
  Future<bool?> getDeviceStatus(String id) async {
    final device = _devices[id];
    if (device == null) return null;
    return await _tuyaProtocol.ping(device);
  }

  @override
  Future<bool> pingDevice(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    return await _tuyaProtocol.ping(device);
  }

  @override
  Future<bool> setSwitchChannel(String id, int channel, bool state) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setSwitchChannel(device, channel, state);
    if (success) {
      final states = List<bool>.from(device.properties['states'] ?? []);
      if (channel <= states.length) {
        states[channel - 1] = state;
        _devices[id] = device.copyWith(properties: {...device.properties, 'states': states});
        await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
      }
    }
    return success;
  }

  @override
  Future<bool> setCurtainPosition(String id, int position) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setCurtainPosition(device, position);
    if (success) {
      _devices[id] = device.copyWith(properties: {...device.properties, 'position': position});
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }

  @override
  Future<bool> setHvac(String id, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setHvac(device, power: power, targetTemp: targetTemp, mode: mode, fanSpeed: fanSpeed);
    if (success) {
      _devices[id] = device.copyWith(properties: {...device.properties, 'isOn': power, 'targetTemp': targetTemp, 'mode': mode, 'fanSpeed': fanSpeed});
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }

  @override
  Future<bool> setBrightness(String id, int brightness) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setBrightness(device, brightness);
    if (success) {
      _devices[id] = device.copyWith(properties: {...device.properties, 'brightness': brightness, 'isOn': brightness > 0});
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }
}