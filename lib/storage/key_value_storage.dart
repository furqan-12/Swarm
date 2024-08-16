import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyValueStorage {
  static const _storage = FlutterSecureStorage();

  static Future<String> getValue(String key) async =>
      await _storage.read(key: key) ?? "";

  static Future<void> setValue(String key, String value) async =>
      await _storage.write(key: key, value: value);

  static Future<void> removeKey(String key) async =>
      await _storage.delete(key: key);
}
