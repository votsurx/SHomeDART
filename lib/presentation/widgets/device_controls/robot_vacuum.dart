import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';

class DeviceRobotVacuum extends ConsumerWidget {
  final Device device;
  const DeviceRobotVacuum({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battery = device.properties['battery_percentage'] as int? ?? 0;
    final status = device.properties['status'] as String? ?? 'unknown';
    final cleanTime = device.properties['clean_time'] as int? ?? 0;
    final cleanArea = device.properties['clean_area'] as int? ?? 0;
    final suction = device.properties['suction'] as String? ?? 'normal';
    final cistern = device.properties['cistern'] as String? ?? 'low';
    final isCleaning = device.properties['isOn'] == true;
    final dnd = device.properties['do_not_disturb'] == true;
    final mop = device.properties['y_mop_104'] == true;
    final volume = device.properties['volume_set'] as int? ?? 54;
    final isOnline = device.state != DeviceState.offline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Заряд + статус
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('🔋$battery%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(_statusIcon(status), style: const TextStyle(fontSize: 12)),
        ]),
        const SizedBox(height: 4),

        // Время + площадь
        Text('⏱$cleanTime мин  📐$cleanArea м²', style: const TextStyle(fontSize: 9, color: Colors.grey)),
        const SizedBox(height: 2),

        // Всасывание + вода
        Text('🌀${_suctionShort(suction)} 💧${_cisternShort(cistern)}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
        const SizedBox(height: 6),

    // Кнопки управления (в два ряда если узко)
    LayoutBuilder(
    builder: (context, constraints) {
    final narrow = constraints.maxWidth < 150;
    final buttons = [
    _btn(ref, context, isOnline, isCleaning ? Icons.stop : Icons.play_arrow,
    isCleaning ? Colors.red : Colors.green, () => _toggleCleaning(ref)),
    _btn(ref, context, isOnline, Icons.home, Colors.blue, () => _goHome(ref)),
    _btn(ref, context, isOnline, dnd ? Icons.do_not_disturb_on : Icons.do_not_disturb,
    dnd ? Colors.orange : Colors.grey, () {}),
    _btn(ref, context, isOnline, mop ? Icons.water_drop : Icons.water_drop_outlined,
    mop ? Colors.blue : Colors.grey, () {}),
    ];

    if (narrow) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
    Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons.sublist(0, 2).map((b) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: b)).toList()),
    const SizedBox(height: 4),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons.sublist(2, 4).map((b) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: b)).toList()),
    ]);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons.map((b) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: b)).toList());
    },
    ),
      ],
    );
  }

  Widget _btn(WidgetRef ref, BuildContext ctx, bool online, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        if (!online) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Offline'), duration: Duration(seconds: 1)),
          );
          return;
        }
        onTap();
      },
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _toggleCleaning(WidgetRef ref) {
    final isOn = device.properties['isOn'] == true;
    if (isOn) {
      ref.read(devicesProvider.notifier).turnOff(device.id);
    } else {
      ref.read(devicesProvider.notifier).turnOn(device.id);
    }
  }

  void _goHome(WidgetRef ref) {
    ref.read(devicesProvider.notifier).turnOn(device.id);
  }

  String _statusIcon(String s) {
    switch (s) {
      case 'charge_done': return '✅';
      case 'cleaning': return '🧹';
      case 'paused': return '⏸';
      case 'charging': return '🔋';
      default: return '📡';
    }
  }

  String _suctionShort(String s) {
    switch (s) {
      case 'normal': return 'норм';
      case 'turbo': return 'турбо';
      case 'max': return 'макс';
      default: return s;
    }
  }

  String _cisternShort(String c) {
    switch (c) {
      case 'low': return 'мало';
      case 'full': return 'полн';
      default: return c;
    }
  }
}