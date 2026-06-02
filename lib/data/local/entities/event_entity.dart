class EventEntity {
  final int? id;
  final String deviceId;
  final String deviceName;
  final String event;       // 'turnOn', 'turnOff', 'online', 'offline', 'error', 'scene'
  final String? sceneName;
  final String timestamp;

  EventEntity({
    this.id,
    required this.deviceId,
    required this.deviceName,
    required this.event,
    this.sceneName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'event': event,
    'sceneName': sceneName,
    'timestamp': timestamp,
  };

  factory EventEntity.fromMap(Map<String, dynamic> map) => EventEntity(
    id: map['id'] as int?,
    deviceId: map['deviceId'] as String,
    deviceName: map['deviceName'] as String,
    event: map['event'] as String,
    sceneName: map['sceneName'] as String?,
    timestamp: map['timestamp'] as String,
  );
}