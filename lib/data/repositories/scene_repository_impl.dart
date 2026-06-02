import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../domain/repositories/device_repository.dart';

class SceneRepositoryImpl implements SceneRepository {
  final DeviceRepository _deviceRepository;
  final Map<String, Scene> _scenes = {};

  SceneRepositoryImpl(this._deviceRepository);

  @override
  Future<List<Scene>> getAllScenes() async {
    return _scenes.values.toList();
  }

  @override
  Future<void> saveScene(Scene scene) async {
    _scenes[scene.id] = scene;
  }

  @override
  Future<void> deleteScene(String id) async {
    _scenes.remove(id);
  }

  @override
  Future<void> executeScene(Scene scene) async {
    for (final action in scene.actions) {
      switch (action.command) {
        case 'turnOn':
          await _deviceRepository.turnOn(action.deviceId);
          break;
        case 'turnOff':
          await _deviceRepository.turnOff(action.deviceId);
          break;
        case 'setBrightness':
          await _deviceRepository.setBrightness(action.deviceId, action.value as int);
          break;
      }
    }
  }
}