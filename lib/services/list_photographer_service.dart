import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/photographer.dart';
import 'package:swarm/services/response/photographerstat.dart';

import '../consts/api.dart';
import '../storage/models/order.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class ListPhotographerService extends BaseService {
  static const String endpoint = "/v1/photographers";

  ListPhotographerService();

  Future<List<Photographer>?> getList(
      BuildContext context, OrderModel order) async {
    const String url = apiBaseUrl + endpoint;

    Map<String, String> headers = await getAuthHeader();

    // Request payload
    final payload = {
      'latitude': order.latitude,
      'longitude': order.longitude,
      'shootLength': order.shootLength,
      'shootTypeId': order.shootTypeId,
      'orderDateTime': order.orderDateTime?.toIso8601String(),
    };

    try {
      LoaderHelper.show(context);
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<Photographer> photographers = responseData
            .map((item) => Photographer(
                id: item['id'],
                imagePath: apiImageBaseUrl + item['imagePath'],
                rating: double.parse(item['rating'].toString()),
                distance: item['distance'] != null
                    ? double.parse(item['distance'].toString())
                    : null,
                name: item['name'],
                bio: item['bio'],
                perHourRate: double.parse(item['perHourRate'].toString()),
                experienceName: item['experienceName'],
                experience: item['experience'],
                experienceId: item['experienceId'],
                portfolios: (item['portfolios'] as List<dynamic>)
                    .map(
                      (portfolioItem) => PhotographerPortfolio(
                          id: portfolioItem['id'],
                          imagePath:
                              apiImageBaseUrl + portfolioItem['imagePath'],
                          isVideo: portfolioItem['isVideo'] ?? false,
                          thumbnailPath: apiImageBaseUrl +
                              ((portfolioItem["thumbnailPath"]) == null
                                  ? ""
                                  : portfolioItem["thumbnailPath"])),
                    )
                    .toList(),
                reviews: item['reviews'] != null
                    ? (item['reviews'] as List<dynamic>)
                        .map(
                          (review) => PhotographerReview(
                              id: review['id'],
                              rating: int.parse(review['rating'].toString()),
                              review: review['review'],
                              imagePath: review['imagePath'],
                              reviewDate: review['reviewDate']),
                        )
                        .toList()
                    : [],
                isVideographer: item['isVideographer'],
                isPhotographer: item['isPhotographer']))
            .toList();
        return photographers;
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
