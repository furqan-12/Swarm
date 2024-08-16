import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/services/token_service.dart';

import '../consts/api.dart';
import '../consts/consts.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class RegistrationService extends BaseService {
  static const String registrationEndpoint = "/users/self-register";

  RegistrationService();

  Future<dynamic> userRegistration(
      BuildContext context, String email, String password) async {
    // API endpoint for the registration request
    const registrationUrl = apiBaseUrl + registrationEndpoint;

    // Request payload with email and password
    final payload = {
      'Email': email,
      'Password': password,
    };

    Map<String, String> headers = getTenanHeader();

    try {
      LoaderHelper.show(context);
      // Send a POST request to the registration API
      final response = await http.post(
        Uri.parse(registrationUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Assuming the API returns the registration in the response JSON

        // Call the TokenRequest to get the JWT token
        final tokenRequest = TokenService();
        final tokenResponse =
            await tokenRequest.getJwtToken(context, email, password);
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
