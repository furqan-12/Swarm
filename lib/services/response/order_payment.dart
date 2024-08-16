class OrderPaymentDetail {
  double picsAmount;
  double? additionalPerPicPrice;
  double? additionalPics;
  double? additionalPicsAmount;
  double advanceAmount;
  double? serviceFee;
  double gratuityPer;
  double gratuityAmount;
  double taxAmount;
  double totalAmount;
  String clientSecret;

  OrderPaymentDetail({
    required this.picsAmount,
    this.additionalPerPicPrice,
    this.additionalPics,
    this.additionalPicsAmount,
    required this.advanceAmount,
    this.serviceFee,
    required this.gratuityPer,
    required this.gratuityAmount,
    required this.taxAmount,
    required this.totalAmount,
    this.clientSecret = '',
  });

  // Factory constructor to parse from JSON
  factory OrderPaymentDetail.fromJson(Map<String, dynamic> json) {
    return OrderPaymentDetail(
      picsAmount: json['picsAmount'].toDouble(),
      additionalPerPicPrice: json['additionalPerPicPrice']?.toDouble(),
      additionalPics: json['additionalPics']?.toDouble(),
      additionalPicsAmount: json['additionalPicsAmount']?.toDouble(),
      advanceAmount: json['advanceAmount'].toDouble(),
      serviceFee: json['serviceFee']?.toDouble(),
      gratuityPer: json['gratuityPer'].toDouble(),
      gratuityAmount: json['gratuityAmount'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      clientSecret: json['clientSecret'] ?? '',
    );
  }
}
