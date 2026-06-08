import 'package:flutter/material.dart';

class ScannerTab extends StatelessWidget {
  const ScannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.wifi_find, color: Colors.teal),
            title: const Text('Сканировать RTSP'),
            subtitle: const Text('Поиск RTSP камер в локальной сети'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⏳ Сканер будет добавлен позже')),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.wifi_find, color: Colors.orange),
            title: const Text('Сканировать ONVIF'),
            subtitle: const Text('Поиск ONVIF камер в локальной сети'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⏳ Сканер будет добавлен позже')),
              );
            },
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
                Text('💡 Как это работает', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text('1. Нажмите «Сканировать»'),
                Text('2. Выберите найденные камеры'),
                Text('3. Они появятся на главном экране'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}