class Schedule {
  final String dayId;
  final String name;
  late DateTime from;
  late DateTime to;
  late int fromHour;
  late int toHour;
  late bool isActive;

  Schedule(this.dayId, this.name, this.from, this.to, this.fromHour,
      this.toHour, this.isActive);

  Map<String, dynamic> toJson() => {
        'dayId': dayId,
        'name': name,
        'from': from.toIso8601String(), // Convert DateTime to string
        'to': to.toIso8601String(), // Convert DateTime to string
        'fromHour': fromHour,
        'toHour': toHour,
        'isActive': isActive,
      };

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      json['dayId'],
      json['name'],
      DateTime.parse(json['from']), // Parse string to DateTime
      DateTime.parse(json['to']), // Parse string to DateTime
      json['fromHour'],
      json['toHour'],
      json['isActive'],
    );
  }
}

class RegistrationModel {
  String profileTypeId;
  String? userName;
  String? bio;
  String? profileImageUrl;
  String? cityId;
  String? boroughId;
  String? hoodId;
  List<String>? hoodIds;
  String? brandChoiceId;
  String? experienceId;
  String? shootingDeviceId;
  List<String>? skillIds;
  List<Map<String, dynamic>>? schedules;

  RegistrationModel({
    required this.profileTypeId,
    this.userName,
    this.bio,
    this.profileImageUrl,
    this.cityId,
    this.boroughId,
    this.hoodId,
    this.hoodIds,
    this.brandChoiceId,
    this.experienceId,
    this.shootingDeviceId,
    this.skillIds,
    this.schedules,
  });

  RegistrationModel.fromJson(Map<String, dynamic> json)
      : profileTypeId = json['profileTypeId'],
        userName = json['userName'],
        bio = json['bio'],
        profileImageUrl = json['profileImage'],
        cityId = json['cityId'],
        boroughId = json['boroughId'],
        hoodId = json['hoodId'],
        hoodIds = (json['hoodIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        brandChoiceId = json['brandChoiceId'],
        experienceId = json['experienceId'],
        shootingDeviceId = json['shootingDeviceId'],
        skillIds = (json['skillIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        schedules = json['schedules'] != null
            ? List<Map<String, dynamic>>.from(json['schedules'])
            : null;

  Map<String, dynamic> toJson() => {
        'profileTypeId': profileTypeId,
        'userName': userName,
        'bio': bio,
        'profileImage': profileImageUrl,
        'cityId': cityId,
        'boroughId': boroughId,
        'hoodId': hoodId,
        'hoodIds': hoodIds,
        'brandChoiceId': brandChoiceId,
        'experienceId': experienceId,
        'shootingDeviceId': shootingDeviceId,
        'skillIds': skillIds,
        'schedules': schedules
            ?.map((schedule) => Map<String, dynamic>.from(schedule))
            .toList(),
      };
}
