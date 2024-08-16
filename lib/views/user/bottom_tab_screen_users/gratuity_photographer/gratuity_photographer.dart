import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/payment_service.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/date_time_helper.dart';

import 'package:swarm/views/user/bottom_tab_screen_users/collection_screen/collection_screen.dart';

import '../../../../services/order_service.dart';
import '../../../../services/response/order_payment.dart';
import '../../../../utils/toast_utils.dart';
import '../../../common/our_button.dart';

class GratuityPhotographerScreen extends StatefulWidget {
  final PhotographerOrder order;
  final int lookPhotoCount;
  final bool isUnlook;

  const GratuityPhotographerScreen(
      {super.key,
      required this.isUnlook,
      required this.order,
      required this.lookPhotoCount});

  @override
  State<GratuityPhotographerScreen> createState() =>
      _GratuityPhotographerScreenState();
}

class _GratuityPhotographerScreenState
    extends State<GratuityPhotographerScreen> {
  OrderPaymentDetail? payment;
  double selectedGratuity = 10;
  String clientSecret = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadOrderPayment();
    });
  }

  Future<void> _loadOrderPayment() async {
    final orderService = OrderService();
    OrderPaymentDetail? paymentDetail =
        await orderService.getOrderPaymentDetail(context, widget.order.id,
            widget.isUnlook, selectedGratuity, clientSecret);
    if (paymentDetail == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      setState(() {
        payment = paymentDetail;
        clientSecret = paymentDetail.clientSecret;
        selectedGratuity = paymentDetail.gratuityPer;
      });
    }
  }

  Future<void> _orderPayment() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var key = await PaymentService().getPublishableKey();
      if (key != null) {
        Stripe.publishableKey = key;
        Stripe.merchantIdentifier = 'Swarm App';
        await Stripe.instance.applySettings();
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Main params
          merchantDisplayName: 'SWARM',
          paymentIntentClientSecret: payment?.clientSecret,
          // Extra options
          style: ThemeMode.system,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = false;
    });

    try {
      await Stripe.instance.presentPaymentSheet();
      ToastHelper.showSuccessToast(
          context,
           CircleAvatar(
            backgroundColor: Colors.white,
                radius: 40,
               backgroundImage: AssetImage(
                          "assets/icons/universal-done-small.png",
                        ),
              ),
          "Thanks!",
          "You can now access your portfolio. Enjoy!",
          "View my shoot", () {
        Get.to(CollectionScreen());
      });
      setState(() {
        payment?.clientSecret = '';
      });
      // await Future.delayed(Duration(seconds: 4));
      // Get.offAll(() => OrderReviewScreen(order: widget.order));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastHelper.showSuccessToast(
          context,
          Icon(
            FontAwesomeIcons.solidCircleXmark,
            color: specialError,
            size: 60,
          ),
          "Payment failed.",
          "Pick another payment method and try again.",
          "Update payment method", () {
        Get.back();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          child: Image.asset("assets/icons/arrow.png").onTap(() {
            Navigator.pop(context);
          }),
        ),
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Align(
                alignment: Alignment.centerLeft,
                child: "Final bill"
                    .text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make(),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 7),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: (formatDateLong(widget.order.orderDateTime))
                          .text
                          .color(universalBlackPrimary)
                          .size(18)
                          .make()),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: widget.order.shortAddress.text
                          .color(universalBlackPrimary)
                          .size(18)
                          .make()),
                ),
                10.heightBox,
                Row(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: widget.order.shootLengthName.text
                            .color(universalBlackSecondary)
                            .size(15)
                            .make()),
                    " , ".text.make(),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: widget.order.shootTypeName.text
                            .color(universalBlackSecondary)
                            .size(15)
                            .make()),
                    " , ".text.make(),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: widget.order.shootSceneName.text
                            .color(universalBlackSecondary)
                            .size(15)
                            .make()),
                  ],
                ),
                10.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.order.photographerName!.text
                            .size(15)
                            .fontFamily(semibold)
                            .make(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: VxRating(
                              isSelectable: false,
                              value: widget.order.photographerRating,
                              onRatingUpdate: (value) {},
                              normalColor: universalBlackTertiary,
                              selectionColor: universalColorPrimaryDefault,
                              size: 18,
                              maxRating: 5,
                              count: 5),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: CachedNetworkImageProvider(
                              widget.order.photographerProfileImage!),
                        ),
                      ],
                    )
                  ],
                )
              ],
            )
                .box
                .margin(const EdgeInsets.only(left: 20, right: 20, top: 10))
                .alignCenterLeft
                .roundedSM
                .padding(const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 20))
                .color(universalBlackCell)
                .make(),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 5),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: "Add gratuity for ${widget.order.photographerName}"
                      .text
                      .color(universalBlackPrimary)
                      .fontFamily(milligramBold)
                      .size(15)
                      .make()),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        setState(() {
                          selectedGratuity = 10 + index * 5;
                        });
                        await _loadOrderPayment();
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            "${10 + index * 5}%"
                                .text
                                .color(selectedGratuity == 10 + index * 5
                                    ? universalWhitePrimary
                                    : universalTransblackPrimary)
                                .size(18)
                                .make(),
                          ],
                        )
                            .box
                            .roundedFull
                            .color(selectedGratuity == 10 + index * 5
                                ? universalColorSecondaryDefault
                                : universalBlackCell)
                            .width(55)
                            .height(55)
                            .margin(const EdgeInsets.only(right: 13))
                            .padding(const EdgeInsets.all(9.0))
                            .make(),
                      ),
                    );
                  }),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: "Shoot details"
                          .text
                          .fontFamily(milligramBold)
                          .color(universalBlackSecondary)
                          .size(15)
                          .make()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "${widget.order.shootLengthName} ${widget.order.shootTypeName} Shoot"
                                .text
                                .fontFamily(milligramBold)
                                .color(universalBlackPrimary)
                                .size(15)
                                .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${payment == null ? 0 : payment!.picsAmount.numCurrency}"
                                .text
                                .fontFamily(milligramRegular)
                                .color(universalBlackPrimary)
                                .size(15)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 5)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "50% Deposit Paid"
                            .text
                            .fontFamily(milligramBold)
                            .color(universalBlackPrimary)
                            .size(15)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "-\$${payment == null ? 0 : payment!.advanceAmount.numCurrency}"
                                .text
                                .fontFamily(milligramRegular)
                                .color(universalBlackPrimary)
                                .size(15)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 5)).make(),
                if (widget.isUnlook)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: "Unlocked Content"
                              .text
                              .fontFamily(milligramBold)
                              .color(universalBlackPrimary)
                              .size(15)
                              .make()),
                      Align(
                          alignment: Alignment.centerLeft,
                          child:
                              "\$${payment == null ? 0 : payment!.additionalPicsAmount!.numCurrency}"
                                  .text
                                  .color(universalBlackPrimary)
                                  .fontFamily(milligramRegular)
                                  .size(15)
                                  .make()),
                    ],
                  ).box.margin(const EdgeInsets.only(bottom: 12)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Service Fee"
                            .text
                            .fontFamily(milligramBold)
                            .color(universalBlackPrimary)
                            .size(15)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${payment == null ? 0 : payment!.serviceFee!.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(milligramRegular)
                                .size(15)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 5)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Gratuity"
                            .text
                            .fontFamily(milligramBold)
                            .color(universalBlackPrimary)
                            .size(15)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${payment == null ? 0 : payment!.gratuityAmount.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(milligramRegular)
                                .size(15)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 5)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Tax"
                            .text
                            .fontFamily(milligramBold)
                            .color(universalBlackPrimary)
                            .size(15)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${payment == null ? 0 : payment!.taxAmount.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(milligramRegular)
                                .size(15)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 25)).make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Total Due Now"
                            .text
                            .color(universalBlackPrimary)
                            .fontFamily(milligramBold)
                            .size(17)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${payment == null ? 0 : payment!.totalAmount.numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(milligramBold)
                                .size(15)
                                .make()),
                  ],
                ).box.margin(const EdgeInsets.only(bottom: 40)).make(),
              ],
            )
                .box
                .margin(const EdgeInsets.only(left: 30, right: 30))
                .alignCenterLeft
                .make(),
            SizedBox(
                    height: 30,
                    width: 120,
                    child: Image.asset(
                      "assets/icons/stripeText.png",
                      scale: 1.0,
                    ))
                .box
                .border(color: universalColorPrimaryDefault, width: 1)
                .roundedSM
                .padding(EdgeInsets.only(left: 10, right: 10))
                .make(),
            15.heightBox,
            Divider(),
            ourButton(
                color: universalColorPrimaryDefault,
                title:
                    "Pay \$${payment == null ? 0 : payment!.totalAmount.numCurrency}",
                textColor: universalBlackPrimary,
                onPress: () async {
                  _isLoading ? null : await _orderPayment();
                }).box.width(context.screenWidth - 180).height(50).rounded.make(),
            Divider(),
            10.heightBox
          ],
        ),
      ),
    );
  }
}
