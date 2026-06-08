import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/camera_scanner.dart';
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ScannerTab extends ConsumerStatefulWidget {
  const ScannerTab({super.key});

  @override
  ConsumerState<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends ConsumerState<ScannerTab> {
  List<DiscoveredCamera> _foundCameras = [];
  bool _isScanning = false;
  String _status = '';

  Future<void> _scanRtsp() async {
    setState(() { _isScanning = true; _status = 'Сканирую RTSP...'; _foundCameras = []; });

    try {
      final info = NetworkInfo();
      final ip = await info.getWifiIP() ?? '192.168.1.0';
      final parts = ip.split('.');
      final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

      final cameras = await CameraScanner.scanRtsp(subnet: subnet, timeout: 1);
      setState(() { _foundCameras = cameras; _status = 'Найдено: ${cameras.length} RTSP камер'; });
    } catch (e) {
      setState(() => _status = 'Ошибка: $e');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _scanOnvif() async {
    setState(() { _isScanning = true; _status = 'Сканирую ONVIF...'; _foundCameras = []; });

    try {
      final cameras = await CameraScanner.scanOnvif(timeout: 5);
      setState(() { _foundCameras = cameras; _status = 'Найдено: ${cameras.length} ONVIF камер'; });
    } catch (e) {
      setState(() => _status = 'Ошибка: $e');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _addCamera(DiscoveredCamera cam) {
    ref.read(devicesProvider.notifier).addDevice(Device(
      id: '${cam.source}_${DateTime.now().millisecondsSinceEpoch}',
      name: cam.name ?? 'Камера ${cam.ip}',
      type: DeviceType.camera,
      roomId: 'other',
      isOnline: true,
      state: DeviceState.online,
      properties: {
        'cameraType': 'rtsp',
        'rtspUrl': cam.rtspUrl ?? 'rtsp://${cam.ip}:554/stream',
        'onvifUrl': cam.onvifUrl,
      },
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Камера "${cam.name}" добавлена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Кнопки сканирования
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanRtsp,
                icon: _isScanning ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi_find),
                label: const Text('RTSP'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanOnvif,
                icon: _isScanning ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi_find),
                label: const Text('ONVIF'),
              ),
            ),
          ]),
        ),

        // Статус
        if (_status.isNotEmpty)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(_status, style: const TextStyle(color: Colors.grey))),

        // Список найденных
        Expanded(
          child: _foundCameras.isEmpty && !_isScanning
              ? Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('Нажмите RTSP или ONVIF для поиска', style: TextStyle(color: Colors.grey)),
            ]),
          )
              : ListView.builder(
            itemCount: _foundCameras.length,
            itemBuilder: (context, index) {
              final cam = _foundCameras[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(cam.source == 'onvif' ? Icons.videocam : Icons.camera, color: Colors.blue),
                  title: Text(cam.name ?? cam.ip),
                  subtitle: Text('${cam.ip} | ${cam.source.toUpperCase()}'),
                  trailing: ElevatedButton(
                    onPressed: () => _addCamera(cam),
                    child: const Text('Добавить'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}