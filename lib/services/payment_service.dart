import 'package:http/http.dart' as http;

import '../consts/api.dart';
import 'base_service.dart';

class PaymentService extends BaseService {
  Future<String?> getPublishableKey() async {
    try {
      const url = apiBaseUrl + "/v1/stripe/stripe-publishable-key";

      Map<String, String> headers = await getBasicHeader();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        // final errorJson = jsonDecode(response.body);
        // final errorMessage = errorJson['exception'] as String;
        return null; // Return the error message to display to the user
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> createAccount() async {
    const url = apiBaseUrl + "/v1/stripe/create-stripe-account";

    Map<String, String> headers = await getAuthHeader();

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }
}
