import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/services/response/user.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/views/common/custom_multilines_text_field.dart';

import 'package:swarm/views/order/shoot_type/shoot_type_screen.dart';

import '../../../../services/order_service.dart';
import '../../../../utils/toast_utils.dart';
import '../../../common/our_button.dart';

class OrderReviewScreen extends StatefulWidget {
  final String orderId;
  const OrderReviewScreen({super.key, required this.orderId});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  UserProfile? user = null;
  PhotographerOrder? order = null;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadOrderChats();
    });
  }

  Future<void> _loadOrderChats() async {
    user = (await UserProfileStorage.getUserProfileModel)!;
    final orderService = OrderService();
    final _order =
        await orderService.getOrder(context, widget.orderId, user!.id);
    if (_order == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      setState(() {
        order = _order;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      backgroundColor: universalWhitePrimary,
      body: order == null
          ? null
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: "Provide a review"
                          .text
                          .fontFamily(milligramBold)
                          .black
                          .size(40)
                          .make()),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 7),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: (formatDateLong(order!.orderDateTime))
                              .text
                              .color(universalBlackPrimary)
                              .size(18)
                              .make()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: order!.shortAddress.text
                              .color(universalBlackPrimary)
                              .size(18)
                              .make()),
                    ),
                    10.heightBox,
                    Row(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: order!.shootLengthName.text
                                .color(universalBlackSecondary)
                                .size(15)
                                .make()),
                        " , ".text.make(),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: order!.shootTypeName.text
                                .color(universalBlackSecondary)
                                .size(15)
                                .make()),
                        " , ".text.make(),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: order!.shootSceneName.text
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
                            order!.photographerName!.text
                                .size(15)
                                .fontFamily(semibold)
                                .make(),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: VxRating(
                                  isSelectable: false,
                                  value: order!.photographerRating,
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
                                  order!.photographerProfileImage!),
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
                15.heightBox,
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: "How did ${order!.photographerName} do?"
                          .text
                          .color(universalBlackPrimary)
                          .size(15)
                          .fontFamily(milligramSemiBold)
                          .make()),
                ),
                15.heightBox,
                VxRating(
                  isSelectable: true,
                  value: _rating,
                  onRatingUpdate: (value) {
                    double doubleValue = double.tryParse(value) ??
                        0.0; // Parse the string as a double
                    int intValue = doubleValue
                        .ceil()
                        .toInt(); // Round up and convert to int
                    setState(() {
                      _rating = intValue.toDouble();
                    });
                  },
                  normalColor: universalGary,
                  selectionColor: universalColorPrimaryDefault,
                  size: 60,
                  maxRating: 5,
                  count: 5,
                  stepInt: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: customMultilineTextFiled(
                      hint: "Write a review",
                      controller: _reviewController,
                      maxLength: 300),
                ),
                Expanded(child: Container()),
                0.heightBox,
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30, bottom: 30, right: 30),
                  child: ourButton(
                          color: universalColorPrimaryDefault,
                          title: "Submit review",
                          textColor: universalBlackPrimary,
                          onPress: () async {
                            await _rateOrder();
                          })
                      .box
                      .width(context.screenWidth - 50)
                      .height(50)
                      .rounded
                      .make(),
                ),
              ],
            ),
    );
  }

  Future<void> _rateOrder() async {
    try {
      final orderService = OrderService();
      final isShared = await orderService.rateOrder(
          context, order!.id, _rating, _reviewController.text);
      if (isShared == null) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      } else {
        ToastHelper.showSuccessToast(
            context,
            CircleAvatar(
            backgroundColor: Colors.white,
                radius: 40,
               backgroundImage: AssetImage(
                          "assets/icons/universal-done-small.png",
                        ),
              ),
            "Thanks for your review!",
            "We’ll add it to ${order!.photographerName}'s profile.",
            "Book a new shoot", () {
          Get.offAll(ShootTypeScreen(
            fromHome: true,
          ));
        });
      }
    } finally {}
  }
}
