import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../domain/events/device_event_bus.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/repositories/room_repository.dart';
import '../domain/services/mqtt_service_interface.dart';
import '../domain/commands/device_command_handler.dart';
import '../data/local/secure_storage/encrypted_keys.dart';
import '../data/protocols/tuya_protocol.dart';
import '../data/repositories/device_repository_impl.dart';
import '../data/repositories/room_repository_impl.dart';
import '../data/services/mqtt_service_impl.dart';
import '../domain/repositories/scene_repository.dart';
import '../data/repositories/scene_repository_impl.dart';
import '../data/services/automation_engine.dart';



final getIt = GetIt.instance;

void configureDependencies() {
  //Automatization
  getIt.registerLazySingleton<AutomationEngine>(
        () => AutomationEngine(getIt<SceneRepository>(), getIt<Talker>()),
  );

  // Logger
  final talker = TalkerFlutter.init();
  getIt.registerLazySingleton<Talker>(() => talker);

  // В configureDependencies:
  getIt.registerLazySingleton<SceneRepository>(
        () => SceneRepositoryImpl(getIt<DeviceRepository>()),
  );

  // Синглтоны
  getIt.registerLazySingleton<DeviceEventBus>(() => DeviceEventBus());
  getIt.registerLazySingleton<EncryptedKeys>(() => EncryptedKeys());

  // Protocols
  getIt.registerLazySingleton<TuyaProtocol>(() => TuyaProtocol(getIt<Talker>()));

  // Services
  getIt.registerLazySingleton<MqttService>(() => MqttServiceImpl(getIt<Talker>()));

  // Command Handler
  getIt.registerLazySingleton<DeviceCommandHandler>(
        () => DeviceCommandHandler(getIt<DeviceRepository>(), getIt<DeviceEventBus>(), getIt<Talker>()),
  );

  // Repositories
  getIt.registerLazySingleton<DeviceRepository>(
        () => DeviceRepositoryImpl(getIt<TuyaProtocol>()),
  );
  getIt.registerLazySingleton<RoomRepository>(
        () => RoomRepositoryImpl(),
  );
}