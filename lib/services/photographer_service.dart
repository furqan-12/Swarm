import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/services/refresh_token_service.dart';
import 'package:swarm/services/response/photographerstat.dart';
import 'package:swarm/storage/models/token.dart';
import 'package:swarm/storage/token_storage.dart';

import '../consts/api.dart';
import '../consts/consts.dart';
import '../storage/models/registration.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class PhotographerService extends BaseService {
  static const String registrationEndpoint = "/v1/registration/photographer";

  PhotographerService();

  Future<dynamic> updateProfile(
      BuildContext context, RegistrationModel registration) async {
    const String registrationUrl = apiBaseUrl + registrationEndpoint;
    // Request payload
    final payload = {
      'ProfileTypeId': registration.profileTypeId,
      'UserName': registration.userName,
      'Bio': registration.bio,
      'HoodId': registration.hoodId,
      'Hoods': registration.hoodIds,
      'ExperienceId': registration.experienceId,
      'ShootingDeviceId': registration.shootingDeviceId,
      'Skills': registration.skillIds,
      'Schedules': registration.schedules,
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

      // Check if the request was successful (status code 200)
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
        // Assuming the API returns the registration in the response JSON
      } else {
        return false;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<PhotographerStat?> getStats(BuildContext context, String id) async {
    String url = apiBaseUrl + '/v1/photographers/${id}/stats';

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        final PhotographerStat photographer = PhotographerStat(
          id: responseData['id'],
          imagePath: apiImageBaseUrl + responseData['imagePath'],
          rating: double.parse(responseData['rating'].toString()),
          name: responseData['name'],
          perHourRate: double.parse(responseData['perHourRate'].toString()),
          experienceName: responseData['experienceName'],
          experience: 2,
          experienceId: responseData['experienceId'],
          totalOrder: responseData['totalOrder'],
          profileLive: DateTime.parse(responseData['profileLive']),
          YealyEarned: double.parse(responseData['yealyEarned'].toString()),
          MonthlyEarned: double.parse(responseData['monthlyEarned'].toString()),
          reviews: (responseData['reviews'] as List<dynamic>)
              .map(
                (review) => PhotographerReview(
                    id: review['id'],
                    rating: int.parse(review['rating'].toString()),
                    review: review['review'],
                    imagePath: apiImageBaseUrl + review['imagePath'],
                    reviewDate: DateTime.parse(review['reviewDate'])),
              )
              .toList(),
        );
        return photographer;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }
}
