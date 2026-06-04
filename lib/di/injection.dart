/// Контейнер внедрения зависимостей (Dependency Injection) на базе GetIt.
/// Регистрирует все сервисы, репозитории и протоколы как синглтоны.
/// Порядок регистрации важен: сначала базовые зависимости, потом те что от них зависят.
///
/// Используется везде через getIt<T>() — в провайдерах, сервисах, экранах.
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../domain/events/device_event_bus.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/repositories/room_repository.dart';
import '../domain/services/mqtt_service_interface.dart';
import '../data/local/secure_storage/encrypted_keys.dart';
import '../data/protocols/tuya_protocol.dart';
import '../data/repositories/device_repository_impl.dart';
import '../data/repositories/room_repository_impl.dart';
import '../data/services/mqtt_service_impl.dart';
import '../domain/repositories/scene_repository.dart';
import '../data/repositories/scene_repository_impl.dart';
import '../data/services/automation_engine.dart';
import '../data/services/timer_engine.dart';

/// Глобальный экземпляр GetIt для доступа ко всем зависимостям.
final getIt = GetIt.instance;

/// Регистрирует все зависимости приложения.
/// Вызывается один раз в main.dart перед запуском.
void configureDependencies() {
  // ============ Таймеры ============
  /// Движок отложенных команд (вкл/выкл по расписанию).
  /// Зависит от: DeviceRepository, Talker.
  getIt.registerLazySingleton<TimerEngine>(
        () => TimerEngine(getIt<DeviceRepository>(), getIt<Talker>()),
  );

  // ============ Автоматизация ============
  /// Движок выполнения сцен по времени.
  /// Зависит от: SceneRepository, Talker.
  getIt.registerLazySingleton<AutomationEngine>(
        () => AutomationEngine(getIt<SceneRepository>(), getIt<Talker>()),
  );

  // ============ Логгер ============
  /// TalkerFlutter — логирование в консоль и файл.
  final talker = TalkerFlutter.init();
  getIt.registerLazySingleton<Talker>(() => talker);

  // ============ Репозиторий сцен ============
  /// Зависит от: DeviceRepository (для выполнения команд).
  getIt.registerLazySingleton<SceneRepository>(
        () => SceneRepositoryImpl(getIt<DeviceRepository>()),
  );

  // ============ Синглтоны ============
  /// Шина событий (DeviceOnline, DeviceOffline, DeviceStateChanged).
  getIt.registerLazySingleton<DeviceEventBus>(() => DeviceEventBus());
  /// Защищённое хранилище ключей (flutter_secure_storage).
  getIt.registerLazySingleton<EncryptedKeys>(() => EncryptedKeys());

  // ============ Протоколы ============
  /// Протокол Tuya — обёртка над tinytuya для управления устройствами.
  getIt.registerLazySingleton<TuyaProtocol>(() => TuyaProtocol(getIt<Talker>()));

  // ============ Сервисы ============
  /// MQTT клиент (заготовка, не используется активно).
  getIt.registerLazySingleton<MqttService>(() => MqttServiceImpl(getIt<Talker>()));

  // ============ Репозитории ============
  /// Репозиторий устройств: кэш + БД + TuyaProtocol.
  getIt.registerLazySingleton<DeviceRepository>(
        () => DeviceRepositoryImpl(getIt<TuyaProtocol>()),
  );
  /// Репозиторий комнат: кэш + БД.
  getIt.registerLazySingleton<RoomRepository>(
        () => RoomRepositoryImpl(),
  );
}