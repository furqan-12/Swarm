import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/shoot_length.dart';

import '../consts/api.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class ShootLengthService extends BaseService {
  static const String shootLengthEndpoint = "/v1/ShootLengths";

  ShootLengthService();

  Future<List<ShootLength>?> getList(BuildContext context) async {
    const String shootLengthUrl = apiBaseUrl + shootLengthEndpoint;

    Map<String, String> headers = await getBasicHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(shootLengthUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<ShootLength> shootLength = responseData
            .map((item) => ShootLength(
                  item['id'].toString(),
                  item['name'].toString(),
                  item['totalPicks'],
                  item['rateMultiplier'],
                ))
            .toList();
        return shootLength;
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
