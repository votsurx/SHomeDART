import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../../../domain/models/device.dart';

class DeviceCameraPreview extends StatelessWidget {
  final Device device;
  const DeviceCameraPreview({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final cameraType = device.properties['cameraType'] as String? ?? 'device';

    if (cameraType == 'rtsp') {
      return _RtspPreview(device: device);
    }

    return GestureDetector(
      onTap: () => _openDeviceFullScreen(context),
      child: _MiniPreview(device: device),
    );
  }

  void _openDeviceFullScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _FullScreenCamera(device: device)));
  }
}

// ═══════════ RTSP через VLC ═══════════

class _RtspPreview extends StatefulWidget {
  final Device device;
  const _RtspPreview({required this.device});

  @override
  State<_RtspPreview> createState() => _RtspPreviewState();
}

class _RtspPreviewState extends State<_RtspPreview> {
  VlcPlayerController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initVlc();
  }

  Future<void> _initVlc() async {
    final url = widget.device.properties['rtspUrl'] as String?;
    if (url == null || url.isEmpty) return;

    _controller = VlcPlayerController.network(
      url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([VlcAdvancedOptions.networkCaching(1000)]),
      ),
    );

    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isReady = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam, size: 28, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            widget.device.properties['rtspUrl'] as String? ?? 'RTSP',
            style: const TextStyle(fontSize: 8),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text(widget.device.name),
              backgroundColor: Colors.black,
            ),
            body: Center(
              child: VlcPlayer(
                controller: _controller!,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),
          ),
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: VlcPlayer(
          controller: _controller!,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
    );
  }
}

// ═══════════ КАМЕРА УСТРОЙСТВА ═══════════

class _MiniPreview extends StatefulWidget {
  final Device device;
  const _MiniPreview({required this.device});

  @override
  State<_MiniPreview> createState() => _MiniPreviewState();
}

class _MiniPreviewState extends State<_MiniPreview> {
  CameraController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final lens = widget.device.properties['cameraLens'] as int? ?? 0;
      _controller = CameraController(cameras[lens < cameras.length ? lens : 0], ResolutionPreset.low, enableAudio: false);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isReady = true);
    } catch (_) {}
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) return const Icon(Icons.videocam, size: 28, color: Colors.grey);
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: CameraPreview(_controller!));
  }
}

class _FullScreenCamera extends StatefulWidget {
  final Device device;
  const _FullScreenCamera({required this.device});

  @override
  State<_FullScreenCamera> createState() => _FullScreenCameraState();
}

class _FullScreenCameraState extends State<_FullScreenCamera> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _lensIndex = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _lensIndex = widget.device.properties['cameraLens'] as int? ?? 0;
    _init();
  }

  Future<void> _init() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;
    if (_lensIndex >= _cameras!.length) _lensIndex = 0;
    _controller = CameraController(_cameras![_lensIndex], ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isReady = true);
  }

  Future<void> _switch() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _lensIndex = _lensIndex == 0 ? 1 : 0;
    await _controller?.dispose();
    _isReady = false;
    setState(() {});
    await _init();
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.device.name), backgroundColor: Colors.black, actions: [
        if (_cameras != null && _cameras!.length > 1)
          IconButton(icon: const Icon(Icons.flip_camera_android, color: Colors.white), onPressed: _switch),
      ]),
      body: _isReady && _controller != null ? Center(child: CameraPreview(_controller!)) : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}