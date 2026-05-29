import '../models/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getAllDevices();
  Future<Device?> getDeviceById(String id);
  Future<void> saveDevice(Device device);
  Future<void> updateDeviceState(String id, DeviceState state);
  Future<void> deleteDevice(String id);
}