import 'package:flutter_test/flutter_test.dart';
import 'package:shome/data/services/camera_scanner.dart';

void main() {
  group('CameraScanner', () {
    test('scanRtsp с невалидной подсетью возвращает пустой список', () async {
      final cameras = await CameraScanner.scanRtsp(subnet: '10.255.255', port: 554, timeout: 1);
      expect(cameras, isEmpty);
    }, skip: 'Требует изолированной сети без loopback');

    test('scanOnvif завершается без ошибок', () async {
      final cameras = await CameraScanner.scanOnvif(timeout: 2);
      // В тестовой среде без сети должен вернуть пустой список
      expect(cameras, isEmpty);
    });

    test('DiscoveredCamera создаётся с правильными полями', () {
      final cam = DiscoveredCamera(
        ip: '192.168.1.100',
        name: 'Test Cam',
        rtspUrl: 'rtsp://192.168.1.100:554/stream',
        source: 'rtsp',
      );

      expect(cam.ip, '192.168.1.100');
      expect(cam.name, 'Test Cam');
      expect(cam.source, 'rtsp');
    });
  });
}