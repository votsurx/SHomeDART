import '../models/scene.dart';

abstract class SceneRepository {
  Future<List<Scene>> getAllScenes();
  Future<void> saveScene(Scene scene);
  Future<void> deleteScene(String id);
  Future<void> executeScene(Scene scene);
}