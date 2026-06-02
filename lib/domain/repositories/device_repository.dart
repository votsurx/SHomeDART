import '../models/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getAllDevices();
  Future<Device?> getDeviceById(String id);
  Future<void> saveDevice(Device device);
  Future<void> updateDeviceState(String id, DeviceState state);
  Future<void> deleteDevice(String id);

  // Базовое управление
  Future<bool> turnOn(String id);
  Future<bool> turnOff(String id);
  Future<bool?> getDeviceStatus(String id);
  Future<bool> pingDevice(String id);

  // Многоканальные выключатели
  Future<bool> setSwitchChannel(String id, int channel, bool state);

  // Шторы
  Future<bool> setCurtainPosition(String id, int position);

  // Кондиционер
  Future<bool> setHvac(String id, {
    required bool power,
    required double targetTemp,
    required String mode,
    required int fanSpeed,
  });
  Future<void> updateDeviceProperties(String id, Map<String, dynamic> properties);
  // Лампа
  Future<bool> setBrightness(String id, int brightness);

  Future<Map<String, dynamic>?> getDeviceDps(String id);
}
