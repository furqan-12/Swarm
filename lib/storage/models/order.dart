class OrderModel {
  String shootTypeId;
  String shootTypeName;
  String? photographerUserId;
  String? shootSceneId;
  String? shootSceneName;
  String? address;
  String? shortAddress;
  double? longitude;
  double? latitude;
  DateTime? orderDateTime;
  int? shootLength;
  String? shootLengthName;
  int? totalPicks;
  int? rateMultiplier;
  String? experienceId;

  OrderModel(
      {required this.shootTypeId,
      required this.shootTypeName,
      this.photographerUserId,
      this.shootSceneId,
      this.shootSceneName,
      this.address,
      this.shortAddress,
      this.longitude,
      this.latitude,
      this.orderDateTime,
      this.shootLength,
      this.shootLengthName,
      this.totalPicks,
      this.rateMultiplier,
      this.experienceId});

  OrderModel.fromJson(Map<String, dynamic> json)
      : photographerUserId = json['photographerUserId'],
        shootTypeId = json['shootTypeId'],
        shootTypeName = json['shootTypeName'],
        shootSceneId = json['shootSceneId'],
        shootSceneName = json['shootSceneName'],
        address = json['address'],
        shortAddress = json['shortAddress'],
        longitude = json['longitude'],
        latitude = json['latitude'],
        orderDateTime = json['orderDateTime'] == null
            ? DateTime.now()
            : DateTime.parse(json['orderDateTime']),
        shootLength = json['shootLength'],
        shootLengthName = json['shootLengthName'],
        totalPicks = json['totalPicks'],
        rateMultiplier = json['rateMultiplier'],
        experienceId = json['experienceId'];

  Map<String, dynamic> toJson() => {
        'photographerUserId': photographerUserId,
        'shootTypeId': shootTypeId,
        'shootTypeName': shootTypeName,
        'shootSceneId': shootSceneId,
        'shootSceneName': shootSceneName,
        'address': address,
        'shortAddress': shortAddress,
        'longitude': longitude,
        'latitude': latitude,
        'orderDateTime':
            orderDateTime?.toIso8601String(), // Convert DateTime to string
        'shootLength': shootLength,
        'shootLengthName': shootLengthName,
        'totalPicks': totalPicks,
        'rateMultiplier': rateMultiplier,
        'experienceId': experienceId,
      };
}
