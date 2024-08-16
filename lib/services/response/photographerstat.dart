class PhotographerStat {
  String id;
  String? imagePath;
  double rating;
  String? name;
  double perHourRate;
  String experienceName;
  int experience;
  int totalOrder;
  String experienceId;
  DateTime profileLive;
  double YealyEarned;
  double MonthlyEarned;
  List<PhotographerReview> reviews;

  PhotographerStat({
    required this.id,
    this.imagePath,
    required this.rating,
    this.name,
    required this.perHourRate,
    required this.experienceName,
    required this.experience,
    required this.totalOrder,
    required this.experienceId,
    required this.profileLive,
    required this.YealyEarned,
    required this.MonthlyEarned,
    required this.reviews,
  });
}

class PhotographerReview {
  String id;
  String? imagePath;
  int rating;
  String? review;
  DateTime? reviewDate;

  PhotographerReview({
    required this.id,
    this.imagePath,
    required this.rating,
    this.review,
    this.reviewDate,
  });
}
