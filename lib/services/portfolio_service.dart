import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:swarm/utils/image_helper.dart';

import '../consts/api.dart';
import '../consts/consts.dart';
import 'base_service.dart';

class PortfolioService extends BaseService {
  static const String portfolioEndpoint = "/v1/photographers/portfolio";

  PortfolioService();

  Future<dynamic> addPortfolioImage(
      BuildContext context, File imageFile, File? thumbnailImageFile) async {
    final String registrationUrl = apiBaseUrl + portfolioEndpoint;
    Map<String, String> headers = await getAuthHeader();

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(registrationUrl));

      // Add the image as a file field
      var image = await http.MultipartFile.fromPath(
        'Image', // This should match the name expected by the API
        imageFile.path,
        contentType: MediaType('image',
            getImageExtension(imageFile)), // Adjust the content type as needed
      );

      request.files.add(image);

      if (thumbnailImageFile != null) {
        var thumbnailImage = await http.MultipartFile.fromPath(
          'ThumbnailImage', // This should match the name expected by the API
          thumbnailImageFile.path,
          contentType: MediaType(
              'image',
              getImageExtension(
                  thumbnailImageFile)), // Adjust the content type as needed
        );
        request.files.add(thumbnailImage);
      }

      request.headers.addAll(headers);

      // Send the request
      final response = await request.send();

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        return true;
        // Assuming the API returns the registration in the response JSON
      } else {
        return false;
      }
    } catch (e) {
      return null;
    }
  }
}
