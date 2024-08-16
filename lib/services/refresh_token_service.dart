import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/consts/consts.dart';

import '../consts/api.dart';
import '../storage/token_storage.dart';
import 'base_service.dart';

class RefreshTokenService extends BaseService {
  static const String tokenEndpoint = "/tokens/refresh";

  RefreshTokenService();

  Future<dynamic> getJwtToken(String token, String refreshToken) async {
    // API endpoint for the token request
    const tokenUrl = apiBaseUrl + tokenEndpoint;

    // Request payload with email and password
    final payload = {"Token": token, "RefreshToken": refreshToken};

    Map<String, String> headers = getTenanHeader();

    try {
      // Send a POST request to the token API
      final response = await http.post(
        Uri.parse(tokenUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Assuming the API returns the token in the response JSON
        final responseJson = jsonDecode(response.body);
        final tokenResponse = responseJson;
        return tokenResponse;
      } else if (response.statusCode == 401) {
        await TokenStorage.removeJwtToken();
        return null;
      } else {
        return unknownError;
      }
    } catch (e) {
      return unknownError;
    }
  }
}
