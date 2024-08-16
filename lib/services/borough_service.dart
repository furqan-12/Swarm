import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/services/response/borough.dart';

import '../consts/api.dart';
import '../consts/consts.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class BoroughService extends BaseService {
  static const String boroughEndpoint = "/v1/boroughs/";

  Future<dynamic> getBoroughs(BuildContext context, String cityId) async {
    // API endpoint for the borough request
    var boroughUrl = apiBaseUrl + boroughEndpoint + cityId;

    Map<String, String> headers = getBasicHeader();

    try {
      LoaderHelper.show(context);
      // Send a GET request to the borough API
      final response = await http.get(
        Uri.parse(boroughUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final List<dynamic> responseData = json.decode(response.body);
        final List<Borough> boroughs = responseData
            .map((item) => Borough(
                  item['id'].toString(),
                  item['name'].toString(),
                  item['cityId'].toString(),
                  isSelected: false,
                ))
            .toList();
        return boroughs;
      } else {}
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }
}
