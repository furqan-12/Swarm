import 'dart:convert';

import 'package:swarm/services/refresh_token_service.dart';

import '../consts/api.dart';
import '../storage/models/token.dart';
import '../storage/token_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class BaseService {
  Future<Map<String, String>> getAuthHeader() async {
    late Map<String, String> headers;
    final String tokenString = await TokenStorage.jwtToken;
    if (tokenString.isNotEmpty) {
      Map<String, dynamic> userMap = jsonDecode(tokenString);
      TokenModel token = TokenModel.fromJson(userMap);
      var isTokenExpired = JwtDecoder.isExpired(token.token);
      if (isTokenExpired) {
        final refreshTokenService = RefreshTokenService();
        final tokenResponse = await refreshTokenService.getJwtToken(
            token.token, token.refreshToken);
        if (tokenResponse != null && tokenResponse is String) {
        } else if (tokenResponse != null) {
          await TokenStorage.setJwtToken(jsonEncode(tokenResponse));
          token = TokenModel.fromJson(tokenResponse);
        }
      }

      String bearerToken = 'Bearer ${token.token}';

      headers = {
        'Content-Type': 'application/json',
        'Authorization':
            bearerToken, // Add the Authorization header with the Bearer token
      };
    }
    return headers;
  }

  Map<String, String> getBasicHeader() {
    final headers = {'Content-Type': 'application/json'};
    return headers;
  }

  Map<String, String> getTenanHeader() {
    // Headers to be sent along with the request (including 'tenant' header)
    final headers = {
      'Content-Type': 'application/json',
      'tenant': tenant,
    };
    return headers;
  }
}
