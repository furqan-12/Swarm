import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/services/response/city.dart';

import '../consts/api.dart';
import '../consts/consts.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class CityService extends BaseService {
  static const String cityEndpoint = "/v1/cities";

  Future<dynamic> getCities(BuildContext context) async {
    // API endpoint for the city request
    const cityUrl = apiBaseUrl + cityEndpoint;

    Map<String, String> headers = getBasicHeader();

    try {
      LoaderHelper.show(context);
      // Send a GET request to the city API
      final response = await http.get(
        Uri.parse(cityUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final List<dynamic> responseData = json.decode(response.body);
        final List<City> cities = responseData
            .map((item) => City(
                  item['id'].toString(),
                  item['name'].toString(),
                  isSelected: false,
                ))
            .toList();
        return cities;
      } else {}
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }
}
