import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/local/database.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Устройства', icon: Icon(Icons.devices)),
            Tab(text: 'Датчики', icon: Icon(Icons.thermostat)),
            Tab(text: 'Энергия', icon: Icon(Icons.bolt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDevicesTab(),
          _buildSensorsTab(),
          _buildEnergyTab(),
        ],
      ),
    );
  }

  Widget _buildDevicesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getDeviceStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!;
        if (data.isEmpty) return const Center(child: Text('Нет данных'));

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // График
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(toY: (e.value['count'] as int).toDouble())],
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Сводка
              ...data.map((d) => ListTile(
                title: Text(d['name'] as String),
                subtitle: Text('Вкл/Выкл: ${d['count']} раз(а)'),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorsTab() {
    return const Center(child: Text('Данные датчиков — скоро'));
  }

  Widget _buildEnergyTab() {
    return const Center(child: Text('Энергопотребление — скоро'));
  }

  Future<List<Map<String, dynamic>>> _getDeviceStats() async {
    final events = await AppDatabase.getRecentEvents(limit: 1000);
    final stats = <String, Map<String, dynamic>>{};

    for (final event in events) {
      if (event.event == 'turnOn' || event.event == 'turnOff') {
        final name = event.deviceName ?? 'Неизвестно';
        stats.putIfAbsent(name, () => {'name': name, 'count': 0});
        stats[name]!['count'] = (stats[name]!['count'] as int) + 1;
      }
    }

    return stats.values.toList();
  }
}