import 'dart:convert';
import 'package:http/http.dart' as http;

import '../consts/api.dart';
import '../consts/consts.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class TokenService extends BaseService {
  static const String tokenEndpoint = "/tokens";
  static const String appleEndpoint = "/tokens/apple-sign-in";

  TokenService();

  Future<dynamic> getJwtToken(
      BuildContext context, String email, String password) async {
    // API endpoint for the token request
    const tokenUrl = apiBaseUrl + tokenEndpoint;

    // Request payload with email and password
    final payload = {
      'Email': email,
      'Password': password,
    };

    Map<String, String> headers = getTenanHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.post(
        Uri.parse(tokenUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final tokenResponse = responseJson;
        return tokenResponse;
      } else {
        final errorJson = jsonDecode(response.body);
        final errorMessage = errorJson['exception'] as String;
        return errorMessage; // Return the error message to display to the user
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

    Future<dynamic> getJwtTokenAppleIds(
      BuildContext context, String authCode) async {
    // API endpoint for the token request
    const tokenUrl = apiBaseUrl + appleEndpoint;

    // Request payload with email and password
    final payload = {
      'id_token': authCode,
    };

    Map<String, String> headers = getTenanHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.post(
        Uri.parse(tokenUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final tokenResponse = responseJson;
        return tokenResponse;
      } else {
        final errorJson = jsonDecode(response.body);
        final errorMessage = errorJson['exception'] as String;
        return errorMessage; // Return the error message to display to the user
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }
}
