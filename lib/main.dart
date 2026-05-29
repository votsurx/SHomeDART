import 'package:flutter/material.dart';
import 'di/injection.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const SHomeApp());
}