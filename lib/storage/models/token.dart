class TokenModel {
  final String token;
  final String refreshToken;
  final bool profilesCompleted;
  final String profileType;
  final DateTime refreshTokenExpiryTime;

  TokenModel(this.token, this.refreshToken, this.profilesCompleted,
      this.profileType, this.refreshTokenExpiryTime);

  TokenModel.fromJson(Map<String, dynamic> json)
      : token = json['token'],
        refreshToken = json['refreshToken'],
        profilesCompleted = json['profilesCompleted'],
        profileType = json['profileType'],
        refreshTokenExpiryTime = DateTime.parse(json['refreshTokenExpiryTime']);

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'profilesCompleted': profilesCompleted,
        'profileType': profileType,
        'refreshTokenExpiryTime': refreshTokenExpiryTime,
      };
}
