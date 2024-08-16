import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/views/common/chip.dart';
import 'package:swarm/views/order/price_plan/price_plan_screen.dart';

import '../../../storage/models/order.dart';
import '../../../storage/order_storage.dart';
import '../../common/our_button.dart';

class DateTimeScreen extends StatefulWidget {
  final OrderModel order;
  DateTimeScreen({super.key, required this.order});

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  DateTime? selectedDate;
  DateTime _initialDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Show DatePicker immediately when the screen loads
    _initialDateTime = _initialDateTime.add(Duration(hours: 1));
    _initialDateTime = DateTime(
      _initialDateTime.year,
      _initialDateTime.month,
      _initialDateTime.day,
      _initialDateTime.hour,
      0, // Set minutes to 00
      0, // Optionally set seconds to 00
    );
  }

  Future<void> selectedOrderDate() async {
    final order = await OrderStorage.getOrderModel;
    if (order != null) {
      order.orderDateTime = _dateTime;
      final jsonMap = order.toJson();
      await OrderStorage.setValue(jsonEncode(jsonMap));
      Get.to(() => PricePlanScreen(order: order));
    }
  }

  DateTime _dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                    chip(widget.order.shootTypeName),
                    chip(widget.order.shootSceneName!),
                    chip(widget.order.shortAddress!.length > 12
                        ? widget.order.shortAddress!.substring(0, 12) + "..."
                        : widget.order.shortAddress!),
                  ])),
            )),
        backgroundColor: universalWhitePrimary,
        body: Column(children: [
          15.heightBox,
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Align(
                alignment: Alignment.centerLeft,
                child: "Date & Time"
                    .text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make()),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: SizedBox(
                    height: 200,
                    child: CupertinoDatePicker(
                      minimumDate: DateTime.now(),
                      maximumDate: DateTime.now().add(Duration(days: 60)),
                      initialDateTime: _initialDateTime,
                      minuteInterval: 30,
                      onDateTimeChanged: (newDateTime) {
                        // if (newDateTime.year != _dateTime.year ||
                        //     newDateTime.month != _dateTime.month ||
                        //     newDateTime.day != _dateTime.day ||
                        //     newDateTime.hour != _dateTime.hour) {
                        //   // Adjust the newDateTime to set the minute and second to 00
                        //   newDateTime = DateTime(
                        //       newDateTime.year,
                        //       newDateTime.month,
                        //       newDateTime.day,
                        //       newDateTime.hour,
                        //       0,
                        //       0);
                        // }
                        setState(() {
                          _dateTime = newDateTime;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 30, right: 30),
            child: ourButton(
                    color: universalColorPrimaryDefault,
                    title: "Select and continue",
                    textColor: universalBlackPrimary,
                    onPress: () async {
                      await selectedOrderDate();
                    })
                .box
                .width(context.screenWidth - 50)
                .height(50)
                .rounded
                .make(),
          ),
        ]));
  }
}
