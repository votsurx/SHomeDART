/// Провайдер списка устройств на Riverpod.
/// Центральный узел управления устройствами: вкл/выкл, многоканальные, датчики.
/// Использует прямое управление через TuyaProtocol (без CommandHandler).
/// Логирует все действия через EventLogger.
/// При старте все устройства переводятся в offline — AdaptivePoller актуализирует состояние.
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/protocols/tuya_protocol.dart';
import '../../di/injection.dart';
import '../../data/services/event_logger.dart';

/// Глобальный провайдер списка устройств.
/// Все виджеты, подписанные через ref.watch, перестраиваются при изменении state.
final devicesProvider = StateNotifierProvider<DevicesNotifier, List<Device>>((ref) {
  return DevicesNotifier();
});

/// Управляет списком устройств: загрузка, добавление, удаление, вкл/выкл.
/// Поддерживает многоканальные устройства и датчики.
class DevicesNotifier extends StateNotifier<List<Device>> {
  /// Репозиторий для сохранения в БД
  final DeviceRepository _repository = getIt<DeviceRepository>();
  /// Протокол Tuya для отправки команд напрямую (без CommandHandler)
  final TuyaProtocol _tuyaProtocol = getIt<TuyaProtocol>();

  /// Колбэк для сброса AdaptivePoller при ручной команде.
  /// Устанавливается из HomeScreen при создании поллера.
  void Function(String)? onCommandSent;

  /// Загружает устройства из БД при создании.
  /// При старте все устройства помечаются offline для показа wifi_off иконок.
  DevicesNotifier() : super([]) {
    _loadDevices();
  }

  /// Геттер для получения списка устройств из других провайдеров (RoomsNotifier)
  List<Device> get devices => state;

  /// Локально обновляет устройство в state (без сохранения в БД).
  /// Используется AdaptivePoller для обновления после опроса.
  void updateDeviceLocal(Device device) {
    state = state.map((d) => d.id == device.id ? device : d).toList();
  }

  /// Обновляет isOn для одноканального устройства.
  /// Вызывается из AdaptivePoller при обнаружении изменения состояния.
  void updateDeviceState(String id, bool isOn) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {
        ...device.properties,
        'isOn': isOn,
        // Если многоканальное — сохраняем текущие states
        if (device.properties['states'] != null)
          'states': device.properties['states'],
      },
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  /// Обновляет states для многоканального устройства.
  /// Принимает список bool для каждого канала.
  void updateDeviceStates(String id, List<bool> states) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {...device.properties, 'states': states, 'isOn': states.any((s) => s)},
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  /// Обновляет isOnline и state (online/offline) устройства.
  /// Вызывается из AdaptivePoller при успехе/ошибке опроса.
  void updateOnlineState(String id, bool isOnline) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      isOnline: isOnline,
      state: isOnline ? DeviceState.online : DeviceState.offline,
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  /// Загружает устройства из БД.
  /// При старте все устройства сбрасываются в offline — поллер обновит реальное состояние.
  Future<void> _loadDevices() async {
    final devices = await _repository.getAllDevices();
    state = devices.map((d) => d.copyWith(
      isOnline: false,
      state: DeviceState.offline,
      properties: {
        ...d.properties,
        'isOn': false,
        if (d.properties['states'] != null)
          'states': List<bool>.filled((d.properties['channels'] as int?) ?? 1, false),
      },
    )).toList();
  }

  /// Обновляет properties устройства (используется для датчиков).
  /// Вызывается из AdaptivePoller через onSensorUpdate колбэк.
  void updateDeviceProperties(String id, Map<String, dynamic> properties) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(properties: properties);
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  /// Добавляет новое устройство в список и БД. Логирует событие.
  Future<void> addDevice(Device device) async {
    await _repository.saveDevice(device);
    state = [...state, device];
    EventLogger.log(event: 'deviceAdded', deviceId: device.id, deviceName: device.name);
  }

  /// Включает устройство: оптимистично обновляет UI, отправляет команду.
  /// При ошибке откатывает состояние. Логирует. Сбрасывает поллер.
  Future<bool> turnOn(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOn');
    onCommandSent?.call(id);
    _updateLocalState(id, true);
    final success = await _tuyaProtocol.turnOn(device);
    if (!success) _updateLocalState(id, false);
    return success;
  }

  /// Выключает устройство: оптимистично обновляет UI, отправляет команду.
  /// При ошибке откатывает состояние. Логирует. Сбрасывает поллер.
  Future<bool> turnOff(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOff');
    onCommandSent?.call(id);
    _updateLocalState(id, false);
    final success = await _tuyaProtocol.turnOff(device);
    if (!success) _updateLocalState(id, true);
    return success;
  }

  /// Переключает канал многоканального устройства.
  /// Оптимистично обновляет UI, при ошибке откатывает.
  Future<bool> setSwitchChannel(String id, int channel, bool value) async {
    final device = state.firstWhere((d) => d.id == id);
    onCommandSent?.call(id);
    _updateChannelState(id, channel, value);
    final success = await _tuyaProtocol.setSwitchChannel(device, channel, value);
    if (!success) _updateChannelState(id, channel, !value);
    return success;
  }

  /// Внутренний метод: обновляет isOn в properties и сохраняет в БД.
  void _updateLocalState(String id, bool isOn) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {...device.properties, 'isOn': isOn},
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
    _repository.updateDeviceState(id, isOn ? DeviceState.online : DeviceState.online);
  }

  /// Внутренний метод: обновляет states многоканального устройства.
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

  /// Проверяет доступность устройства (пинг).
  Future<bool> pingDevice(String id) async {
    return await _repository.pingDevice(id);
  }

  /// Устанавливает позицию штор (0-100%).
  Future<bool> setCurtainPosition(String id, int position) async {
    final device = state.firstWhere((d) => d.id == id);
    final success = await _tuyaProtocol.setCurtainPosition(device, position);
    if (success) {
      final updated = device.copyWith(
        properties: {...device.properties, 'position': position},
      );
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
    return success;
  }

  /// Управляет кондиционером (HVAC): вкл/выкл, температура, режим, вентилятор.
  Future<bool> setHvac(String id, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async {
    return await _repository.setHvac(id, power: power, targetTemp: targetTemp, mode: mode, fanSpeed: fanSpeed);
  }

  /// Устанавливает яркость лампы (0-255).
  Future<bool> setBrightness(String id, int brightness) async {
    final device = state.firstWhere((d) => d.id == id);
    final success = await _tuyaProtocol.setBrightness(device, brightness);
    if (success) {
      final updated = device.copyWith(
        properties: {...device.properties, 'brightness': brightness, 'isOn': brightness > 0},
      );
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
    return success;
  }

  /// Получает DPS устройства (статус, показания датчиков).
  Future<Map<String, dynamic>?> getDeviceDps(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    return await _tuyaProtocol.getStatus(device);
  }

  /// Сохраняет изменения устройства в БД и перезагружает список.
  Future<void> updateDevice(Device device) async {
    await _repository.saveDevice(device);
    await _loadDevices();
  }

  /// Удаляет устройство из списка и БД. Логирует событие.
  Future<void> removeDevice(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(event: 'deviceRemoved', deviceId: id, deviceName: device.name);
    await _repository.deleteDevice(id);
    state = state.where((d) => d.id != id).toList();
  }
}