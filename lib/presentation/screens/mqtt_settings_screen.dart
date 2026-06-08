/// Экран настроек MQTT брокера.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttSettingsScreen extends StatefulWidget {
  const MqttSettingsScreen({super.key});

  @override
  State<MqttSettingsScreen> createState() => _MqttSettingsScreenState();
}

class _MqttSettingsScreenState extends State<MqttSettingsScreen> {
  final _brokerController = TextEditingController();
  final _portController = TextEditingController();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _brokerController.text = prefs.getString('mqtt_broker') ?? '192.168.1.100';
    _portController.text = prefs.getString('mqtt_port') ?? '1883';
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mqtt_broker', _brokerController.text.trim());
    await prefs.setString('mqtt_port', _portController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Настройки MQTT сохранены')),
    );
  }

  @override
  void dispose() {
    _brokerController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 MQTT Брокер'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Настройки подключения', style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  TextField(
                    controller: _brokerController,
                    decoration: const InputDecoration(
                      labelText: 'IP адрес брокера',
                      prefixIcon: Icon(Icons.dns),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Порт',
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 Для связки с Frigate', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('1. Укажите IP ноутбука/сервера с MQTT брокером'),
                  Text('2. В конфиге Frigate пропишите этот же брокер'),
                  Text('3. Тревоги будут приходить автоматически'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}