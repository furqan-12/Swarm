import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:swarm/services/response/order_recipt.dart';
import 'package:swarm/utils/image_helper.dart';
import 'package:swarm/services/response/order_advance_payment%20copy.dart';
import 'package:swarm/services/response/order_payment.dart';
import 'package:swarm/services/response/photographer_order.dart';

import '../consts/api.dart';
import '../consts/consts.dart';
import '../storage/models/order.dart';
import '../utils/loader.dart';
import 'base_service.dart';

class OrderService extends BaseService {
  static const String orderAdvancePaymentEndpoint =
      "/v1/orders/advance-payment-detail";
  static const String orderPaymentEndpoint = "/v1/orders/payment-detail";
  static const String orderIdEndpoint = "/v1/orders/order-id";
  static const String photographerOrdersEndpoint = "/v1/orders/photographers";
  static const String customerOrdersEndpoint = "/v1/orders/customers";
  static const String orderChatsEndpoint = "/v1/OrderChats/";
  static const String orderEndpoint = "/v1/Orders/";
  static const String orderReciptEndpoint = "/v1/orders/recipt";

  Future<dynamic> getOrderAdvancePaymentDetail(
      BuildContext context, OrderModel order) async {
    // API endpoint for the order request
    const orderAdvancePaymentUrl = apiBaseUrl + orderAdvancePaymentEndpoint;

    // Request payload
    final payload = {
      'PhotographerUserId': order.photographerUserId,
      'ShootTypeId': order.shootTypeId,
      'ShootSceneId': order.shootSceneId,
      'Address': order.address,
      'Longitude': order.longitude,
      'Latitude': order.latitude,
      'ShortAddress': order.shortAddress,
      'OrderDateTime': order.orderDateTime?.toIso8601String(),
      'ShootLength': order.shootLength,
    };

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      // Send a POST request to the registration API
      final response = await http.post(
        Uri.parse(orderAdvancePaymentUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final dynamic responseData = json.decode(response.body);
        final OrderAdvancePayment detail = OrderAdvancePayment(
          double.parse(responseData['advanceAmount'].toString()),
          double.parse(responseData['orderAmount'].toString()),
          responseData['clientSecret'].toString(),
        );
        return detail;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<dynamic> getOrderPaymentDetail(BuildContext context, String orderId,
      bool withLookedPhoto, double gratuityPer, String clientSecret) async {
    // API endpoint for the order request
    const orderAdvancePaymentUrl = apiBaseUrl + orderPaymentEndpoint;

    // Request payload
    final payload = {
      'orderId': orderId,
      'withLookedPhoto': withLookedPhoto,
      'gratuityPer': gratuityPer,
      'clientSecret': clientSecret,
    };

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      // Send a POST request to the registration API
      final response = await http.post(
        Uri.parse(orderAdvancePaymentUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final dynamic responseData = json.decode(response.body);
        final OrderPaymentDetail detail =
            OrderPaymentDetail.fromJson(responseData);
        return detail;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<dynamic> getOrderRecipt(BuildContext context, String orderId) async {
    // API endpoint for the order request
    var url = apiBaseUrl + orderReciptEndpoint + "?orderId=${orderId}";

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      // Send a Get request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final dynamic responseData = json.decode(response.body);
        final OrderRecipt detail = OrderRecipt.fromJson(responseData);
        return detail;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<String?> getOrderId(BuildContext context, String paymentIntent) async {
    // API endpoint for the order request
    const orderIdUrl = apiBaseUrl + orderIdEndpoint;

    // Request payload
    final payload = {
      'PaymentIntent': paymentIntent,
    };

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.post(
        Uri.parse(orderIdUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<PhotographerOrder?> getOrder(
      BuildContext context, String orderId, userId) async {
    // API endpoint for the order request
    final orderUrl = apiBaseUrl + orderEndpoint + orderId;

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(orderUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final responseData = json.decode(response.body);
        PhotographerOrder order =
            PhotographerOrder.fromJson(responseData, userId);

        return order;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<List<PhotographerOrder>?> getPhotographerOrders(
      BuildContext context, String userId) async {
    // API endpoint for the order request
    const ordersUrl = apiBaseUrl + photographerOrdersEndpoint;

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(ordersUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final List<dynamic> responseData = json.decode(response.body);
        final List<PhotographerOrder> photographerOrders = responseData
            .map((item) => PhotographerOrder.fromJson(item, userId))
            .toList();

        return photographerOrders;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<List<PhotographerOrder>?> getCustomerOrders(
      BuildContext context, String userId) async {
    // API endpoint for the order request
    const ordersUrl = apiBaseUrl + customerOrdersEndpoint;

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(ordersUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final List<dynamic> responseData = json.decode(response.body);
        final List<PhotographerOrder> photographerOrders = responseData
            .map((item) => PhotographerOrder.fromJson(item, userId))
            .toList();

        return photographerOrders;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<List<OrderChat>?> getOrderChats(
      BuildContext context, String orderId, String userId) async {
    // API endpoint for the order request
    final orderChatsUrl = apiBaseUrl + orderChatsEndpoint + orderId;

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(orderChatsUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final List<dynamic> responseData = json.decode(response.body);
        final List<OrderChat> orderChats = responseData
            .map((item) => OrderChat.fromJson(item, userId))
            .toList();

        return orderChats;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<OrderChat?> sendMessage(BuildContext context, String orderId,
      String message, String userId) async {
    // API endpoint for the order request
    const orderChatUrl = apiBaseUrl + orderChatsEndpoint;

    // Request payload
    final payload = {
      'OrderId': orderId,
      'Message': message,
    };

    Map<String, String> headers = await getAuthHeader();

    try {
      final response = await http.post(
        Uri.parse(orderChatUrl),
        body: jsonEncode(payload),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final responseData = json.decode(response.body);
        final OrderChat orderChat = OrderChat.fromJson(responseData, userId);
        return orderChat;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {}
  }

  Future<List<OrderPhoto>?> getOrderPhotos(
      BuildContext context, String orderId) async {
    // API endpoint for the order request
    final orderPhotosUrl = apiBaseUrl + orderEndpoint + orderId + "/photos";

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.get(
        Uri.parse(orderPhotosUrl),
        headers: headers,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // If the API call is successful (status code 200), parse the response body
        final List<dynamic> responseData = json.decode(response.body);
        final List<OrderPhoto> orderPhoto =
            responseData.map((item) => OrderPhoto.fromJson(item)).toList();

        return orderPhoto;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<bool?> sharePortfolio(BuildContext context, String orderId) async {
    // API endpoint for the order request
    final orderSharePhotosUrl =
        apiBaseUrl + orderEndpoint + orderId + "/photos/shared";

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.patch(
        Uri.parse(orderSharePhotosUrl),
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

  Future<bool?> rateOrder(
      BuildContext context, String orderId, double rate, String review) async {
    int intRate = rate.ceil().toInt(); // Round up and convert to int
    // API endpoint for the order request
    final orderRateUrl =
        apiBaseUrl + orderEndpoint + orderId + "/rate/" + intRate.toString();

    Map<String, String> headers = await getAuthHeader();

    // Request payload
    final payload = {
      'orderId': orderId,
      'rating': intRate,
      'review': review,
    };

    try {
      LoaderHelper.show(context);
      final response = await http.post(
        Uri.parse(orderRateUrl),
        body: jsonEncode(payload),
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

  Future<bool?> acceptOrder(BuildContext context, String orderId) async {
    // API endpoint for the order request
    final orderRateUrl = apiBaseUrl + orderEndpoint + orderId + "/accept";

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.patch(
        Uri.parse(orderRateUrl),
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

  Future<bool?> declineOrder(BuildContext context, String orderId) async {
    // API endpoint for the order request
    final orderRateUrl = apiBaseUrl + orderEndpoint + orderId + "/decline";

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.patch(
        Uri.parse(orderRateUrl),
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

  Future<bool?> deactiveOrder(BuildContext context, String orderId) async {
    // API endpoint for the order request
    final orderRateUrl = apiBaseUrl + orderEndpoint + orderId + "/deactive";

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.patch(
        Uri.parse(orderRateUrl),
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

  Future<bool?> deleteUploadedOrderPhoto(
      BuildContext context, String orderId, String orderPhotoId) async {
    // API endpoint for the order request
    final orderRateUrl =
        apiBaseUrl + orderEndpoint + orderId + "/photo/" + orderPhotoId;

    Map<String, String> headers = await getAuthHeader();

    try {
      final response = await http.delete(
        Uri.parse(orderRateUrl),
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
    } finally {}
  }

  Future<bool?> uploadOrderPhoto(BuildContext context, String orderId,
      bool isLooked, File orderImage, File? thumbnailImageFile) async {
    final url = apiBaseUrl + orderEndpoint + orderId + "/photos";

    Map<String, String> headers = await getAuthHeader();

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add the image as a file field
      var image = await http.MultipartFile.fromPath(
        'Image', // This should match the name expected by the API
        orderImage.path,
        contentType: MediaType('image',
            getImageExtension(orderImage)), // Adjust the content type as needed
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
      request.fields['orderId'] = orderId.toString();
      request.fields['isLooked'] = isLooked.toString();
      request.headers.addAll(headers);

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {}
  }

  Future<bool?> deleteOrderPhoto(
      BuildContext context, String orderId, String id) async {
    // API endpoint for the order request
    final orderRateUrl = apiBaseUrl + orderEndpoint + orderId + "/photos/" + id;

    Map<String, String> headers = await getAuthHeader();

    try {
      LoaderHelper.show(context);
      final response = await http.delete(
        Uri.parse(orderRateUrl),
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

  Future<int> unreadCount() async {
    final orderRateUrl = apiBaseUrl + orderChatsEndpoint + "unread-count";

    Map<String, String> headers = await getAuthHeader();

    try {
      final response = await http.get(
        Uri.parse(orderRateUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    } finally {}
  }

  Future<int> notifyCount() async {
    final orderRateUrl = apiBaseUrl + orderEndpoint + "notify-count";

    Map<String, String> headers = await getAuthHeader();

    try {
      final response = await http.get(
        Uri.parse(orderRateUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        // final errorJson = jsonDecode(response.body);
        // final errorMessage = errorJson['exception'] as String;
        return 0; // Return the error message to display to the user
      }
    } catch (e) {
      return 0;
    } finally {}
  }
}
