import 'dart:async';
import 'dart:io';
import 'package:talker/talker.dart';

class DiscoveredDevice {
  final String ip;
  final int port;

  DiscoveredDevice({required this.ip, required this.port});
}

class PortScanner {
  final Talker _talker;
  final void Function(DiscoveredDevice device) _onDeviceFound;
  final void Function(int progress, int total) _onProgress;

  PortScanner(this._talker, this._onDeviceFound, this._onProgress);

  static const List<int> tuyaPorts = [6668, 6667, 6666, 7000];
  static const Duration timeout = Duration(milliseconds: 500); // Было 200
  static const int maxParallel = 50;

  Future<void> scanSubnet(String subnet) async {
    _talker.info('Scanning subnet: ${subnet}0/24');

    final ips = List.generate(254, (i) => '$subnet${i + 1}');
    var completed = 0;
    final totalChecks = ips.length;
    final foundIps = <String>{};

    // Сканируем IP, а не порты — быстрее
    for (var i = 0; i < ips.length; i += maxParallel) {
      final batch = ips.skip(i).take(maxParallel).toList();

      await Future.wait(batch.map((ip) async {
        // Проверяем порты по очереди, а не все сразу
        for (final port in tuyaPorts) {
          try {
            final socket = await Socket.connect(ip, port, timeout: timeout);
            socket.destroy();

            if (!foundIps.contains(ip)) {
              foundIps.add(ip);
              _talker.info('Found device: $ip (port $port)');
              _onDeviceFound(DiscoveredDevice(ip: ip, port: port));
            }
            break; // Нашли — не проверяем другие порты
          } catch (e) {
            // Порт закрыт — пробуем следующий
          }
        }
        completed++;
        if (completed % 10 == 0 || completed == totalChecks) {
          _onProgress(completed, totalChecks);
        }
      }));
    }

    _talker.info('Scan complete. Found ${foundIps.length} devices');
    _onProgress(totalChecks, totalChecks); // Финал
  }

  static Future<String?> getLocalSubnet() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.address.startsWith('127.')) {
            final parts = addr.address.split('.');
            return '${parts[0]}.${parts[1]}.${parts[2]}.';
          }
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}