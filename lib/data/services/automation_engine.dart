import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';

class AutomationEngine {
  final SceneRepository _sceneRepository;
  final Talker _talker;
  Timer? _timer;
  DateTime? _lastCheck;

  AutomationEngine(this._sceneRepository, this._talker);

  void start() {
    _talker.info('AutomationEngine started');
    _lastCheck = DateTime.now().subtract(const Duration(minutes: 1));
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkTimeTriggers());
  }

  Future<void> _checkTimeTriggers() async {
    try {
      final now = DateTime.now();
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final scenes = await _sceneRepository.getAllScenes();

      for (final scene in scenes) {
        if (scene.trigger != null && scene.trigger!.type == TriggerType.time) {
          final triggerTime = scene.trigger!.time;

          // Проверяем что время совпадает и мы ещё не выполняли в эту минуту
          if (triggerTime == currentTime &&
              (_lastCheck == null || !_isSameMinute(_lastCheck!, now))) {
            _talker.info('Executing time-triggered scene: ${scene.name} at $currentTime');
            await _sceneRepository.executeScene(scene);
          }
        }
      }

      _lastCheck = now;
    } catch (e, stackTrace) {
      _talker.error('Error checking time triggers', e, stackTrace);
    }
  }

  bool _isSameMinute(DateTime a, DateTime b) {
    return a.hour == b.hour && a.minute == b.minute;
  }

  void stop() {
    _timer?.cancel();
    _talker.info('AutomationEngine stopped');
  }
}