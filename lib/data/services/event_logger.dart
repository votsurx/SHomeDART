import '../local/database.dart';
import '../local/entities/event_entity.dart';

class EventLogger {
  static Future<void> log({
    required String deviceId,
    required String deviceName,
    required String event,
    String? sceneName,
  }) async {
    final entity = EventEntity(
      deviceId: deviceId,
      deviceName: deviceName,
      event: event,
      sceneName: sceneName,
      timestamp: DateTime.now().toIso8601String(),
    );
    await AppDatabase.insertEvent(entity);
  }
}