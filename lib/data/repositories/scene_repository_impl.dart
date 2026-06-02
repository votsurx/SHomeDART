import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../domain/repositories/device_repository.dart';
import '../local/database.dart';
import '../mappers/scene_mapper.dart';

class SceneRepositoryImpl implements SceneRepository {
  final DeviceRepository _deviceRepository;
  final Map<String, Scene> _scenes = {};

  SceneRepositoryImpl(this._deviceRepository);

  @override
  Future<List<Scene>> getAllScenes() async {
    if (_scenes.isEmpty) {
      final entities = await AppDatabase.getAllScenes();
      for (final e in entities) {
        _scenes[e.id] = SceneMapper.toDomain(e);
      }
    }
    return _scenes.values.toList();
  }

  @override
  Future<void> saveScene(Scene scene) async {
    _scenes[scene.id] = scene;
    await AppDatabase.insertScene(SceneMapper.toEntity(scene));
    print('Saved scene: ${scene.name}, total scenes: ${_scenes.length}');
  }

  @override
  Future<void> deleteScene(String id) async {
    _scenes.remove(id);
    await AppDatabase.deleteScene(id);
  }

  @override
  Future<void> executeScene(Scene scene) async {
    for (final action in scene.actions) {
      switch (action.command) {
        case 'turnOn': await _deviceRepository.turnOn(action.deviceId);
        case 'turnOff': await _deviceRepository.turnOff(action.deviceId);
      }
    }
  }
}