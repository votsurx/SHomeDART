/// Сканер IP-камер в локальной сети.
/// Поддерживает RTSP (по портам) и ONVIF (WS-Discovery).
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DiscoveredCamera {
  final String ip;
  final String? name;
  final String? rtspUrl;
  final String? onvifUrl;
  final String source; // 'rtsp' | 'onvif'

  DiscoveredCamera({
    required this.ip,
    this.name,
    this.rtspUrl,
    this.onvifUrl,
    required this.source,
  });
}

class CameraScanner {
  /// Сканирует RTSP камеры по списку IP и стандартным портам.
  static Future<List<DiscoveredCamera>> scanRtsp({
    required String subnet, // "192.168.1"
    int port = 554,
    int timeout = 3,
  }) async {
    final cameras = <DiscoveredCamera>[];
    final futures = <Future>[];

    for (var i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      futures.add(
        Socket.connect(ip, port, timeout: Duration(seconds: timeout))
            .then((socket) {
          socket.destroy();
          cameras.add(DiscoveredCamera(
            ip: ip,
            name: 'RTSP Camera $ip',
            rtspUrl: 'rtsp://$ip:$port/stream',
            source: 'rtsp',
          ));
          debugPrint('🔍 Найдена RTSP камера: $ip');
        }).catchError((_) {
          // Порт закрыт — не камера
        }),
      );
    }

    await Future.wait(futures);
    return cameras;
  }

  /// Сканирует ONVIF камеры через WS-Discovery.
  static Future<List<DiscoveredCamera>> scanOnvif({
    int timeout = 3,
  }) async {
    final cameras = <DiscoveredCamera>[];
    final completer = Completer<void>();

    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;

    // WS-Discovery probe message
    final probe = '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing"
               xmlns:wsd="http://schemas.xmlsoap.org/ws/2005/04/discovery">
  <soap:Header>
    <wsa:Action>http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</wsa:Action>
    <wsa:MessageID>urn:uuid:${DateTime.now().millisecondsSinceEpoch}</wsa:MessageID>
    <wsa:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</wsa:To>
  </soap:Header>
  <soap:Body>
    <wsd:Probe>
      <wsd:Types>dn:NetworkVideoTransmitter</wsd:Types>
    </wsd:Probe>
  </soap:Body>
</soap:Envelope>
''';

    socket.send(probe.codeUnits, InternetAddress('239.255.255.250'), 3702);

    Timer(Duration(seconds: timeout), () {
      socket.close();
      if (!completer.isCompleted) completer.complete();
    });

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram != null) {
          final data = String.fromCharCodes(datagram.data);
          // Ищем XAddrs в ответе
          final xaddrs = RegExp(r'<wsd:XAddrs>(.*?)</wsd:XAddrs>').firstMatch(data);
          if (xaddrs != null) {
            final url = xaddrs.group(1)!;
            final ip = RegExp(r'(\d+\.\d+\.\d+\.\d+)').firstMatch(url)?.group(1);
            if (ip != null && !cameras.any((c) => c.ip == ip)) {
              cameras.add(DiscoveredCamera(
                ip: ip,
                name: 'ONVIF Camera $ip',
                onvifUrl: url,
                rtspUrl: 'rtsp://$ip:554/onvif1',
                source: 'onvif',
              ));
              debugPrint('🔍 Найдена ONVIF камера: $ip → $url');
            }
          }
        }
      }
    });

    await completer.future;
    return cameras;
  }
}
