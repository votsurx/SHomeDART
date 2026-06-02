import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:talker/talker.dart';
import 'dart:typed_data';

class TuyaScanner {
  final Talker _talker;
  final _devicesController = StreamController<List<Map<String, String>>>.broadcast();

  TuyaScanner(this._talker);

  Stream<List<Map<String, String>>> get devicesStream => _devicesController.stream;
  List<Map<String, String>> _foundDevices = [];

  Future<void> scanNetwork() async {
    _talker.info('Starting Tuya device scan...');
    _foundDevices = [];

    try {
      // Получаем локальный IP
      final interfaces = await NetworkInterface.list();
      String? localIp;
      String? subnet;

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.address.startsWith('127.')) {
            localIp = addr.address;
            subnet = localIp.substring(0, localIp.lastIndexOf('.') + 1);
            break;
          }
        }
        if (localIp != null) break;
      }

      if (localIp == null || subnet == null) {
        _talker.error('Could not determine local network');
        return;
      }

      _talker.info('Local IP: $localIp, scanning subnet: ${subnet}0/24');

      // Сканируем все IP в подсети
      for (var i = 1; i <= 254; i++) {
        final targetIp = '$subnet$i';
        _checkDevice(targetIp);
      }

      // Ждём 5 секунд для ответов
      await Future.delayed(const Duration(seconds: 5));

      _devicesController.add(List.from(_foundDevices));
      _talker.info('Scan complete. Found ${_foundDevices.length} devices');

    } catch (e, stackTrace) {
      _talker.error('Scan failed', e, stackTrace);
      _devicesController.add([]);
    }
  }

  Future<void> _checkDevice(String ip) async {
    try {
      final socket = await Socket.connect(ip, 6668, timeout: const Duration(milliseconds: 200));

      // Отправляем Tuya discovery запрос
      final discoveryPacket = _buildDiscoveryPacket();
      socket.add(discoveryPacket);

      await socket.flush();

      // Ждём ответ
      socket.listen(
            (data) {
          final response = utf8.decode(data);
          _talker.debug('Response from $ip: $response');

          try {
            final json = jsonDecode(response);
            if (json['ip'] != null || json['gwId'] != null) {
              final device = {
                'name': json['gwId']?.toString() ?? 'Tuya Device',
                'ip': ip,
                'deviceId': json['gwId']?.toString() ?? '',
                'version': json['version']?.toString() ?? '3.3',
              };

              // Проверяем, нет ли уже такого устройства
              if (!_foundDevices.any((d) => d['ip'] == ip)) {
                _foundDevices.add(device);
                _devicesController.add(List.from(_foundDevices));
                _talker.info('Found Tuya device: $device');
              }
            }
          } catch (e) {
            // Не JSON ответ — игнорируем
          }
        },
        onError: (e) {
          // Устройство не Tuya — игнорируем
        },
        onDone: () {
          socket.destroy();
        },
      );
    } catch (e) {
      // Порт закрыт — не Tuya устройство
    }
  }

  Uint8List _buildDiscoveryPacket() {
    // Простой UDP пакет для обнаружения Tuya устройств
    // Формат: {"gwId":"...", "devId":"..."}
    final packet = jsonEncode({'gwId': '', 'devId': ''});
    return Uint8List.fromList(utf8.encode(packet));
  }

  void dispose() {
    _devicesController.close();
  }
}