/// Провайдер настроек подключения к LegionNVR
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/nvr_api_client.dart';

// ============================================================
// 📦 NVR SETTINGS
// ============================================================

class NvrSettings {
  final String host;
  final int port;
  final bool autoSync;
  final bool showMjpeg;

  const NvrSettings({
    this.host = '192.168.1.100',
    this.port = 8080,
    this.autoSync = true,
    this.showMjpeg = true,
  });

  NvrSettings copyWith({
    String? host,
    int? port,
    bool? autoSync,
    bool? showMjpeg,
  }) {
    return NvrSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      autoSync: autoSync ?? this.autoSync,
      showMjpeg: showMjpeg ?? this.showMjpeg,
    );
  }

  String get baseUrl => 'http://$host:$port';
}

// ============================================================
// 🔌 NVR SETTINGS NOTIFIER
// ============================================================

final nvrSettingsProvider = StateNotifierProvider<NvrSettingsNotifier, NvrSettings>(
      (ref) => NvrSettingsNotifier(),
);

class NvrSettingsNotifier extends StateNotifier<NvrSettings> {
  static const _hostKey = 'nvr_host';
  static const _portKey = 'nvr_port';
  static const _autoSyncKey = 'nvr_auto_sync';
  static const _showMjpegKey = 'nvr_show_mjpeg';

  NvrSettingsNotifier() : super(const NvrSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = NvrSettings(
      host: prefs.getString(_hostKey) ?? state.host,
      port: prefs.getInt(_portKey) ?? state.port,
      autoSync: prefs.getBool(_autoSyncKey) ?? state.autoSync,
      showMjpeg: prefs.getBool(_showMjpegKey) ?? state.showMjpeg,
    );
  }

  Future<void> updateSettings({
    String? host,
    int? port,
    bool? autoSync,
    bool? showMjpeg,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (host != null) {
      await prefs.setString(_hostKey, host);
    }
    if (port != null) {
      await prefs.setInt(_portKey, port);
    }
    if (autoSync != null) {
      await prefs.setBool(_autoSyncKey, autoSync);
    }
    if (showMjpeg != null) {
      await prefs.setBool(_showMjpegKey, showMjpeg);
    }

    state = state.copyWith(
      host: host,
      port: port,
      autoSync: autoSync,
      showMjpeg: showMjpeg,
    );
  }

  /// Создаёт клиент API с текущими настройками
  NvrApiClient get client => NvrApiClient(
    host: state.host,
    port: state.port,
  );
}

// ============================================================
// 🔄 NVR STATUS PROVIDER
// ============================================================

final nvrStatusProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(nvrSettingsProvider);
  final client = NvrApiClient(
    host: settings.host,
    port: settings.port,
  );
  return await client.isAlive();
});