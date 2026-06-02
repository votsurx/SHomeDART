import '../local/database.dart';
import '../local/entities/event_entity.dart';

class EventLogger {
  static Future<void> log({
    required String event,
    String? deviceId,
    String? deviceName,
    String? value,
    String? sceneName,
    String? roomName,
    String? timerName,
  }) async {
    final entity = EventEntity(
      event: event,
      deviceId: deviceId,
      deviceName: deviceName,
      value: value,
      sceneName: sceneName,
      roomName: roomName,
      timerName: timerName,
      timestamp: DateTime.now().toIso8601String(),
    );
    await AppDatabase.insertEvent(entity);
  }
}