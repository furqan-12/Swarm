// shoots to upload

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/order_location_screen.dart';
import 'package:swarm/views/photographer/upload_shoot_screen/upload_first_shoots.dart';

import '../../../consts/consts.dart';

Widget ShootToUpload(List<PhotographerOrder> shootToUploadOrder) {
  return ListView.builder(
      itemCount: shootToUploadOrder.length, // Adjust the itemCount as needed
      itemBuilder: (context, index) {
        var item = shootToUploadOrder[index];
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
                          .color(universalBlackPrimary)
                          .fontFamily(milligramBold)
                          .size(18)
                          .make()
                          .marginOnly(bottom: 5),
                    ],
                  )),
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: (formatDateLong(item.orderDateTime))
                    .text
                    .color(universalBlackSecondary)
                    .fontFamily(milligramBold)
                    .size(16)
                    .make()
                    .marginOnly(bottom: 5)),
            Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.shortAddress,
                      style: TextStyle(
                        fontSize: 15,
                        color: universalBlackSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: universalBlackSecondary,
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
                        .color(universalBlackSecondary)
                        .fontFamily(milligramRegular)
                        .size(15)
                        .make()),
                " , ".text.make(),
                Align(
                    alignment: Alignment.centerLeft,
                    child: item.shootTypeName.text
                        .color(universalBlackSecondary)
                        .fontFamily(milligramRegular)
                        .size(15)
                        .make()),
                " , ".text.make(),
                Align(
                    alignment: Alignment.centerLeft,
                    child: item.shootSceneName.text
                        .color(universalBlackSecondary)
                        .fontFamily(milligramRegular)
                        .size(15)
                        .make()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => UploadFirstShoot(
                              order: item,
                            ));
                      },
                      child: Image.asset(
                        "assets/icons/cameraicon.png",
                        width: 60,
                        height: 60,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: item.customerProfileImage == null
                            ? null
                            : CachedNetworkImageProvider(
                                item.customerProfileImage!),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        )
            .onTap(() {
              Get.to(() => UploadFirstShoot(
                    order: item,
                  ));
            })
            .box
            .margin(const EdgeInsets.only(left: 10, right: 10, top: 10))
            .alignCenterLeft
            .border(color: universalBlackTertiary, width: 0.3)
            .roundedSM
            .shadowXs
            .padding(const EdgeInsets.only(left: 10, right: 10, top: 20))
            .color(universalWhitePrimary)
            .make();
      });
}
