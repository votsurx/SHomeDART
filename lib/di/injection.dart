import 'package:get_it/get_it.dart';
import '../domain/events/device_event_bus.dart';
import '../data/local/secure_storage/encrypted_keys.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Синглтоны
  getIt.registerLazySingleton<DeviceEventBus>(() => DeviceEventBus());
  getIt.registerLazySingleton<EncryptedKeys>(() => EncryptedKeys());

  // Репозитории и сервисы будем добавлять по мере создания
}