import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/api.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/payment_service.dart';
import 'package:swarm/utils/loader.dart';
import 'package:swarm/views/common/chip.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';

import 'package:swarm/views/user/chat_screen/user_chat_screen.dart';

import '../../../services/order_service.dart';
import '../../../services/response/order_advance_payment copy.dart';
import '../../../services/response/photographer.dart';
import '../../../storage/models/order.dart';
import '../../../storage/order_storage.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key, required this.photographer});
  final Photographer photographer;

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  OrderModel? order = OrderModel(shootTypeId: "", shootTypeName: "");
  OrderAdvancePayment? payment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  @override
  void dispose(){
    LoaderHelper.hide();
    super.dispose();
  }

  Future<void> _loadData() async {
    OrderModel? orderDetail = await OrderStorage.getOrderModel;
    if (orderDetail != null) {
      setState(() {
        order = orderDetail;
      });
      orderDetail.photographerUserId = widget.photographer.id;
      final orderRequest = OrderService();
      final paymentDetail =
          await orderRequest.getOrderAdvancePaymentDetail(context, orderDetail);

      if (paymentDetail == null) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }

      setState(() {
        payment = paymentDetail;
      });
    }
  }

  Future<void> _advancePayment() async {
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

      final orderRequest = OrderService();
      String? orderId =
          await orderRequest.getOrderId(context, payment!.clientSecret);
      if (orderId == null) {
        LoaderHelper.show(context);
        await Future.delayed(Duration(seconds: 1));
        orderId = await orderRequest.getOrderId(context, payment!.clientSecret);
        if (orderId == null) {
          ToastHelper.showSuccessToast(
              context,
              CircleAvatar(
                radius: 35,
                backgroundImage:
                    CachedNetworkImageProvider(widget.photographer.imagePath!),
              ),
              "You’ve booked ${widget.photographer.name}",
              "You can chat with ${widget.photographer.name} about the details of your shoot.",
              "Chat now", () {
            Get.offAll(HomeUserScreen(index: 3));
          });
          return;
        }
      }
      setState(() {
        payment?.clientSecret = '';
      });
      Get.offAll(() => UserChatScreen(
            orderId: orderId!,
          ));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastHelper.showErrorToast(context, "Cancelled");
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
          toolbarHeight: 100,
          title: Align(
            alignment: Alignment.topLeft,
            child: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight + 20),
                child: Wrap(spacing: 4.0, children: [
                  chip(order!.shootTypeName),
                  chip(order!.shootSceneName!),
                  chip(order!.shortAddress!.length > 12
                      ? order!.shortAddress!.substring(0, 12) + "..."
                      : order!.shortAddress!),
                  chip(formatDate(order!.orderDateTime!)),
                  chip(ExperienceName[order!.experienceId!]!),
                  chip(order!.shootLengthName!),
                ])),
          )),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            15.heightBox,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "Deposit".text.fontFamily(milligramBold).black.size(40).make(),
                10.heightBox,
                "To book this shoot, please pay your 50% deposit"
                    .text
                    .fontFamily(milligramRegular)
                    .color(universalBlackSecondary)
                    .size(15)
                    .make(),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 7),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: (order == null
                              ? formatDateLong(DateTime.now())
                              : formatDateLong(order!.orderDateTime!))
                          .text
                          .color(universalBlackPrimary)
                          .size(18)
                          .make()),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: order?.shortAddress!.text
                          .color(universalBlackPrimary)
                          .size(18)
                          .make()),
                ),
                10.heightBox,
                Row(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: order?.shootLengthName!.text
                            .color(universalBlackSecondary)
                            .size(15)
                            .make()),
                    " , ".text.make(),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: order?.shootTypeName.text
                            .color(universalBlackSecondary)
                            .size(15)
                            .make()),
                    " , ".text.make(),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: order?.shootSceneName!.text
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
                        widget.photographer.name!.text
                            .size(15)
                            .fontFamily(semibold)
                            .make(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: VxRating(
                              isSelectable: false,
                              value: widget.photographer.rating,
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
                              widget.photographer.imagePath!),
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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: "Price Details"
                          .text
                          .fontFamily(milligramBold)
                          .color(universalBlackSecondary)
                          .size(15)
                          .make()),
                ),
                10.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "${order?.shootLengthName} ${order?.shootTypeName} Shoot"
                                .text
                                .fontFamily(milligramBold)
                                .black
                                .size(15)
                                .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${payment == null ? "" : payment?.orderAmount.numCurrency}"
                                .text
                                .fontFamily(milligramBold)
                                .color(universalBlackPrimary)
                                .size(15)
                                .make()),
                  ],
                ).box.make(),
                10.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "50% Deposit"
                            .text
                            .fontFamily(milligramBold)
                            .color(universalBlackPrimary)
                            .size(15)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${payment == null ? "" : payment?.advanceAmount.numCurrency}"
                                .text
                                .fontFamily(milligramBold)
                                .color(universalBlackPrimary)
                                .size(15)
                                .make()),
                  ],
                ),
                30.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Total Due Now"
                            .text
                            .color(universalBlackPrimary)
                            .fontFamily(milligramBold)
                            .size(15)
                            .make()),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            "\$${payment == null ? "" : (payment!.orderAmount - payment!.advanceAmount).numCurrency}"
                                .text
                                .color(universalBlackPrimary)
                                .fontFamily(milligramBold)
                                .size(15)
                                .make()),
                  ],
                ),
              ],
            )
                .box
                .margin(const EdgeInsets.only(
                    left: 25, right: 25, top: 35, bottom: 35))
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
            25.heightBox,
            Divider(),
            5.heightBox,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: universalColorPrimaryDefault,
                  elevation: 0,
                  padding: EdgeInsets.only(left: 40, right: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                // Handle button press when a city is selected
                _isLoading ? null : await _advancePayment();
              },
              child:
                  "Pay \$${payment == null ? "" : payment?.advanceAmount.numCurrency}"
                      .text
                      .color(universalBlackPrimary)
                      .fontFamily(milligramBold)
                      .size(20)
                      .make(),
            )
                .box
                .height(50)
                .padding(EdgeInsets.only(left: 20, right: 20))
                .roundedSM
                .make(),
            5.heightBox,
            Divider()
          ],
        ),
      ),
    );
  }
}
