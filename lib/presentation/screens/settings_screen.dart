/// Экран настроек приложения.
/// Позволяет изменить интервал опроса устройств (2/5/10/30 сек),
/// экспортировать/импортировать конфигурацию в JSON-файл,
/// посмотреть информацию о приложении.
library;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/config_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _pollInterval = 2;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Загружает сохранённый интервал опроса из SharedPreferences.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _pollInterval = prefs.getInt('poll_interval') ?? 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Интервал опроса ---
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer, color: Colors.orange),
              title: const Text('Интервал опроса'),
              subtitle: Text('$_pollInterval сек'),
              onTap: () async {
                final selected = await showDialog<int>(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: const Text('Интервал опроса'),
                    children: [2, 5, 10, 30].map((s) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, s),
                      child: Text('$s секунд'),
                    )).toList(),
                  ),
                );
                if (selected != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('poll_interval', selected);
                  setState(() => _pollInterval = selected);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Интервал изменён на $selected сек. Перезапустите приложение.')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          // --- Экспорт конфигурации ---
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.blue),
              title: const Text('Экспортировать'),
              subtitle: const Text('Сохранить конфигурацию в файл'),
              onTap: () async {
                try {
                  await ConfigService.exportConfig();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Экспорт выполнен!')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка экспорта: $e')));
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          // --- Импорт конфигурации ---
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_download, color: Colors.green),
              title: const Text('Импортировать'),
              subtitle: const Text('Восстановить конфигурацию из файла'),
              onTap: () async {
                try {
                  await ConfigService.importConfig();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Импорт выполнен! Перезапустите приложение.')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка импорта: $e')));
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          // --- О приложении ---
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('О приложении'),
              subtitle: const Text('SHome v2.7'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SHome',
                  applicationVersion: '2.7.0',
                  applicationLegalese: '© 2026 SHome Team',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}