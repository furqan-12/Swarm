class OrderReciptDetail {
  double advanceAmount;
  double picsAmount;
  double? additionalPicsAmount;
  double? serviceFee;
  double gratuityPer;
  double gratuityAmount;
  double taxAmount;

  OrderReciptDetail({
    required this.picsAmount,
    this.additionalPicsAmount,
    required this.advanceAmount,
    this.serviceFee,
    required this.gratuityPer,
    required this.gratuityAmount,
    required this.taxAmount,
  });

  // Factory constructor to parse from JSON
  factory OrderReciptDetail.fromJson(Map<String, dynamic> json) {
    return OrderReciptDetail(
      picsAmount: json['picsAmount'].toDouble(),
      additionalPicsAmount: json['additionalPicsAmount']?.toDouble(),
      advanceAmount: json['advanceAmount'].toDouble(),
      serviceFee: json['serviceFee']?.toDouble(),
      gratuityPer: json['gratuityPer'].toDouble(),
      gratuityAmount: json['gratuityAmount'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
    );
  }
}

class OrderRecipt {
  String id;
  String orderNo;
  String shootTypeName;
  String shootSceneName;
  String shortAddress;
  String dateFormated;
  double totalOrderAmount;
  double transferredAmount;
  double advanceTransferredAmount;
  OrderReciptDetail orderReciptDetail;

  OrderRecipt({
    required this.id,
    required this.orderNo,
    required this.shootTypeName,
    required this.shootSceneName,
    required this.shortAddress,
    required this.dateFormated,
    required this.orderReciptDetail,
    required this.totalOrderAmount,
    required this.advanceTransferredAmount,
    required this.transferredAmount,
  });

  // Additional constructor to parse from JSON
  factory OrderRecipt.fromJson(Map<String, dynamic> json) {
    return OrderRecipt(
      id: json['id'],
      orderNo: json['orderNo'],
      shootTypeName: json['shootTypeName'],
      shootSceneName: json['shootSceneName'],
      shortAddress: json['shortAddress'],
      orderReciptDetail: OrderReciptDetail.fromJson(json['orderPayment']),
      dateFormated: json['dateFormated'],
      totalOrderAmount: json['totalOrderAmount']?.toDouble(),
      advanceTransferredAmount: json['advanceTransferredAmount']?.toDouble(),
      transferredAmount: json['transferredAmount']?.toDouble(),
    );
  }
}
