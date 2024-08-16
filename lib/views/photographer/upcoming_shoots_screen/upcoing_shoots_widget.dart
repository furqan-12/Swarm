import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/views/photographer/chat_screen/photograpers_chat_screen.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/order_location_screen.dart';

import '../../../consts/consts.dart';

Widget UpcomingShoots(List<PhotographerOrder> upcomingOrders) {
  void _openChat(PhotographerOrder item) {
    Get.to(() => PhotographersChatScreen(orderId: item.id));
  }

  return ListView.builder(
      itemCount: upcomingOrders.length, // Adjust the itemCount as needed
      itemBuilder: (context, index) {
        var item = upcomingOrders[index];
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ("${item.customerName}'s shoot")
                          .text
                          .color(universalWhitePrimary)
                          .fontFamily(milligramBold)
                          .size(18)
                          .make(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: universalWhitePrimary,
                          size: 15,
                        ),
                      )
                    ],
                  )),
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: (formatDateLong(item.orderDateTime))
                    .text
                    .color(universalWhitePrimary)
                    .fontFamily(milligramRegular)
                    .size(16)
                    .make()
                    .marginOnly(bottom: 5)),
            Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.shortAddress,
                      style: TextStyle(
                        fontSize: 15,
                        color: universalWhitePrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: universalWhitePrimary,
                      ),
                    ).marginOnly(bottom: 5))
                .onTap(() {
              Get.to(() => OrderLocationScreen(order: item));
            }),
            Row(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: item.shootLengthName.text
                        .color(universalWhitePrimary)
                        .fontFamily(milligramRegular)
                        .size(15)
                        .make()),
                " , ".text.color(universalWhitePrimary).make(),
                Align(
                    alignment: Alignment.centerLeft,
                    child: item.shootTypeName.text
                        .color(universalWhitePrimary)
                        .fontFamily(milligramRegular)
                        .size(15)
                        .make()),
                " , ".text.color(universalWhitePrimary).make(),
                Align(
                    alignment: Alignment.centerLeft,
                    child: item.shootSceneName.text
                        .color(universalWhitePrimary)
                        .fontFamily(milligramRegular)
                        .size(15)
                        .make()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: item.customerProfileImage == null
                      ? null
                      : CachedNetworkImageProvider(item.customerProfileImage!),
                ),
              ],
            )
          ],
        )
            .onTap(() {
              _openChat(item);
            })
            .box
            .margin(const EdgeInsets.only(left: 10, right: 10, top: 10))
            .alignCenterLeft
            .roundedSM
            .shadowXs
            .padding(
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20))
            .color(universalColorSecondaryDefault)
            .make();
      });
}
