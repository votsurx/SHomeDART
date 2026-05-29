import 'package:get_it/get_it.dart';
import '../domain/events/device_event_bus.dart';
import '../data/local/secure_storage/encrypted_keys.dart';

void registerSingletons(GetIt getIt) {
  getIt.registerLazySingleton<DeviceEventBus>(() => DeviceEventBus());
  getIt.registerLazySingleton<EncryptedKeys>(() => EncryptedKeys());
}