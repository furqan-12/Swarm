import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/refresh_token_service.dart';
import 'package:swarm/storage/models/token.dart';
import 'package:swarm/storage/token_storage.dart';

import '../consts/api.dart';
import '../storage/models/registration.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class CustomerService extends BaseService {
  final RegistrationModel registration;

  static const String modelRegistrationEndpoint = "/v1/registration/model";
  static const String brandRegistrationEndpoint = "/v1/registration/brand";

  CustomerService(this.registration);

  Future<dynamic> updateProfile(BuildContext context) async {
    String registrationUrl = '';

    if (registration.profileTypeId == ModelTypeId) {
      registrationUrl = apiBaseUrl + modelRegistrationEndpoint;
    } else {
      registrationUrl = apiBaseUrl + brandRegistrationEndpoint;
    }

    // Request payload
    final payload = {
      'ProfileTypeId': registration.profileTypeId,
      'userName': registration.userName,
      'bio': registration.bio,
      'brandChoice': registration.brandChoiceId,
      'cityId': registration.cityId,
    };

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      // Send a POST request to the registration API
      final response = await http.post(
        Uri.parse(registrationUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      if (response.statusCode == 200) {
        TokenModel? token = await TokenStorage.getToken;
        if (token != null) {
          final refreshTokenService = RefreshTokenService();
          final tokenResponse = await refreshTokenService.getJwtToken(
              token.token, token.refreshToken);
          if (tokenResponse != null && tokenResponse is String) {
          } else if (tokenResponse != null) {
            await TokenStorage.setJwtToken(jsonEncode(tokenResponse));
            token = TokenModel.fromJson(tokenResponse);
          }
        }
        return true;
      } else {
        final errorJson = jsonDecode(response.body);
        final errorMessage = errorJson['exception'] as String;
        return errorMessage; // Return the error message to display to the user
      }
    } catch (e) {
      return unknownError;
    } finally {
      LoaderHelper.hide();
    }
  }
}
