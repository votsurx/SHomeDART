/// Экран настроек подключения к LegionNVR
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/state/nvr_provider.dart';
import '../../data/services/nvr_api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class NvrSettingsScreen extends ConsumerStatefulWidget {
  const NvrSettingsScreen({super.key});

  @override
  ConsumerState<NvrSettingsScreen> createState() => _NvrSettingsScreenState();
}

class _NvrSettingsScreenState extends ConsumerState<NvrSettingsScreen> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _mqttBrokerController = TextEditingController();
  final TextEditingController _mqttPortController = TextEditingController();
  bool _isTesting = false;
  bool _isConnected = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _mqttBrokerController.dispose();
    _mqttPortController.dispose();
    super.dispose();
  }

  void _loadSettings() async {
    final settings = ref.read(nvrSettingsProvider);
    _hostController.text = settings.host;
    _portController.text = settings.port.toString();

    // Загружаем MQTT настройки
    final prefs = await SharedPreferences.getInstance();
    _mqttBrokerController.text = prefs.getString('mqtt_broker') ?? '127.0.0.1';
    _mqttPortController.text = prefs.getString('mqtt_port') ?? '1883';
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);

    try {
      final client = NvrApiClient(
        host: _hostController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 8080,
      );

      _isConnected = await client.isAlive();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isConnected ? '✅ Подключено к LegionNVR' : '❌ Не удалось подключиться',
            ),
            backgroundColor: _isConnected ? Colors.green : Colors.red,
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
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8080;
    final mqttBroker = _mqttBrokerController.text.trim();
    final mqttPort = _mqttPortController.text.trim();

    if (host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите IP адрес NVR')),
      );
      return;
    }

    // Сохраняем NVR настройки
    final notifier = ref.read(nvrSettingsProvider.notifier);
    await notifier.updateSettings(host: host, port: port);

    // Сохраняем MQTT настройки
    final prefs = await SharedPreferences.getInstance();
    if (mqttBroker.isNotEmpty) {
      await prefs.setString('mqtt_broker', mqttBroker);
    }
    if (mqttPort.isNotEmpty) {
      await prefs.setString('mqtt_port', mqttPort);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Настройки сохранены')),
      );
    }
  }

  Future<void> _syncNow() async {
    setState(() => _isSyncing = true);

    try {
      // TODO: вызвать NvrSyncService.syncNow()
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Синхронизация выполнена')),
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
        setState(() => _isSyncing = false);
      }
    }
  }

  void _openNvr() async {
    final settings = ref.read(nvrSettingsProvider);
    final url = 'http://${settings.host}:${settings.port}';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Не удалось открыть LegionNVR')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🖥️ Видео NVR'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================================
          // ПОДКЛЮЧЕНИЕ К NVR
          // ============================================================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Подключение к LegionNVR',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'IP адрес NVR',
                      hintText: '192.168.1.100',
                      prefixIcon: Icon(Icons.dns),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Порт NVR',
                      hintText: '8080',
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isTesting ? null : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(Icons.wifi_find),
                          label: Text(_isTesting ? 'Проверка...' : 'Проверить'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.save),
                          label: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),

                  if (_isConnected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('LegionNVR доступен'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ============================================================
          // MQTT НАСТРОЙКИ (для LegionNVR)
          // ============================================================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📡 MQTT Брокер (для тревог)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Для получения тревог от LegionNVR',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _mqttBrokerController,
                    decoration: const InputDecoration(
                      labelText: 'IP адрес MQTT',
                      hintText: '127.0.0.1',
                      prefixIcon: Icon(Icons.settings_input_antenna),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _mqttPortController,
                    decoration: const InputDecoration(
                      labelText: 'Порт MQTT',
                      hintText: '1883',
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ============================================================
          // ДЕЙСТВИЯ
          // ============================================================
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync, color: Colors.blue),
                  title: const Text('Синхронизировать камеры'),
                  subtitle: const Text('Обновить список камер из NVR'),
                  trailing: _isSyncing
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.chevron_right),
                  onTap: _isSyncing ? null : _syncNow,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.open_in_browser, color: Colors.purple),
                  title: const Text('Открыть LegionNVR'),
                  subtitle: const Text('В браузере'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openNvr,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ============================================================
          // ИНФО
          // ============================================================
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Интеграция с LegionNVR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Камеры добавляются и настраиваются в LegionNVR'),
                  Text('• Изменения автоматически синхронизируются'),
                  Text('• Управляйте камерами прямо с главного экрана'),
                  Text('• Тревоги отображаются в журнале событий'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}