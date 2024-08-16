import '../../consts/api.dart';
import '../../utils/date_time_helper.dart';

class PhotographerOrder {
  String id;
  String orderNo;
  String photographerUserId;
  double photographerRating;
  String? photographerName;
  String? photographerProfileImage;
  String customerUserId;
  String? customerName;
  String? customerProfileImage;
  String shootTypeName;
  String shootSceneName;
  String address;
  double longitude;
  double latitude;
  String shortAddress;
  DateTime orderPlaceDateTime;
  DateTime orderDateTime;
  String shootLengthName;
  int shootLength;
  String experienceId;
  String orderStatusName;
  int orderStatusNo;
  double orderAmount;
  int? rating;
  List<OrderPhoto> orderPhotos;
  List<OrderChat> orderChats;
  int unreadMessageCount;
  String? lastChatMessage;
  DateTime? lastChatMessageDateTime;
  int timeLineType;
  String dateFormated;
  bool isOnline;
  int newRequestStatus = 0;
  bool IsSharedToCustomer = false;

  PhotographerOrder({
    required this.id,
    required this.orderNo,
    required this.photographerUserId,
    required this.photographerRating,
    this.photographerName,
    this.photographerProfileImage,
    required this.customerUserId,
    this.customerName,
    this.customerProfileImage,
    required this.shootTypeName,
    required this.shootSceneName,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.shortAddress,
    required this.orderPlaceDateTime,
    required this.orderDateTime,
    required this.shootLengthName,
    required this.shootLength,
    required this.experienceId,
    required this.orderStatusName,
    required this.orderStatusNo,
    required this.orderAmount,
    this.rating,
    required this.orderPhotos,
    required this.orderChats,
    required this.unreadMessageCount,
    this.lastChatMessage,
    this.lastChatMessageDateTime,
    required this.timeLineType,
    required this.dateFormated,
    required this.isOnline,
    required this.IsSharedToCustomer,
  });

  // Additional constructor to parse from JSON
  factory PhotographerOrder.fromJson(Map<String, dynamic> json, String userId) {
    return PhotographerOrder(
      id: json['id'],
      orderNo: json['orderNo'],
      photographerUserId: json['photographerUserId'],
      photographerName: json['photographerName']?.trim(),
      photographerProfileImage:
          apiImageBaseUrl + json['photographerProfileImage'],
      photographerRating: json['photographerRating'].toDouble(),
      customerUserId: json['customerUserId'],
      customerName: json['customerName']?.trim(),
      customerProfileImage: apiImageBaseUrl + json['customerProfileImage'],
      shootTypeName: json['shootTypeName'],
      shootSceneName: json['shootSceneName'],
      address: json['address'],
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
      shortAddress: json['shortAddress'],
      orderPlaceDateTime:
          convertUtcToLocal(DateTime.parse(json['orderPlaceDateTime'])),
      orderDateTime: convertUtcToLocal(DateTime.parse(json['orderDateTime'])),
      shootLengthName: json['shootLengthName'],
      shootLength: json['shootLength'],
      experienceId: json['experienceId'],
      orderStatusName: json['orderStatusName'],
      orderStatusNo: json['orderStatusNo'],
      orderAmount: json['orderAmount'].toDouble(),
      rating: json['rating'],
      orderPhotos: json['orderPhotos'] == null
          ? []
          : (json['orderPhotos'] as List<dynamic>)
              .map((item) => OrderPhoto.fromJson(item))
              .toList(),
      orderChats: json['orderChats'] == null
          ? []
          : (json['orderChats'] as List<dynamic>)
              .map((item) => OrderChat.fromJson(item, userId))
              .toList(),
      unreadMessageCount: json['unreadMessageCount'],
      lastChatMessage: json['lastChatMessage'],
      lastChatMessageDateTime: convertUtcToLocal(
          json['lastChatMessageDateTime'] != null
              ? DateTime.parse(json['lastChatMessageDateTime'])
              : null),
      timeLineType: json['timeLineType'],
      dateFormated: json['dateFormated'],
      isOnline: json['isOnline'],
      IsSharedToCustomer: json['isSharedToCustomer'],
    );
  }
}

class OrderPhoto {
  String id;
  String orderId;
  String? imagePath;
  bool isLocked;
  String? blurImagePath;
  bool isSharedToCustomer;
  DateTime uploadDateTime;
  bool? isVideo;
  String? thumbnailPath;

  OrderPhoto({
    required this.id,
    required this.orderId,
    this.imagePath,
    required this.isLocked,
    this.blurImagePath,
    required this.isSharedToCustomer,
    required this.uploadDateTime,
    this.isVideo,
    this.thumbnailPath,
  });

  // Additional constructor to parse from JSON
  factory OrderPhoto.fromJson(Map<String, dynamic> json) {
    return OrderPhoto(
      id: json['id'],
      orderId: json['orderId'],
      imagePath: apiImageBaseUrl + json['imagePath'],
      isVideo: json['isVideo'] ?? false,
      thumbnailPath: apiImageBaseUrl +
          ((json["thumbnailPath"]) == null ? "" : json["thumbnailPath"]),
      isLocked: json['isLocked'],
      blurImagePath: apiImageBaseUrl + json['blurImagePath'],
      isSharedToCustomer: json['isSharedToCustomer'],
      uploadDateTime: convertUtcToLocal(DateTime.parse(json['uploadDateTime'])),
    );
  }
}

class OrderChat {
  String? id;
  String? orderId;
  String fromUserId;
  String toUserId;
  String? heading;
  String message;
  DateTime dateTime;
  String? imagePath;
  String? imageText;
  String? navigation;
  String? navigationText;
  bool isRead;
  bool fromSystem;
  bool isUserMessage;

  OrderChat({
    this.id,
    this.orderId,
    required this.fromUserId,
    required this.toUserId,
    this.heading,
    required this.message,
    required this.dateTime,
    this.imagePath,
    this.imageText,
    this.navigation,
    this.navigationText,
    required this.isRead,
    required this.fromSystem,
    required this.isUserMessage,
  });

  // Additional constructor to parse from JSON
  factory OrderChat.fromJson(Map<String, dynamic> json, String myUserId) {
    return OrderChat(
      id: json['id'],
      orderId: json['orderId'],
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      heading: json['heading'],
      message: json['message'],
      dateTime: convertUtcToLocal(DateTime.parse(json['dateTime'])),
      imagePath:
          json['imagePath'] != null ? apiImageBaseUrl + json['imagePath'] : '',
      imageText: json['imageText'],
      navigation: json['navigation'],
      navigationText: json['navigationText'],
      isRead: json['isRead'],
      fromSystem: json['fromSystem'],
      isUserMessage: json['fromUserId'] == myUserId,
    );
  }
}
