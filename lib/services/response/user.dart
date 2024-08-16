class UserProfile {
  String id;
  String name;
  String bio;
  String email;
  String profileTypeId;
  bool enablePushNotification;
  bool profileCompleted;
  String imageUrl;

  UserProfile(
    this.id,
    this.name,
    this.bio,
    this.email,
    this.profileTypeId,
    this.enablePushNotification,
    this.profileCompleted,
    this.imageUrl,
  );

  UserProfile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        bio = json['bio'],
        email = json['email'],
        profileTypeId = json['profileTypeId'],
        enablePushNotification = json['enablePushNotification'],
        profileCompleted = json['profileCompleted'],
        imageUrl = json['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bio': bio,
        'email': email,
        'profileTypeId': profileTypeId,
        'enablePushNotification': enablePushNotification,
        'profileCompleted': profileCompleted,
        'imageUrl': imageUrl,
      };
}
