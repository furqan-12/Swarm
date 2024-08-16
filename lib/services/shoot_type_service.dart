import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/shoot_type.dart';

import '../consts/api.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class ShootTypeService extends BaseService {
  static const String shootTypeEndpoint = "/v1/ShootTypes";

  ShootTypeService();

  Future<dynamic> getList(BuildContext context) async {
    const String shootTypeUrl = apiBaseUrl + shootTypeEndpoint;

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(shootTypeUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<ShootType> shootTypes = responseData
            .map((item) => ShootType(
                  item['id'].toString(),
                  item['name'].toString(),
                  apiImageBaseUrl + item['imagePath'].toString(),
                ))
            .toList();
        return shootTypes;
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
