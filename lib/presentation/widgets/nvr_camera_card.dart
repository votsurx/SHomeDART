/// Виджет карточки NVR-камеры для главного экрана
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/nvr_provider.dart';
import '../../data/services/mjpeg_stream_service.dart';
import '../../data/services/nvr_api_client.dart';
import 'dart:typed_data';

class NvrCameraCard extends ConsumerStatefulWidget {
  final Device device;

  const NvrCameraCard({
    super.key,
    required this.device,
  });

  @override
  ConsumerState<NvrCameraCard> createState() => _NvrCameraCardState();
}

class _NvrCameraCardState extends ConsumerState<NvrCameraCard> {
  MjpegStreamService? _mjpegService;
  Stream<Uint8List>? _stream;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isUpdating = false;
  late final int _nvrId;

  @override
  void initState() {
    super.initState();
    _nvrId = widget.device.properties['nvrId'] as int? ?? 0;
    _startStream();
  }

  @override
  void dispose() {
    _mjpegService?.dispose();
    super.dispose();
  }

  void _startStream() {
    final mjpegUrl = widget.device.properties['mjpegUrl'] as String?;

    if (mjpegUrl == null || mjpegUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    _mjpegService = MjpegStreamService();
    _stream = _mjpegService!.subscribe(mjpegUrl);

    // Сброс состояния после получения первого кадра
    _stream?.listen(
          (_) {
        if (_isLoading) {
          setState(() => _isLoading = false);
        }
      },
      onError: (_) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    );
  }

  // ============================================================
  // ДЕЙСТВИЯ
  // ============================================================

  Future<void> _toggleCamera() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      final settings = ref.read(nvrSettingsProvider);
      final client = NvrApiClient(host: settings.host, port: settings.port);

      final newState = !widget.device.isOnline;
      await client.updateCamera(_nvrId, {'enabled': newState ? 1 : 0});
      await client.applyCamera(_nvrId);

      // Обновить локальное состояние
      final updated = widget.device.copyWith(
        isOnline: newState,
        state: newState ? DeviceState.online : DeviceState.offline,
      );
      ref.read(devicesProvider.notifier).updateDevice(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState ? '✅ Камера включена' : '🔴 Камера выключена'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      final current = widget.device.properties['recordEnabled'] == true;
      final newState = !current;

      final settings = ref.read(nvrSettingsProvider);
      final client = NvrApiClient(host: settings.host, port: settings.port);

      await client.updateCamera(_nvrId, {'record_enabled': newState ? 1 : 0});
      await client.applyCamera(_nvrId);

      // Обновить локальное состояние
      final updated = widget.device.copyWith(
        properties: {
          ...widget.device.properties,
          'recordEnabled': newState,
        },
      );
      ref.read(devicesProvider.notifier).updateDevice(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState ? '📼 Запись включена' : '⏹️ Запись выключена'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _toggleMotion() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      final current = widget.device.properties['motionEnabled'] == true;
      final newState = !current;

      final settings = ref.read(nvrSettingsProvider);
      final client = NvrApiClient(host: settings.host, port: settings.port);

      await client.updateCamera(_nvrId, {'motion_enabled': newState ? 1 : 0});
      await client.applyCamera(_nvrId);

      // Обновить локальное состояние
      final updated = widget.device.copyWith(
        properties: {
          ...widget.device.properties,
          'motionEnabled': newState,
        },
      );
      ref.read(devicesProvider.notifier).updateDevice(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newState ? '🔍 Детектор включен' : '🔍 Детектор выключен',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _openNvrSettings() {
    final nvrSettings = ref.read(nvrSettingsProvider);
    final url = '${nvrSettings.baseUrl}/cameras/$_nvrId/edit';
    // Открываем в браузере
    // TODO: использовать url_launcher
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.device.isOnline;
    final isRecording = widget.device.properties['recordEnabled'] == true;
    final hasMotion = widget.device.properties['hasMotion'] == true;
    final isMotionEnabled = widget.device.properties['motionEnabled'] == true;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Column(
            children: [
              // ============================================================
              // ЗАГОЛОВОК
              // ============================================================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.videocam,
                      size: 20,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.device.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, size: 18),
                      onPressed: _openNvrSettings,
                    ),
                  ],
                ),
              ),

              // ============================================================
              // ВИДЕО
              // ============================================================
              Expanded(
                child: _buildVideoPreview(),
              ),

              // ============================================================
              // КНОПКИ УПРАВЛЕНИЯ
              // ============================================================
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: Icons.power_settings_new,
                      label: isOnline ? 'ON' : 'OFF',
                      color: isOnline ? Colors.green : Colors.grey,
                      onTap: _toggleCamera,
                    ),
                    const SizedBox(width: 12),
                    _buildControlButton(
                      icon: Icons.fiber_manual_record,
                      label: 'REC',
                      color: isRecording ? Colors.red : Colors.grey,
                      onTap: _toggleRecording,
                    ),
                    const SizedBox(width: 12),
                    _buildControlButton(
                      icon: Icons.motion_photos_on,
                      label: 'MOTION',
                      color: isMotionEnabled ? Colors.orange : Colors.grey,
                      onTap: _toggleMotion,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ============================================================
          // ИНДИКАТОР ЗАПИСИ
          // ============================================================
          if (isRecording)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.fiber_manual_record,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text('REC', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
            ),

          // ============================================================
          // ИНДИКАТОР ДВИЖЕНИЯ
          // ============================================================
          if (hasMotion)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text('MOTION', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
            ),

          // ============================================================
          // ИНДИКАТОР OFFLINE
          // ============================================================
          if (!isOnline)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text('Offline', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _stream == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Нет сигнала', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return StreamBuilder<Uint8List>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const Center(child: Icon(Icons.error, color: Colors.grey));
            },
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Icon(Icons.error_outline, color: Colors.red));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isUpdating ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: _isUpdating
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(icon, color: color, size: 20),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}