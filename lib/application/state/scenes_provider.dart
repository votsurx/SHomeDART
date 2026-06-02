import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/event_logger.dart';
import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../di/injection.dart';

final scenesProvider = StateNotifierProvider<ScenesNotifier, List<Scene>>((ref) {
  return ScenesNotifier();
});

class ScenesNotifier extends StateNotifier<List<Scene>> {
  final SceneRepository _repository = getIt<SceneRepository>();

  ScenesNotifier() : super([]) {
    _loadScenes();
  }

  Future<void> _loadScenes() async {
    state = await _repository.getAllScenes();
  }

  Future<void> addScene(Scene scene) async {
    await _repository.saveScene(scene);
    await _loadScenes();
    EventLogger.log(event: 'sceneCreated', sceneName: scene.name);
  }

  Future<void> executeScene(String id) async {
    final scene = state.firstWhere((s) => s.id == id);
    await _repository.executeScene(scene);

    // Логируем выполнение сцены
    await EventLogger.log(
      deviceId: '',
      deviceName: '',
      event: 'scene',
      sceneName: scene.name,
    );
  }

  Future<void> deleteScene(String id) async {
    final scene = state.firstWhere((s) => s.id == id);
    EventLogger.log(event: 'sceneDeleted', sceneName: scene.name);
    await _repository.deleteScene(id);
    state = state.where((s) => s.id != id).toList();
  }
}