import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedKeys {
  static final EncryptedKeys _instance = EncryptedKeys._();
  factory EncryptedKeys() => _instance;
  EncryptedKeys._();

  final _storage = const FlutterSecureStorage();

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}