import 'dart:convert';
import 'package:http/http.dart' as http;

import '../consts/api.dart';
import '../consts/consts.dart';
import '../storage/models/registration.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class PhotographerScheduleService extends BaseService {
  static const String photographerScheduleEndpoint =
      "/v1/photographers/schedule";

  PhotographerScheduleService();

  Future<dynamic> updateSchedule(
      BuildContext context, List<Schedule> schedules) async {
    const String url = apiBaseUrl + photographerScheduleEndpoint;
    // Request payload
    final payload = {
      'Schedules': schedules,
    };

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      // Send a POST request to the registration API
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
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

  Future<List<Schedule>?> getSchedule(
    BuildContext context,
  ) async {
    const String url = apiBaseUrl + photographerScheduleEndpoint;

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      // Send a POST request to the registration API
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<Schedule> schedule =
            responseData.map((item) => Schedule.fromJson(item)).toList();

        return schedule;
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
