import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:swarm/services/response/user.dart';

class UserProfileStorage {
  static const _userProfile = 'userProfile';

  static Future<String?> get getValue async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userProfile);
  }

  static Future<void> setValue(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfile, value ?? '');
  }

  static Future<void> removeValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      _userProfile,
    );
  }

  static Future<UserProfile?> get getUserProfileModel async {
    final jsonStr = await UserProfileStorage.getValue;
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final json = jsonDecode(jsonStr);

      return UserProfile.fromJson(json);
    } else {
      return null;
    }
  }
}
