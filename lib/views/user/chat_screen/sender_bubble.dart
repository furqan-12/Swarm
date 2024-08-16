import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/views/order/shoot_type/shoot_type_screen.dart';
import 'package:swarm/views/photographer/upload_shoot_screen/upload_first_shoots.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/gratuity_photographer/collection_unlock_screen.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/gratuity_photographer/order_review_screen.dart';

import '../../../consts/consts.dart';

import '../../../services/response/photographer_order.dart';

Widget buildChatMessage(OrderChat message, PhotographerOrder order,
    VoidCallback? onPress, bool? isLastMsg, String? time) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    alignment:
        message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (time != null) ...[
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                time,
                style: TextStyle(
                    fontSize: 14,
                    color: universalGary,
                    fontFamily: milligramRegular),
              )),
          20.heightBox
        ],
        if (message.heading == "Your shoot is complete.") ...[
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                "${order.photographerName} has ended your shoot",
                style: TextStyle(
                    fontSize: 14,
                    color: universalGary,
                    fontFamily: milligramSemiBold),
              )),
          10.heightBox,
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: message.isUserMessage
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (onPress != null && !message.isUserMessage && message.fromSystem)
              CircleAvatar(
                radius: 23.0,
                backgroundImage: AssetImage("assets/icons/admin.png"),
              ),
            if (onPress != null &&
                !message.isUserMessage &&
                !message.fromSystem)
              CircleAvatar(
                radius: 23.0,
                backgroundImage:
                    CachedNetworkImageProvider(order.photographerProfileImage!),
              ),
            if (onPress == null &&
                !message.isUserMessage &&
                !message.fromSystem)
              CircleAvatar(
                radius: 23.0,
                backgroundImage:
                    CachedNetworkImageProvider(order.customerProfileImage!),
              ),
            SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, bottom: 12, top: 12),
              decoration: BoxDecoration(
                color: message.fromSystem
                    ? universalColorPrimaryDefault
                    : message.isUserMessage
                        ? universalLightGary
                        : universalColorPrimaryDefault,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.fromSystem && message.imagePath.isEmptyOrNull)
                      SizedBox(
                        width: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.heading!,
                              style: TextStyle(
                                  color: universalWhitePrimary,
                                  fontFamily: milligramBold,
                                  fontSize: 16),
                            ),
                            13.heightBox,
                            Text(message.message,
                                style: const TextStyle(
                                    color: universalWhitePrimary)),
                            if (message.navigationText.isNotEmptyAndNotNull &&
                                !(message.heading == "Your shoot is ready!" &&
                                    order.orderStatusNo == 3) &&
                                !(message.heading ==
                                        "Your shoot is complete." &&
                                    order.rating != null))
                              13.heightBox,
                            if (message.navigationText.isNotEmptyAndNotNull &&
                                !(message.heading == "Your shoot is ready!" &&
                                    order.orderStatusNo == 3) &&
                                !(message.heading ==
                                        "Your shoot is complete." &&
                                    order.rating != null))
                              Row(
                                children: [
                                  Text(
                                    message.navigationText!,
                                    style: const TextStyle(
                                        color: universalWhitePrimary,
                                        fontFamily: milligramBold,
                                        fontSize: 16),
                                  ).onTap(() {
                                    if (message.heading ==
                                        "Your shoot is tomorrow!") {
                                      onPress != null ? onPress() : '';
                                    } else if (message.heading ==
                                        "Your shoot is complete.") {
                                      Get.to(() =>
                                          OrderReviewScreen(orderId: order.id));
                                    } else if (message.heading ==
                                            "Your shoot is ready!" &&
                                        order.orderStatusNo != 3) {
                                      Get.to(() =>
                                          CollectionUnLockScreen(order: order));
                                    }
                                  }),
                                  5.widthBox,
                                  Icon(
                                    FontAwesomeIcons.arrowRightLong,
                                    color: universalWhitePrimary,
                                    size: 20,
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                    if (message.fromSystem == false &&
                        message.imagePath.isEmptyOrNull)
                      SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message.message,
                                style: TextStyle(
                                    color: message.isUserMessage == true
                                        ? universalBlackPrimary
                                        : universalWhitePrimary,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                  ]),
            ),
            SizedBox(width: 10),
            if (onPress != null && message.isUserMessage && !message.fromSystem)
              CircleAvatar(
                radius: 23.0,
                backgroundImage:
                    CachedNetworkImageProvider(order.customerProfileImage!),
              ),
            if (onPress == null && message.isUserMessage && !message.fromSystem)
              CircleAvatar(
                radius: 23.0,
                backgroundImage:
                    CachedNetworkImageProvider(order.photographerProfileImage!),
              ),
          ],
        ),
        if (message.heading == "Your shoot is ready!" &&
            order.orderStatusNo == 3) ...[
          10.heightBox,
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Payment has been successfully made",
                style: TextStyle(
                    fontSize: 14,
                    color: universalGary,
                    fontFamily: milligramSemiBold),
              )),
        ],
        if (message.heading == "Your shoot is booked!") ...[
          10.heightBox,
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                "${order.photographerName} has accepted your shoot request",
                style: TextStyle(
                    fontSize: 14,
                    color: universalGary,
                    fontFamily: milligramSemiBold),
              )),
        ],
        if (message.heading == "Your shoot is complete.") ...[
          10.heightBox,
          Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Book a new shoot",
                    style: TextStyle(
                        fontSize: 16,
                        color: universalColorPrimaryDefault,
                        fontFamily: milligramBold),
                  ),
                  5.widthBox,
                  Icon(
                    FontAwesomeIcons.arrowRightLong,
                    size: 20,
                    color: universalColorPrimaryDefault,
                  )
                ],
              )).onTap(() {
            Get.to(() => ShootTypeScreen(fromHome: true));
          }),
        ],
        if (isLastMsg == true &&
            onPress == null &&
            order.IsSharedToCustomer &&
            remainingHoursInt(order.orderDateTime) <= 0) ...[
          10.heightBox,
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                "The shoot has ended.",
                style: TextStyle(
                    fontSize: 14,
                    color: universalGary,
                    fontFamily: milligramSemiBold),
              )),
        ],
        if (isLastMsg == true &&
            onPress == null &&
            !order.IsSharedToCustomer &&
            remainingHoursInt(order.orderDateTime) <= 0) ...[
          10.heightBox,
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                "The shoot has ended.",
                style: TextStyle(
                    fontSize: 14,
                    color: universalGary,
                    fontFamily: milligramSemiBold),
              )),
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Please upload your customer’s shoot now.",
                style: TextStyle(
                    fontSize: 14,
                    color: universalGary,
                    fontFamily: milligramSemiBold),
              )),
          10.heightBox,
          Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Upload shoot",
                    style: TextStyle(
                        fontSize: 16,
                        color: universalColorPrimaryDefault,
                        fontFamily: milligramBold),
                  ),
                  5.widthBox,
                  Icon(
                    FontAwesomeIcons.arrowRightLong,
                    size: 20,
                    color: universalColorPrimaryDefault,
                  )
                ],
              )).onTap(() {
            Get.to(() => UploadFirstShoot(order: order));
          })
        ],
      ],
    ),
  );
}
