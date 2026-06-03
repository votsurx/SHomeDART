import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/device.dart';
import '../protocols/tuya_protocol.dart';
import 'event_logger.dart';
import '../local/database.dart';

class AdaptivePoller {
  final TuyaProtocol _tuyaProtocol;
  final Talker _talker;
  final void Function(String deviceId, bool isOn) _onStateChanged;
  final void Function(String deviceId, bool isOnline) _onOnlineChanged;
  final void Function(String deviceId, List<bool> states) _onStatesChanged;

  static const normalInterval = Duration(seconds: 2);
  static const slowInterval = Duration(minutes: 1);
  static const verySlowInterval = Duration(minutes: 5);
  static const maxErrorsBeforeSlowdown = 3;

  final Map<String, _DevicePollState> _states = {};
  Timer? _timer;
  List<Device> _devices = [];

  AdaptivePoller(
      this._tuyaProtocol,
      this._talker,
      this._onStateChanged,
      this._onOnlineChanged,
      this._onStatesChanged,
      );

  void start() {
    _talker.info('AdaptivePoller started');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void updateDevices(List<Device> devices) {
    _devices = devices;
    // Удаляем состояния для несуществующих устройств
    _states.removeWhere((id, _) => !devices.any((d) => d.id == id));
  }

  /// Принудительный сброс в быстрый режим (после команды из GUI)
  void forceReset(String deviceId) {
    final state = _states[deviceId];
    if (state != null) {
      state.reset();
      _talker.debug('Force reset poller for $deviceId');
    }
  }

  void _tick() {
    final now = DateTime.now();

    for (final device in _devices) {
      if (device.deviceId == null || device.address == null) continue;

      final state = _states.putIfAbsent(device.id, () => _DevicePollState());

      if (now.isAfter(state.nextPollAt)) {
        _pollDevice(device, state);
      }
    }
  }
  void _updateDeviceInList(Device updated) {
    final idx = _devices.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      _devices[idx] = updated;
    }
  }

  Future<void> _pollDevice(Device device, _DevicePollState state) async {
    if (state.polling) return;
    state.polling = true;

    try {
      final result = await _tuyaProtocol.getStatus(device);

      if (result != null && result['dps'] != null) {
        state.onSuccess();
        _onOnlineChanged(device.id, true);

        final dps = result['dps'] as Map<String, dynamic>;

        // Проверяем многоканальные устройства
        final channels = device.properties['channels'] as int?;
        if (channels != null && channels > 1) {
          final currentStates = List<bool>.from(device.properties['states'] ?? List.filled(channels, false));
          var changed = false;

          for (var i = 1; i <= channels; i++) {
            final val = dps[i] ?? dps[i.toString()];
            if (val != null) {
              final isOn = val == true || val == 1;
              if (i - 1 < currentStates.length && currentStates[i - 1] != isOn) {
                currentStates[i - 1] = isOn;
                changed = true;
                _talker.info('Channel $i changed: ${device.name} -> ${isOn ? "ON" : "OFF"}');
              }
            }
          }

          if (changed) {
            final updatedDevice = device.copyWith(
              properties: {
                ...device.properties,
                'states': currentStates,
                'isOn': currentStates.any((s) => s),
              },
            );
            _updateDeviceInList(updatedDevice);
            _onStatesChanged(device.id, currentStates);
            _talker.info('States updated for ${device.name}: $currentStates');
          }
        } else {
          // Одноканальное устройство
          final dpsIndex = device.dpsIndex ?? 1;
          final rawValue = dps[dpsIndex] ?? dps[dpsIndex.toString()];

          if (rawValue != null) {
            final realIsOn = rawValue == true || rawValue == 1;
            final currentIsOn = device.properties['isOn'] == true;

            if (realIsOn != currentIsOn) {
              _talker.info('State changed: ${device.name} -> ${realIsOn ? "ON" : "OFF"}');
              _onStateChanged(device.id, realIsOn);
              EventLogger.log(
                deviceId: device.id,
                deviceName: device.name,
                event: realIsOn ? 'turnOn' : 'turnOff',
              );
            }
          }
        }
      } else {
        state.onError();
        _onOnlineChanged(device.id, false);
      }
    } catch (e) {
      state.onError();
      _onOnlineChanged(device.id, false);
    } finally {
      state.polling = false;
    }
  }

  void stop() {
    _timer?.cancel();
  }
}

class _DevicePollState {
  int errorCount = 0;
  Duration interval = AdaptivePoller.normalInterval;
  DateTime nextPollAt = DateTime.now();
  bool polling = false; // ← Защита от параллельных опросов

  void onSuccess() {
    errorCount = 0;
    interval = AdaptivePoller.normalInterval;
    nextPollAt = DateTime.now().add(interval);
  }

  void onError() {
    errorCount++;
    if (errorCount >= AdaptivePoller.maxErrorsBeforeSlowdown * 2) {
      interval = AdaptivePoller.verySlowInterval;
    } else if (errorCount >= AdaptivePoller.maxErrorsBeforeSlowdown) {
      interval = AdaptivePoller.slowInterval;
    }
    nextPollAt = DateTime.now().add(interval);
  }

  void reset() {
    errorCount = 0;
    interval = AdaptivePoller.normalInterval;
    nextPollAt = DateTime.now();
  }
}