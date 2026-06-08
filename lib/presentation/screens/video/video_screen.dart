/// Экран видеонаблюдения с вкладками.
library;

import 'package:flutter/material.dart';
import 'local_camera_tab.dart';
import 'scanner_tab.dart';
import 'rtsp_cameras_tab.dart';
import 'alarms_tab.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📹 Видеонаблюдение'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.phone_android), text: 'Локальная'),
            Tab(icon: Icon(Icons.wifi_find), text: 'Сканер'),
            Tab(icon: Icon(Icons.videocam), text: 'RTSP'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Тревоги'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LocalCameraTab(),
          ScannerTab(),
          RtspCamerasTab(),
          AlarmsTab(),
        ],
      ),
    );
  }
}