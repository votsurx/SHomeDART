class EventEntity {
  final int? id;
  final String event;        // Тип события
  final String? deviceId;
  final String? deviceName;
  final String? value;       // Значение (температура, энергия)
  final String? sceneName;
  final String? roomName;
  final String? timerName;
  final String timestamp;

  EventEntity({
    this.id,
    required this.event,
    this.deviceId,
    this.deviceName,
    this.value,
    this.sceneName,
    this.roomName,
    this.timerName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'event': event,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'value': value,
    'sceneName': sceneName,
    'roomName': roomName,
    'timerName': timerName,
    'timestamp': timestamp,
  };

  factory EventEntity.fromMap(Map<String, dynamic> map) => EventEntity(
    id: map['id'] as int?,
    event: map['event'] as String,
    deviceId: map['deviceId'] as String?,
    deviceName: map['deviceName'] as String?,
    value: map['value'] as String?,
    sceneName: map['sceneName'] as String?,
    roomName: map['roomName'] as String?,
    timerName: map['timerName'] as String?,
    timestamp: map['timestamp'] as String,
  );
}