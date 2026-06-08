import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VkSettingsScreen extends StatefulWidget {
  const VkSettingsScreen({super.key});

  @override
  State<VkSettingsScreen> createState() => _VkSettingsScreenState();
}

class _VkSettingsScreenState extends State<VkSettingsScreen> {
  final _tokenController = TextEditingController();
  final _userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _tokenController.text = prefs.getString('vk_token') ?? '';
    _userIdController.text = prefs.getString('vk_user_id') ?? '';
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vk_token', _tokenController.text.trim());
    await prefs.setString('vk_user_id', _userIdController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Настройки VK сохранены')),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _userIdController.dispose();
    super.dispose();
  }
  Future<void> _testNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('vk_token');
    final userId = prefs.getString('vk_user_id');

    if (token == null || userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Сначала сохраните настройки')),
      );
      return;
    }

    try {
      final randomId = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse(
          'https://api.vk.com/method/messages.send'
              '?user_id=$userId'
              '&message=${Uri.encodeComponent('🧪 Тестовое уведомление SHome!\n✅ VK Bot работает!\n🕐 ${DateTime.now().toString().substring(0, 19)}')}'
              '&random_id=$randomId'
              '&access_token=$token'
              '&v=5.199'
      );

      final response = await http.get(url);
      debugPrint('VK Response: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Тестовое уведомление отправлено! Проверьте VK')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Ошибка отправки')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔔 VK Уведомления'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Настройки VK Bot', style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(labelText: 'Токен сообщества', prefixIcon: Icon(Icons.key)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'Ваш VK ID', prefixIcon: Icon(Icons.person)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: _save, icon: const Icon(Icons.save), label: const Text('Сохранить'),
                )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _testNotification,
                    icon: const Icon(Icons.send),
                    label: const Text('Отправить тестовое уведомление'),
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
                Text('💡 Как настроить', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('1. Создайте сообщество VK'),
                Text('2. Управление → API → Создать токен'),
                Text('3. Включите Long Poll API'),
                Text('4. Узнайте свой ID через @userinfobot'),
                Text('5. Вставьте токен и ID сюда'),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}