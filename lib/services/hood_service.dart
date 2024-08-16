import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/services/response/hood.dart';

import '../consts/api.dart';
import '../consts/consts.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class HoodService extends BaseService {
  static const String hoodEndpoint = "/v1/hoods/";

  Future<dynamic> getHoods(BuildContext context, String boroughId) async {
    // API endpoint for the hood request
    var hoodUrl = apiBaseUrl + hoodEndpoint + boroughId;

    Map<String, String> headers = getBasicHeader();

    try {
      LoaderHelper.show(context);
      // Send a GET request to the hood API
      final response = await http.get(
        Uri.parse(hoodUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final List<dynamic> responseData = json.decode(response.body);
        final List<Hood> hoods = responseData
            .map((item) => Hood(
                  item['id'],
                  item['name'].toString(),
                  item['boroughId'].toString(),
                  item['longitude'],
                  item['latitude'],
                  isSelected: false,
                ))
            .toList();
        return hoods;
      } else {}
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }
}
