/// Адаптивный опрос устройств — заменяет HeartbeatService и UdpListener.
/// Опрашивает все устройства параллельно через TuyaProtocol.getStatus().
/// Адаптивный интервал: 2с → 1мин → 5мин при ошибках.
/// Обнаруживает изменения состояния и обновляет UI через колбэки.
/// Поддерживает одноканальные, многоканальные устройства и датчики.
library;
import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/device.dart';
import '../protocols/tuya_protocol.dart';
import 'event_logger.dart';

class AdaptivePoller {
  final TuyaProtocol _tuyaProtocol;
  final Talker _talker;
  /// Колбэк при изменении состояния одноканального устройства (вкл/выкл)
  final void Function(String deviceId, bool isOn) _onStateChanged;
  /// Колбэк при изменении онлайн-статуса устройства
  final void Function(String deviceId, bool isOnline) _onOnlineChanged;
  /// Колбэк при изменении состояний многоканального устройства
  final void Function(String deviceId, List<bool> states) _onStatesChanged;
  /// Колбэк при обновлении данных датчика (температура, влажность, мощность...)
  final void Function(String deviceId, Map<String, dynamic> properties)? onSensorUpdate;

  /// Интервалы замедления при ошибках
  static const slowInterval = Duration(minutes: 1);
  static const verySlowInterval = Duration(minutes: 5);
  /// Количество ошибок до замедления
  static const maxErrorsBeforeSlowdown = 3;

  /// Базовый интервал опроса (из настроек, по умолчанию 2с)
  final Duration _normalInterval;
  /// Состояния опроса для каждого устройства
  final Map<String, _DevicePollState> _states = {};
  /// Таймер для периодического опроса
  Timer? _timer;
  /// Список устройств для опроса
  List<Device> _devices = [];

  AdaptivePoller(
      this._tuyaProtocol,
      this._talker,
      this._onStateChanged,
      this._onOnlineChanged,
      this._onStatesChanged, {
        this.onSensorUpdate,
        Duration normalInterval = const Duration(seconds: 2),
      }) : _normalInterval = normalInterval;

  /// Запускает периодический опрос. Первый опрос — немедленно.
  void start() {
    _talker.info('AdaptivePoller started (interval: ${_normalInterval.inSeconds}s)');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  /// Обновляет список устройств для опроса.
  void updateDevices(List<Device> devices) {
    _devices = devices;
    _states.removeWhere((id, _) => !devices.any((d) => d.id == id));
  }

  /// Принудительный сброс интервала опроса (после ручной команды).
  void forceReset(String deviceId) {
    final state = _states[deviceId];
    if (state != null) state.reset();
  }

  /// Проверяет, нужно ли опросить устройство, и запускает опрос.
  void _tick() {
    final now = DateTime.now();
    for (final device in _devices) {
      if (device.deviceId == null || device.address == null) continue;
      final state = _states.putIfAbsent(device.id, () => _DevicePollState(_normalInterval));
      if (now.isAfter(state.nextPollAt)) {
        _pollDevice(device, state);
      }
    }
  }

  /// Обновляет устройство в списке _devices (для актуализации properties).
  void _updateDeviceInList(Device updated) {
    final idx = _devices.indexWhere((d) => d.id == updated.id);
    if (idx != -1) _devices[idx] = updated;
  }

  /// Опрашивает одно устройство: получает DPS, анализирует изменения.
  /// Поддерживает одноканальные, многоканальные и датчики.
  Future<void> _pollDevice(Device device, _DevicePollState state) async {
    if (state.polling) return;
    state.polling = true;

    try {
      final result = await _tuyaProtocol.getStatus(device);

      if (result != null && result['dps'] != null) {
        state.onSuccess();
        _onOnlineChanged(device.id, true);

        final dps = result['dps'] as Map<String, dynamic>;

        // --- Многоканальные устройства ---
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
              }
            }
          }

          if (changed) {
            final updatedDevice = device.copyWith(
              properties: {...device.properties, 'states': currentStates, 'isOn': currentStates.any((s) => s)},
            );
            _updateDeviceInList(updatedDevice);
            _onStatesChanged(device.id, currentStates);
          }
        } else {
          // --- Одноканальные устройства ---
          final dpsIndex = device.dpsIndex ?? 1;
          final rawValue = dps[dpsIndex] ?? dps[dpsIndex.toString()];

          if (rawValue != null) {
            final realIsOn = rawValue == true || rawValue == 1;
            final currentIsOn = device.properties['isOn'] == true;

            if (realIsOn != currentIsOn) {
              _onStateChanged(device.id, realIsOn);
              EventLogger.log(
                deviceId: device.id,
                deviceName: device.name,
                event: realIsOn ? 'turnOn' : 'turnOff',
              );
            }
          }
          // --- Датчики ---
          if (device.type == DeviceType.sensor) {
            final sensorDps = device.properties['sensorDps'] ?? device.dpsIndex ?? 21;
            final divider = (device.properties['sensorDivider'] as num?)?.toDouble() ?? 10.0;
            final sensorType = device.properties['sensorType'] as String?;
            final rawValue = dps[sensorDps] ?? dps[sensorDps.toString()];

            if (rawValue != null) {
              final value = (rawValue as num).toDouble() / divider;

              final updatedProperties = {
                ...device.properties,
                if (sensorType == 'temperature') 'temperature': value,
                if (sensorType == 'humidity') 'humidity': value,
                if (sensorType == 'power') 'power': value,
                if (sensorType == 'current') 'current': value,
                if (sensorType == 'voltage') 'voltage': value,
              };

              final updated = device.copyWith(properties: updatedProperties);
              _updateDeviceInList(updated);
              onSensorUpdate?.call(device.id, updatedProperties);
            }
          }
        }
      } else {
        // Ошибка — устройство не ответило
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

  void stop() => _timer?.cancel();
}

/// Состояние опроса для одного устройства.
/// Хранит счётчик ошибок, текущий интервал, флаг опроса.
class _DevicePollState {
  int errorCount = 0;
  Duration interval;
  final Duration _normalInterval;
  DateTime nextPollAt = DateTime.now();
  bool polling = false;

  _DevicePollState(Duration normalInterval)
      : interval = normalInterval,
        _normalInterval = normalInterval;

  /// Сбрасывает счётчик ошибок и интервал на базовый.
  void onSuccess() {
    errorCount = 0;
    interval = _normalInterval;
    nextPollAt = DateTime.now().add(interval);
  }

  /// Увеличивает счётчик ошибок и замедляет интервал.
  void onError() {
    errorCount++;
    if (errorCount >= AdaptivePoller.maxErrorsBeforeSlowdown * 2) {
      interval = AdaptivePoller.verySlowInterval;
    } else if (errorCount >= AdaptivePoller.maxErrorsBeforeSlowdown) {
      interval = AdaptivePoller.slowInterval;
    }
    nextPollAt = DateTime.now().add(interval);
  }

  /// Принудительный сброс на базовый интервал (после ручной команды).
  void reset() {
    errorCount = 0;
    interval = _normalInterval;
    nextPollAt = DateTime.now();
  }
}