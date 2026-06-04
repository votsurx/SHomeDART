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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pollInterval = prefs.getInt('poll_interval') ?? 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Интервал опроса
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

          // Резервная копия
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: const Text('Резервная копия'),
              subtitle: const Text('Экспорт / Импорт конфигурации'),
              onTap: () => _showBackupMenu(context),
            ),
          ),
          const SizedBox(height: 24),

          // О приложении
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('О приложении'),
              subtitle: const Text('SHome v2.11'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SHome',
                  applicationVersion: '2.11.0',
                  applicationLegalese: '© 2026 SHome Team',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Показывает меню выбора: Экспорт / Импорт из файла / Восстановить из приложения
  void _showBackupMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Экспорт
            ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.blue),
              title: const Text('Экспортировать'),
              subtitle: const Text('Сохранить и поделиться'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await ConfigService.exportConfig();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Экспорт выполнен!')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e')));
                  }
                }
              },
            ),
            // Импорт из файла
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.green),
              title: const Text('Импортировать из файла'),
              subtitle: const Text('Выбрать файл на устройстве'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await ConfigService.importConfig();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Импорт выполнен!')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e')));
                  }
                }
              },
            ),
            // Восстановить из приложения
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.teal),
              title: const Text('Восстановить из приложения'),
              subtitle: const Text('Импорт из сохранённой копии'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await ConfigService.quickImport();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Импорт выполнен!')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ ${e.toString().replaceFirst('Exception: ', '')}')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}