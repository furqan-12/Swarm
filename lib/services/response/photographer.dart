import 'package:swarm/services/response/photographerstat.dart';

class Photographer {
  String id;
  String? imagePath;
  double rating;
  double? distance;
  String? name;
  String? bio;
  double perHourRate;
  String experienceName;
  int experience;
  String experienceId;
  List<PhotographerPortfolio> portfolios;
  List<PhotographerReview> reviews;
  bool isVideographer;
  bool isPhotographer;

  Photographer({
    required this.id,
    this.imagePath,
    required this.rating,
    this.distance,
    this.name,
    this.bio,
    required this.perHourRate,
    required this.experienceName,
    required this.experience,
    required this.experienceId,
    required this.portfolios,
    required this.reviews,
    required this.isVideographer,
    required this.isPhotographer,
  });
}

class PhotographerPortfolio {
  String id;
  String? imagePath;
  bool? isVideo;
  String? thumbnailPath;

  PhotographerPortfolio({
    required this.id,
    this.imagePath,
    this.isVideo,
    this.thumbnailPath,
  });
}
