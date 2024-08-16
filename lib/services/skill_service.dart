import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/services/response/skill.dart';

import '../consts/api.dart';
import '../consts/consts.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class SkillService extends BaseService {
  static const String skillEndpoint = "/v1/skills";

  Future<dynamic> getSkills(BuildContext context) async {
    const skillUrl = apiBaseUrl + skillEndpoint;

    Map<String, String> headers = getBasicHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(skillUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<Skill> skills = responseData
            .map((item) => Skill(
                  item['id'].toString(),
                  item['name'].toString(),
                  isSelected: false,
                ))
            .toList();
        return skills;
      } else {}
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }
}
