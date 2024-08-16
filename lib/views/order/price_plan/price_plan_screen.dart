import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/api.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/experience_service.dart';
import 'package:swarm/services/response/experience.dart';
import 'package:swarm/views/common/chip.dart';
import 'package:swarm/views/common/our_button.dart';
import 'package:swarm/views/order/find_photographers/find_photographers_screen.dart';

import '../../../storage/models/order.dart';
import '../../../storage/order_storage.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';

class PricePlanScreen extends StatefulWidget {
  final OrderModel order;

  PricePlanScreen({super.key, required this.order});

  @override
  State<PricePlanScreen> createState() => _PricePlanScreenState();
}

class _PricePlanScreenState extends State<PricePlanScreen> {
  List<Experience> items = [];
  Experience? selected = null;

  int shootLength = 0;
  String experience = "";

  void incrementCounter() {
    if (shootLength >= 12) return;
    setState(() {
      shootLength++;
    });
  }

  void decrementCounter() {
    if (shootLength <= 0) return;
    setState(() {
      shootLength--;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadPricePlans();
    });
  }

  Future<void> _loadPricePlans() async {
    final pricePlanRequest = ExperienceService();
    final pricePlans = await pricePlanRequest.getExperiences(
      context,
    );
    if (pricePlans == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }
    setState(() {
      items = pricePlans;
      // items.add(Experience("", "", 0));
    });
  }

  Future<void> selectPricePlan(String? experienceId) async {
    final order = await OrderStorage.getOrderModel;
    if (order != null) {
      order.experienceId = experienceId;
      order.shootLength = shootLength;
      order.shootLengthName = '${shootLength} hrs';
      order.rateMultiplier = shootLength;
      order.totalPicks = (order.rateMultiplier! * 10).floor();
      final jsonMap = order.toJson();
      await OrderStorage.setValue(jsonEncode(jsonMap));
      Get.to(() => FindPhotographersScreen(order: order));
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
                    chip(formatDate(widget.order.orderDateTime!)),
                    if (selected != null) chip(ExperienceName[selected!.id]!),
                    if (shootLength > 0) chip('${shootLength} hrs'),
                  ])),
            )),
        backgroundColor: universalWhitePrimary,
        body: Column(children: [
          15.heightBox,
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: "Plans & Pricing"
                    .text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make()),
          ),
          SizedBox(
            height: 440,
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                Experience item = items[index];

                return Padding(
                  padding:
                      const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        for (var exp in items) {
                          exp.isSelected = false;
                        }
                        item.isSelected = true;
                        selected = item;
                      });
                    },
                    child: Stack(children: [
                      Container(
                              decoration: BoxDecoration(
                                color: item.isSelected
                                    ? universalColorSecondaryDefault
                                    : universalBlackCell,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    item.name.isEmpty
                                        ? ""
                                        : item.name.toString(),
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontFamily: milligramBold,
                                      color: item.isSelected
                                          ? universalWhitePrimary
                                          : universalBlackPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: item.name.isEmpty
                                              ? ""
                                              : '\$${item.perHourRate}/hr',
                                          style: TextStyle(
                                            fontFamily: milligramBold,
                                            fontSize: 17,
                                            color: item.isSelected
                                                ? universalWhitePrimary
                                                : universalBlackPrimary,
                                          ),
                                        ),
                                        TextSpan(
                                          // Add the rest of your text here
                                          text: item.name.isEmpty
                                              ? ""
                                              : ' You get ${widget.order.shootTypeId != ShootingTypes["Video"] ? "9" : VideoExperiences[item.id]} ${item.id == Experiences["Starter"] ? "raw" : "edited"} ${widget.order.shootTypeId != ShootingTypes["Video"] ? "pics" : "video"}',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: milligramBold,
                                            color: item.isSelected
                                                ? universalWhitePrimary
                                                : universalGrayDarkCell,
                                            // Add styles for the remaining text
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                          .box
                          .width(context.screenWidth - 50)
                          .height(140)
                          .make(),
                      Positioned(
                          top: 15,
                          right: 15,
                          child: Column(
                            children: [
                              if (item.isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: universalWhitePrimary,
                                  size: 30,
                                ),
                            ],
                          ))
                    ]),
                  ),
                );
              },
            ),
          ),
          10.heightBox,
          Container(
            decoration: BoxDecoration(
              color: shootLength < 1
                  ? universalBlackCell
                  : universalColorSecondaryDefault,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${shootLength} hrs',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: milligramBold,
                        color: shootLength < 1
                            ? universalBlackPrimary
                            : universalWhitePrimary),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove,
                        color: universalWhitePrimary,
                        size: 30,
                      )
                          .box
                          .color(universalBlackPrimary)
                          .roundedFull
                          .make()
                          .onTap(() {
                        decrementCounter();
                      }),
                      SizedBox(width: 9),
                      Icon(
                        Icons.add,
                        color: universalWhitePrimary,
                        size: 30,
                      )
                          .box
                          .color(universalBlackPrimary)
                          .roundedFull
                          .make()
                          .onTap(() {
                        incrementCounter();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ).box.width(context.screenWidth - 50).height(60).make(),
          Expanded(child: Container()),
          0.heightBox,
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 30, right: 30),
            child: ourButton(
                    color: universalColorPrimaryDefault,
                    title: "Select and continue",
                    textColor: universalBlackPrimary,
                    isDisabled: !(selected != null && shootLength > 0),
                    onPress: selected != null && shootLength > 0
                        ? () async {
                            await selectPricePlan(selected?.id);
                          }
                        : null)
                .box
                .width(context.screenWidth - 50)
                .height(50)
                .rounded
                .make(),
          ),
        ]));
  }
}
