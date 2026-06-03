import 'package:flutter_test/flutter_test.dart';
import 'package:shome/data/services/adaptive_poller.dart';
import 'package:shome/data/protocols/tuya_protocol.dart';
import 'package:shome/domain/models/device.dart';
import 'package:talker/talker.dart';

// Мок TuyaProtocol
class MockTuyaProtocol implements TuyaProtocol {
  final Map<String, Map<String, dynamic>> _deviceStates = {};
  int getStatusCallCount = 0;

  void setDeviceState(String deviceId, bool isOn) {
    _deviceStates[deviceId] = {
      'dps': {1: isOn},
    };
  }

  void setMultiChannelState(String deviceId, List<bool> states) {
    final dps = <int, bool>{};
    for (var i = 0; i < states.length; i++) {
      dps[i + 1] = states[i];
    }
    _deviceStates[deviceId] = {'dps': dps};
  }

  @override
  Future<Map<String, dynamic>?> getStatus(Device device) async {
    getStatusCallCount++;
    return _deviceStates[device.id];
  }

  @override
  Future<bool> turnOn(Device device) async => true;

  @override
  Future<bool> turnOff(Device device) async => true;

  @override
  Future<bool> ping(Device device) async => true;

  @override
  Future<bool> setSwitchChannel(Device device, int channel, bool state) async => true;

  @override
  Future<bool> setCurtainPosition(Device device, int position) async => true;

  @override
  Future<bool> setHvac(Device device, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async => true;

  @override
  Future<bool> setBrightness(Device device, int brightness) async => true;

  @override
  Future<Map<String, dynamic>?> getDeviceDps(Device device) async => _deviceStates[device.id];
}

void main() {
  group('AdaptivePoller', () {
    late MockTuyaProtocol mockTuya;
    late Talker talker;
    late List<String> stateChanges;
    late List<String> onlineChanges;
    late List<Map<String, dynamic>> statesChanges;

    setUp(() {
      mockTuya = MockTuyaProtocol();
      talker = Talker();
      stateChanges = [];
      onlineChanges = [];
      statesChanges = [];
    });

    test('Обнаружение включения устройства', () async {
      final device = Device(
        id: 'dev_1',
        name: 'Test',
        type: DeviceType.outlet,
        roomId: 'living',
        isOnline: true,
        state: DeviceState.online,
        deviceId: 'bf123',
        localKey: 'key123',
        address: '192.168.1.1',
        version: 3.3,
        properties: {'isOn': false},
      );

      mockTuya.setDeviceState(device.id, true);

      final poller = AdaptivePoller(
        mockTuya,
        talker,
            (deviceId, isOn) => stateChanges.add('$deviceId:$isOn'),
            (deviceId, isOnline) => onlineChanges.add('$deviceId:$isOnline'),
            (deviceId, states) => statesChanges.add({'id': deviceId, 'states': states}),
        normalInterval: const Duration(milliseconds: 100),
      );

      poller.updateDevices([device]);
      poller.start();

      // Ждём, пока поллер опросит устройство
      await Future.delayed(const Duration(seconds: 1));

      poller.stop();

      expect(mockTuya.getStatusCallCount, greaterThan(0));
      expect(stateChanges.length, 1);
      expect(stateChanges.first, 'dev_1:true');
      expect(onlineChanges.first, 'dev_1:true');
    });

    test('Обнаружение выключения устройства', () async {
      final device = Device(
        id: 'dev_2',
        name: 'Test',
        type: DeviceType.outlet,
        roomId: 'living',
        isOnline: true,
        state: DeviceState.online,
        deviceId: 'bf456',
        localKey: 'key456',
        address: '192.168.1.2',
        version: 3.3,
        properties: {'isOn': true},
      );

      mockTuya.setDeviceState(device.id, false);

      final poller = AdaptivePoller(
        mockTuya,
        talker,
            (deviceId, isOn) => stateChanges.add('$deviceId:$isOn'),
            (deviceId, isOnline) => onlineChanges.add('$deviceId:$isOnline'),
            (deviceId, states) => statesChanges.add({'id': deviceId, 'states': states}),
        normalInterval: const Duration(milliseconds: 100),
      );

      poller.updateDevices([device]);
      poller.start();

      await Future.delayed(const Duration(seconds: 1));

      poller.stop();

      expect(stateChanges.first, 'dev_2:false');
    });

    test('Многоканальное устройство — изменение одного канала', () async {
      final device = Device(
        id: 'switch_1',
        name: 'Switch',
        type: DeviceType.switch2,
        roomId: 'living',
        isOnline: true,
        state: DeviceState.online,
        deviceId: 'bf789',
        localKey: 'key789',
        address: '192.168.1.3',
        version: 3.3,
        properties: {
          'channels': 2,
          'states': [false, false],
        },
      );

      mockTuya.setMultiChannelState(device.id, [true, false]);

      final poller = AdaptivePoller(
        mockTuya,
        talker,
            (deviceId, isOn) => stateChanges.add('$deviceId:$isOn'),
            (deviceId, isOnline) => onlineChanges.add('$deviceId:$isOnline'),
            (deviceId, states) => statesChanges.add({'id': deviceId, 'states': states}),
        normalInterval: const Duration(milliseconds: 100),
      );

      poller.updateDevices([device]);
      poller.start();

      await Future.delayed(const Duration(seconds: 1));

      poller.stop();

      expect(statesChanges.length, 1);
      expect(statesChanges.first['states'], [true, false]);
    });

    test('Состояние не меняется — нет ложных срабатываний', () async {
      final device = Device(
        id: 'dev_3',
        name: 'Test',
        type: DeviceType.outlet,
        roomId: 'living',
        isOnline: true,
        state: DeviceState.online,
        deviceId: 'bf000',
        localKey: 'key000',
        address: '192.168.1.4',
        version: 3.3,
        properties: {'isOn': false},
      );

      mockTuya.setDeviceState(device.id, false);

      final poller = AdaptivePoller(
        mockTuya,
        talker,
            (deviceId, isOn) => stateChanges.add('$deviceId:$isOn'),
            (deviceId, isOnline) => onlineChanges.add('$deviceId:$isOnline'),
            (deviceId, states) => statesChanges.add({'id': deviceId, 'states': states}),
        normalInterval: const Duration(milliseconds: 100),
      );

      poller.updateDevices([device]);
      poller.start();

      await Future.delayed(const Duration(seconds: 1));

      poller.stop();

      expect(stateChanges.length, 0);
      expect(statesChanges.length, 0);
    });
  });
}