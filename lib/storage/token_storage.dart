import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:swarm/services/refresh_token_service.dart';

import 'models/token.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';
  static const _credentialKey = 'credential';
  static const _biometricKey = 'biometric';
  static const _fromLoginKey = 'fromLogin';

  static Future<void> fromLogin(value) async =>
      await _storage.write(key: _fromLoginKey, value: value);

  static Future<String> get getFromLogin async =>
      await _storage.read(key: _fromLoginKey) ?? "no";

  static Future<void> enableBiometric() async =>
      await _storage.write(key: _biometricKey, value: "yes");

  static Future<String> get isBiometricEnable async =>
      await _storage.read(key: _biometricKey) ?? "no";

  static Future<void> setCredential(String username, String password) async =>
      await _storage.write(
          key: _credentialKey, value: "${username}:${password}");

  static Future<String> get getCredential async =>
      await _storage.read(key: _credentialKey) ?? "";

  static Future<String> get jwtToken async =>
      await _storage.read(key: _tokenKey) ?? "";

  static Future<void> setJwtToken(String? value) async =>
      await _storage.write(key: _tokenKey, value: value);

  static Future<void> removeJwtToken() async =>
      await _storage.delete(key: _tokenKey);

  static Future<TokenModel?> get getToken async {
    final jsonStr = await TokenStorage.jwtToken;
    if (jsonStr.isNotEmpty) {
      final json = jsonDecode(jsonStr);

      return TokenModel.fromJson(json);
    } else {
      return null;
    }
  }

  static Future<String> get getJwtToken async {
    final jsonStr = await TokenStorage.jwtToken;
    if (jsonStr.isNotEmpty) {
      final json = jsonDecode(jsonStr);

      return TokenModel.fromJson(json).token;
    } else {
      return "";
    }
  }

  static Future<void> updateProfileCompletedToken() async {
    final token = await TokenStorage.getToken;
    final refreshTokenService = RefreshTokenService();
    final tokenResponse =
        await refreshTokenService.getJwtToken(token!.token, token.refreshToken);
    if (tokenResponse != null && tokenResponse is String) {
    } else if (tokenResponse != null) {
      await TokenStorage.setJwtToken(jsonEncode(tokenResponse));
    }
  }
}
