import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/events/device_event_bus.dart';

import 'device_command.dart';

class DeviceCommandHandler {
  final DeviceRepository _repository;
  final DeviceEventBus _eventBus;
  final Talker _talker;

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration timeout = Duration(seconds: 5);

  DeviceCommandHandler(this._repository, this._eventBus, this._talker);

  Future<bool> execute(DeviceCommand command) async {
    _talker.info('Executing command: ${command.type} on device ${command.deviceId}');

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final success = await _sendCommand(command);

        if (success) {
          _talker.info('Command ${command.type} succeeded on ${command.deviceId} (attempt ${attempt + 1})');
          return true;
        }
      } catch (e) {
        _talker.warning('Command ${command.type} failed (attempt ${attempt + 1}): $e');
      }

      if (attempt < maxRetries - 1) {
        await Future.delayed(retryDelay * (attempt + 1));
      }
    }

    _talker.error('Command ${command.type} failed after $maxRetries attempts');
    return false;
  }

  Future<bool> _sendCommand(DeviceCommand command) async {
    switch (command.type) {
      case DeviceCommandType.turnOn:
        return await _repository.turnOn(command.deviceId);
      case DeviceCommandType.turnOff:
        return await _repository.turnOff(command.deviceId);
      case DeviceCommandType.setSwitchChannel:
        return await _repository.setSwitchChannel(
          command.deviceId,
          command.params!['channel'],
          command.params!['state'],
        );
      case DeviceCommandType.setCurtainPosition:
        return await _repository.setCurtainPosition(
          command.deviceId,
          command.params!['position'],
        );
      case DeviceCommandType.setBrightness:
        return await _repository.setBrightness(
          command.deviceId,
          command.params!['brightness'],
        );
    }
  }
}
