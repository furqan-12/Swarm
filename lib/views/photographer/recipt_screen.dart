import 'package:cached_network_image/cached_network_image.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/order_recipt.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/services/response/user.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/utils/date_time_helper.dart';

import '../../../../services/order_service.dart';
import '../../../../utils/toast_utils.dart';

class OrderReciptScreen extends StatefulWidget {
  final String orderId;

  const OrderReciptScreen({super.key, required this.orderId});

  @override
  State<OrderReciptScreen> createState() => _OrderReciptScreenState();
}

class _OrderReciptScreenState extends State<OrderReciptScreen> {
  OrderRecipt? recipt;
  UserProfile? user = null;
  PhotographerOrder? order = null;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadOrderPayment();
    });
  }

  Future<void> _loadOrderPayment() async {
    user = (await UserProfileStorage.getUserProfileModel)!;
    final orderService = OrderService();
    final _order =
        await orderService.getOrder(context, widget.orderId, user!.id);
    OrderRecipt? orderRecipt =
        await orderService.getOrderRecipt(context, widget.orderId);
    if (orderRecipt == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      setState(() {
        recipt = orderRecipt;
        order = _order;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: universalBlackPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
        title: "Recipt".text.color(universalBlackPrimary).size(17).make(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Center(
              child: Stack(children: [
                CachedNetworkImage(
                  fadeInDuration: const Duration(seconds: 1),
                  imageUrl: order != null ? order!.customerProfileImage! : "",
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: const CircularProgressIndicator(
                      color: universalColorPrimaryDefault,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: specialError,
                  ),
                ),
                if (order != null)
                  Positioned(
                      bottom: 30,
                      left: 10,
                      child:
                          "${order!.shootTypeName},\n${formatDateString(order!.orderDateTime)}"
                              .text
                              .white
                              .fontFamily(bold)
                              .size(17)
                              .make()),
                if (order != null)
                  Positioned(
                      bottom: 10,
                      left: 10,
                      child: "${order!.orderPhotos.length} photos"
                          .text
                          .white
                          .fontFamily(bold)
                          .size(13)
                          .make())
              ]).box.rounded.make(),
            ),
            30.heightBox,
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: "Add-ons"
                          .text
                          .color(universalBlackPrimary)
                          .size(17)
                          .fontFamily(bold)
                          .make()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Unlocked pics................."
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${recipt == null ? 0 : recipt!.orderReciptDetail.picsAmount.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(17)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 12)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (recipt != null &&
                        recipt!.orderReciptDetail.additionalPicsAmount! > 0)
                      SizedBox(
                        width: context.screenWidth - 120,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: "Additional pics amount"
                                .text
                                .color(universalBlackPrimary)
                                .size(17)
                                .make()),
                      ),
                    if (recipt != null &&
                        recipt!.orderReciptDetail.additionalPicsAmount! > 0)
                      Align(
                          alignment: Alignment.centerLeft,
                          child:
                              "\$${recipt == null ? 0 : recipt!.orderReciptDetail.additionalPicsAmount!.numCurrency}"
                                  .text
                                  .color(universalBlackPrimary)
                                  .fontFamily(bold)
                                  .size(17)
                                  .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 25)).make(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: "Additional Fees"
                          .text
                          .color(universalBlackPrimary)
                          .size(17)
                          .fontFamily(bold)
                          .make()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Service Fees................."
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${recipt == null ? 0 : recipt!.orderReciptDetail.serviceFee!.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(17)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 12)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Tip............................"
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${recipt == null ? 0 : recipt!.orderReciptDetail.gratuityAmount.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(17)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 12)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Tax.............................."
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${recipt == null ? 0 : recipt!.orderReciptDetail.taxAmount.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(17)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 25)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Total Amount"
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${recipt == null ? 0 : recipt!.totalOrderAmount.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(25)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 40)).make(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: "Your Payment"
                          .text
                          .color(universalBlackPrimary)
                          .size(17)
                          .fontFamily(bold)
                          .make()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Order Amount............................"
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${recipt == null ? 0 : recipt!.totalOrderAmount.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(17)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 12)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Service Fees................."
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "(\$${recipt == null ? 0 : recipt!.orderReciptDetail.serviceFee!.numCurrency})"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(17)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 12)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Tax.............................."
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "(\$${recipt == null ? 0 : recipt!.orderReciptDetail.taxAmount.numCurrency})"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(17)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 25)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Total Amount"
                            .text
                            .color(universalBlackPrimary)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${recipt == null ? 0 : (recipt!.totalOrderAmount - (recipt!.orderReciptDetail.serviceFee! + recipt!.orderReciptDetail.taxAmount)).numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(bold)
                                .size(25)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 40)).make(),
              ],
            )
                .box
                .margin(const EdgeInsets.only(left: 30, right: 30))
                .alignCenterLeft
                .make(),
          ],
        ),
      ),
    );
  }
}
