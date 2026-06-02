import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/device.dart';
import '../protocols/tuya_protocol.dart';

class AdaptivePoller {
  final TuyaProtocol _tuyaProtocol;
  final Talker _talker;
  final void Function(String deviceId, bool isOn) _onStateChanged;
  final void Function(String deviceId, bool isOnline) _onOnlineChanged;

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

  Future<void> _pollDevice(Device device, _DevicePollState state) async {
    if (state.polling) return; // Уже опрашивается — пропускаем
    state.polling = true;

    try {
      final result = await _tuyaProtocol.getStatus(device);

      if (result != null && result['dps'] != null) {
        // УСПЕХ! Сброс в нормальный режим
        state.onSuccess();
        _onOnlineChanged(device.id, true);

        final dps = result['dps'] as Map<String, dynamic>;
        final dpsIndex = device.dpsIndex ?? 1;
        final rawValue = dps[dpsIndex] ?? dps[dpsIndex.toString()];

        if (rawValue != null) {
          final realIsOn = rawValue == true || rawValue == 1;
          final currentIsOn = device.properties['isOn'] == true;

          if (realIsOn != currentIsOn) {
            _talker.info('State changed: ${device.name} -> ${realIsOn ? "ON" : "OFF"}');
            _onStateChanged(device.id, realIsOn);
          }
        }
      } else {
        // Ошибка
        state.onError();
        _onOnlineChanged(device.id, false);
        _talker.debug('Poll failed for ${device.name}, interval: ${state.interval}');
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