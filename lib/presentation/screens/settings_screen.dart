import 'package:flutter/material.dart';
import '../../data/services/config_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Экспорт
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.blue),
              title: const Text('Экспортировать'),
              subtitle: const Text('Сохранить конфигурацию в файл'),
              onTap: () async {
                try {
                  await ConfigService.exportConfig();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Экспорт выполнен!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Ошибка экспорта: $e')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          // Импорт
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_download, color: Colors.green),
              title: const Text('Импортировать'),
              subtitle: const Text('Восстановить конфигурацию из файла'),
              onTap: () async {
                try {
                  await ConfigService.importConfig();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Импорт выполнен! Перезапустите приложение.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Ошибка импорта: $e')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          // О приложении
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('О приложении'),
              subtitle: const Text('SHome v2.6'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SHome',
                  applicationVersion: '2.6.0',
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