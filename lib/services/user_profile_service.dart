import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/user.dart';
import 'package:swarm/utils/image_helper.dart';
import 'package:http_parser/http_parser.dart';

import '../consts/api.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class UserProfileService extends BaseService {
  static const String UserProfileEndpoint = "/personal";

  UserProfileService();

  Future<dynamic> getUserProfile(
    BuildContext? context,
  ) async {
    const String UserProfileUrl = apiBaseUrl + UserProfileEndpoint;

    Map<String, String> headers = await getAuthHeader();

    try {
      if (context != null) LoaderHelper.show(context);
      // Send a POST request to the registration API
      final response = await http.get(
        Uri.parse(UserProfileUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final dynamic responseData = json.decode(response.body);
        final UserProfile userProfiles = UserProfile(
          responseData['id'].toString(),
          responseData['firstName'].toString(),
          responseData['bio'].toString(),
          responseData['email'].toString(),
          responseData['profileTypeId'].toString(),
          responseData['enablePushNotification'],
          responseData['profileCompleted'],
          apiImageBaseUrl + responseData['imageUrl'].toString(),
        );
        return userProfiles;
        // Assuming the API returns the registration in the response JSON
      } else {
        final errorJson = jsonDecode(response.body);
        final errorMessage = errorJson['exception'] as String;
        return errorMessage; // Return the error message to display to the user
      }
    } catch (e) {
      return unknownError;
    } finally {
      if (context != null) LoaderHelper.hide();
    }
  }

  Future<dynamic> updateUserProfile(BuildContext context, String userName,
      String bio, File? profileImage) async {
    const String url = apiBaseUrl + UserProfileEndpoint;

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      if (profileImage != null) {
        // Add the image as a file field
        var image = await http.MultipartFile.fromPath(
          'ProfileImage', // This should match the name expected by the API
          profileImage.path,
          contentType: MediaType(
              'image',
              getImageExtension(
                  profileImage)), // Adjust the content type as needed
        );

        request.files.add(image);
      }

      request.headers.addAll(headers);
      request.fields['userName'] = userName.toString();
      request.fields['bio'] = bio.toString();

      // Send the request
      final response = await request.send();
      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        return true;
      } else {
        return unknownError; // Return the error message to display to the user
      }
    } catch (e) {
      return unknownError;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<bool?> toggleNotification(BuildContext context) async {
    // API endpoint for the order request
    const url = apiBaseUrl + UserProfileEndpoint + "/toggle-push-notification";

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        return true;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<dynamic> changePassword(BuildContext context, String oldPassword,
      String changePassword, String retryPassword) async {
    // API endpoint for the order request
    const url = apiBaseUrl + UserProfileEndpoint + "/change-password";

    Map<String, String> headers = await getAuthHeader();

    final body = json.encode({
      'Password': oldPassword,
      'NewPassword': changePassword,
      'ConfirmNewPassword': retryPassword,
    });

    try {
      LoaderHelper.show(context);
      final response = await http.put(
        Uri.parse(url),
        body: body,
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        return true;
      } else {
        final errorJson = jsonDecode(response.body);
        final errorMessage = errorJson['messages'][0] as String;
        return errorMessage; // Return the error message to display to the user
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<dynamic> forgetPassword(BuildContext context, String email) async {
    // API endpoint for the order request
    const url = apiBaseUrl + "/users/forgot-password";

    Map<String, String> headers = await getTenanHeader();

    final body = json.encode({
      'email': email,
    });

    try {
      LoaderHelper.show(context);
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        return response.body;
      } else {
        final errorJson = jsonDecode(response.body);
        final errorMessage = errorJson['messages'][0] as String;
        return errorMessage; // Return the error message to display to the user
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<dynamic> resetPassword(BuildContext context, String email,
      String newPassword, String code) async {
    // API endpoint for the order request
    const url = apiBaseUrl + "/users/reset-password";

    Map<String, String> headers = await getTenanHeader();

    final body = json.encode({
      'email': email,
      'password': newPassword,
      'token': code,
    });

    try {
      LoaderHelper.show(context);
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        return response.body;
      } else {
        final errorJson = jsonDecode(response.body);
        final errorMessage = errorJson['messages'][0] as String;
        return errorMessage; // Return the error message to display to the user
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<void> sendDeviceToken(String token) async {
    const String url = apiBaseUrl + UserProfileEndpoint + "/device-token";

    // Request payload
    final payload = {
      'token': token,
    };

    Map<String, String> headers = await getAuthHeader();

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: headers,
      );

      if (response.statusCode == 200) {}
    } catch (e) {
    } finally {}
  }

  Future<bool?> setIsOnline(bool isOnline) async {
    // API endpoint for the order request
    // var url =
    //     apiBaseUrl + UserProfileEndpoint + "/is-online/" + isOnline.toString();

    // Map<String, String> headers = await getAuthHeader();

    // try {
    //   final response = await http.post(
    //     Uri.parse(url),
    //     headers: headers,
    //   );

    //   if (response.statusCode == 200) {
    //     return true;
    //   } else {
    //     return null;
    //   }
    // } catch (e) {
    //   return null;
    // } finally {}
    return true;
  }

  Future<bool?> deleteAccount() async {
    // API endpoint for the order request
    var url = apiBaseUrl + UserProfileEndpoint + "/delete-account";

    Map<String, String> headers = await getAuthHeader();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {}
  }

  Future<bool> getIsOnline(String userId) async {
    // API endpoint for the order request
    // var url = apiBaseUrl + UserProfileEndpoint + "/" + userId + "/is-online";

    // Map<String, String> headers = await getAuthHeader();

    // try {
    //   final response = await http.get(
    //     Uri.parse(url),
    //     headers: headers,
    //   );

    //   if (response.statusCode == 200) {
    //     return true;
    //   } else {
    //     return false;
    //   }
    // } catch (e) {
    //   return false;
    // } finally {}
    return true;
  }

  Future<bool> sendMessage(BuildContext context, String message) async {
    var url = apiBaseUrl + "/admin/contact-us";

    Map<String, String> headers = await getAuthHeader();

    final body = json.encode({
      'message': message,
    });

    try {
      LoaderHelper.show(context);
      final response = await http.put(
        Uri.parse(url),
        body: body,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      LoaderHelper.hide();
    }
  }
}
