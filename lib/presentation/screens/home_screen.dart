import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHome v2.0'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('🚀 Нулевой этап запущен!'),
      ),
    );
  }
}