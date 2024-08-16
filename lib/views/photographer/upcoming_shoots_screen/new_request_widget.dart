import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:swarm/services/order_service.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/new_requests_result_widget.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/order_location_screen.dart';

import '../../../consts/consts.dart';

// StatefulWidget
class NewRequestsWidget extends StatefulWidget {
  final List<PhotographerOrder> newBookingOrders;

  const NewRequestsWidget({Key? key, required this.newBookingOrders})
      : super(key: key);

  @override
  _NewRequestsWidgetState createState() => _NewRequestsWidgetState();
}

// State class
class _NewRequestsWidgetState extends State<NewRequestsWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.newBookingOrders
            .where((e) => e.newRequestStatus != -1)
            .length,
        itemBuilder: (context, index) {
          var item = widget.newBookingOrders[index];
          return item.newRequestStatus == 0
              ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: ("${item.customerName}'s shoot")
                              .text
                              .color(universalBlackPrimary)
                              .fontFamily(milligramBold)
                              .size(18)
                              .make()
                              .marginOnly(bottom: 5)),
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: universalColorPrimaryDefault,
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30, top: 10, bottom: 10),
                                  shadowColor: null,
                                  shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.circular(3)),
                                  elevation: 0),
                              onPressed: () async {
                                OrderService orderService = OrderService();
                                var accepted = await orderService.acceptOrder(
                                    context, item.id);
                                if (accepted == true) {
                                  setState(() {
                                    item.newRequestStatus = 1;
                                  });
                                  Future.delayed(Duration(seconds: 120), () {
                                    setState(() {
                                      item.newRequestStatus = -1;
                                    });
                                  });
                                }
                              },
                              child: const Text(
                                'Accept',
                                style: TextStyle(
                                    color: universalBlackPrimary,
                                    fontFamily: milligramBold,
                                    fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: universalWhitePrimary,
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30, top: 10, bottom: 10),
                                  shadowColor: null,
                                  shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.circular(3)),
                                  side: BorderSide(
                                      color: universalBlackTertiary,
                                      width: 0.3),
                                  elevation: 0),
                              onPressed: () async {
                                OrderService orderService = OrderService();

                                var declined = await orderService.declineOrder(
                                    context, item.id);
                                if (declined == true) {
                                  setState(() {
                                    item.newRequestStatus = 2;
                                  });
                                  Future.delayed(Duration(seconds: 5), () {
                                    setState(() {
                                      item.newRequestStatus = -1;
                                    });
                                  });
                                }
                                // Handle Decline button press
                                // You can add your logic here
                              },
                              child: const Text('Decline',
                                  style: TextStyle(
                                      color: universalBlackPrimary,
                                      fontFamily: milligramRegular,
                                      fontSize: 16)),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: item.customerProfileImage == null
                                  ? null
                                  : CachedNetworkImageProvider(
                                      item.customerProfileImage!),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                )
                  .box
                  .margin(const EdgeInsets.only(left: 10, right: 10, top: 10))
                  .alignCenterLeft
                  .roundedSM
                  .padding(const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20))
                  .color(universalBlackCell)
                  .make()
              : item.newRequestStatus == 1
                  ? NewRequestsResult(
                      icon: Icon(Icons.check,
                              color: universalWhitePrimary, size: 40)
                          .box
                          .roundedFull
                          .padding(EdgeInsets.all(7))
                          .border(color: universalWhitePrimary, width: 0.5)
                          .color(universalColorPrimaryDefault)
                          .make(),
                      title: "All set!",
                      textColor: universalWhitePrimary,
                      subtitle: "This shoot has been added\nto your schedule.",
                      color: universalColorSecondaryDefault)
                  : NewRequestsResult(
                      icon: Icon(Icons.close,
                              color: universalWhitePrimary, size: 40)
                          .box
                          .roundedFull
                          .padding(EdgeInsets.all(3))
                          .border(color: universalWhitePrimary, width: 0.5)
                          .color(Colors.red)
                          .make(),
                      title: "Thanks for letting us know.",
                      textColor: universalBlackPrimary,
                      subtitle:
                          "We will let the customer know\nyou are not available.",
                      color: universalBlackCell);
        });
  }
}
