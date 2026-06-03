
import 'package:tinytuya/tinytuya.dart' hide Device;
import 'package:talker/talker.dart';
import '../../domain/models/device.dart';

class TuyaProtocol {
  final Talker _talker;

  TuyaProtocol(this._talker);

  OutletDevice _createOutletDevice(Device device) {
    return OutletDevice(
      deviceId: device.deviceId ?? '',
      address: device.address ?? '',
      localKey: device.localKey ?? '',
      version: device.version ?? 3.5,
    );
  }

  Future<bool> turnOn(Device device) async {
    try {
      _talker.info('Turning ON device: ${device.name}');
      final outlet = _createOutletDevice(device);
      if (device.dpsIndex == null || device.dpsIndex == 1) {
        await outlet.turnOn();
      } else {
        await outlet.setValue(index: device.dpsIndex!, value: true);
      }
      _talker.info('Device ${device.name} turned ON successfully');
      return true;
    } catch (e, stackTrace) {
      _talker.error('Failed to turn ON ${device.name}', e, stackTrace);
      return false;
    }
  }

  Future<bool> turnOff(Device device) async {
    try {
      _talker.info('Turning OFF device: ${device.name}');
      final outlet = _createOutletDevice(device);
      if (device.dpsIndex == null || device.dpsIndex == 1) {
        await outlet.turnOff();
      } else {
        await outlet.setValue(index: device.dpsIndex!, value: false);
      }
      _talker.info('Device ${device.name} turned OFF successfully');
      return true;
    } catch (e, stackTrace) {
      _talker.error('Failed to turn OFF ${device.name}', e, stackTrace);
      return false;
    }
  }

  Future<bool> ping(Device device) async {
    try {
      final outlet = _createOutletDevice(device);
      // Реальная проверка — setValue БЕЗ nowait, ждём ответ
      final result = await outlet.setValue(index: '1', value: null, nowait: false);

      if (result.containsKey('Error')) {
        _talker.debug('Device ${device.name} ping failed: ${result['Error']}');
        return false;
      }

      _talker.debug('Device ${device.name} ping successful');
      return true;
    } catch (e) {
      _talker.debug('Device ${device.name} ping failed: $e');
      return false;
    }
  }

  Future<bool> setSwitchChannel(Device device, int channel, bool state) async {
    try {
      _talker.info('Setting channel $channel to $state on ${device.name}');
      final outlet = _createOutletDevice(device);
      await outlet.setValue(index: channel, value: state);
      _talker.info('Channel $channel set successfully');
      return true;
    } catch (e) {
      _talker.error('Failed to set channel: $e');
      return false;
    }
  }

  Future<bool> setCurtainPosition(Device device, int position) async {
    try {
      final outlet = _createOutletDevice(device);
      await outlet.setValue(index: '1', value: position);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setHvac(Device device, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async {
    try {
      final outlet = _createOutletDevice(device);
      final modeMap = {'auto': 0, 'cool': 1, 'heat': 2, 'dry': 3, 'fan': 4};
      await outlet.setValue(index: '1', value: power ? 1 : 0);
      await outlet.setValue(index: '2', value: targetTemp.toInt());
      await outlet.setValue(index: '3', value: modeMap[mode] ?? 0);
      await outlet.setValue(index: '4', value: fanSpeed);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setBrightness(Device device, int brightness) async {
    try {
      final outlet = _createOutletDevice(device);
      await outlet.setDimmer(value: brightness);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDeviceDps(Device device) async {
    try {
      _talker.info('Getting DPS for device: ${device.name}');
      final outlet = _createOutletDevice(device);
      final result = await outlet.setDimmer(value: 255, nowait: true);
      return result;
    } catch (e) {
      return {'note': 'DPS reading not fully supported yet'};
    }
  }

  /// Получить полный статус устройства (все DPS)
  Future<Map<String, dynamic>?> getStatus(Device device) async {
    try {
      _talker.info('Getting status for: ${device.name}');
      final outlet = _createOutletDevice(device);
      // Используем status() как в тестовом проекте!
      final result = await outlet.status();
      _talker.debug('Status result: $result');
      return result;
    } catch (e) {
      _talker.error('Failed to get status for ${device.name}: $e');
      return null;
    }
  }
}
