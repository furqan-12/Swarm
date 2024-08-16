import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/registration.dart';

class RegistrationStorage {
  static const _registration = 'registration';
  static const _portfolio = 'portfolio';

  static Future<String?> get getValue async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registration);
  }

  static Future<void> setValue(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registration, value ?? '');
  }

  static Future<void> removeValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      _registration,
    );
    await prefs.remove(
      _portfolio,
    );
  }

  static Future<String?> get getPortfolioValue async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_portfolio);
  }

  static Future<RegistrationModel?> get getRegistrationModel async {
    final jsonStr = await RegistrationStorage.getValue;
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final json = jsonDecode(jsonStr);

      return RegistrationModel.fromJson(json);
    } else {
      return null;
    }
  }
}
