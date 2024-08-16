import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/order_payment.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/views/common/custom_slider.dart';
import 'package:swarm/views/common/our_button.dart';

import '../../../../services/order_service.dart';
import '../../../../utils/toast_utils.dart';
import 'gratuity_photographer.dart';

class CollectionUnLockScreen extends StatefulWidget {
  final PhotographerOrder order;
  const CollectionUnLockScreen({super.key, required this.order});

  @override
  State<CollectionUnLockScreen> createState() => _CollectionUnLockScreenState();
}

class _CollectionUnLockScreenState extends State<CollectionUnLockScreen>
    with TickerProviderStateMixin {
  List<OrderPhoto> orderUnLookPhotos = [];
  List<OrderPhoto> orderLookPhotos = [];
  late AnimationController animationController;

  bool isUnlocked = false; // Flag to indicate if the item is unlocked

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadOrderPhotos();
    });
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Adjust duration as needed
    );
  }

  Future<void> _loadOrderPhotos() async {
    final orderService = OrderService();
    final photos = await orderService.getOrderPhotos(context, widget.order.id);
    if (photos == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      setState(() {
        orderLookPhotos =
            photos.where((element) => element.isLocked == true).toList();
        orderUnLookPhotos =
            photos.where((element) => element.isLocked == false).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      body: Column(
        children: [
          50.heightBox,
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: "Your shoot is ready"
                  .text
                  .color(universalBlackPrimary)
                  .size(29)
                  .fontFamily(milligramBold)
                  .make(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: (formatDateLong(widget.order.orderDateTime))
                        .text
                        .color(universalBlackSecondary)
                        .size(13)
                        .make()),
                Row(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: widget.order.shootLengthName.text
                            .color(universalBlackSecondary)
                            .size(13)
                            .make()),
                    ", ".text.make(),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: widget.order.shootTypeName.text
                            .color(universalBlackSecondary)
                            .size(13)
                            .make()),
                    ", ".text.make(),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: widget.order.shootSceneName.text
                            .color(universalBlackSecondary)
                            .size(13)
                            .make()),
                  ],
                ),
                10.heightBox,
              ],
            ),
          ),
          orderLookPhotos.isNotEmpty
              ? Expanded(
                  child: Stack(children: [
                    buildGridView(context),
                    if (!isUnlocked)
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: ourButton(
                                color: universalColorPrimaryDefault,
                                title: "Continue to checkout",
                                textColor: universalBlackPrimary,
                                onPress: () async {
                                  await Get.to(() => GratuityPhotographerScreen(
                                      order: widget.order,
                                      isUnlook: false,
                                      lookPhotoCount: orderLookPhotos.length));
                                })
                            .box
                            .width(context.screenWidth - 50)
                            .height(50)
                            .rounded
                            .make(),
                      )
                  ]),
                )
              : Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: context.screenHeight * 0.8,
                    child: Stack(children: [
                      GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          reverse: false,
                          itemCount: orderUnLookPhotos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2),
                          itemBuilder: (context, index) {
                            OrderPhoto item = orderUnLookPhotos[index];
                            var url = item.isVideo == true
                                ? item.thumbnailPath!
                                : item.imagePath!;
                            return Column(
                              children: [
                                Stack(children: [
                                  CachedNetworkImage(
                                    fadeInDuration: const Duration(seconds: 1),
                                    imageUrl: url,
                                    height: 127,
                                    width: context.screenWidth,
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
                                  if (item.isVideo == true)
                                    const Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Icon(
                                          FontAwesomeIcons.clapperboard,
                                          color: universalWhitePrimary,
                                        )),
                                ]),
                              ],
                            );
                          }),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: ourButton(
                                color: universalColorPrimaryDefault,
                                title: "Continue to checkout",
                                textColor: universalBlackPrimary,
                                onPress: () async {
                                  await Get.to(() => GratuityPhotographerScreen(
                                      order: widget.order,
                                      isUnlook: false,
                                      lookPhotoCount: orderLookPhotos.length));
                                })
                            .box
                            .width(context.screenWidth - 50)
                            .height(50)
                            .rounded
                            .make(),
                      )
                    ]),
                  ),
                ),
          if (orderLookPhotos.isNotEmpty) 10.heightBox,
          if (orderLookPhotos.isNotEmpty)
            Expanded(
              child: Stack(children: [
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  reverse: false,
                  itemCount: orderLookPhotos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    OrderPhoto item = orderLookPhotos[index];
                    var url = item.isVideo == true
                        ? item.thumbnailPath!
                        : item.blurImagePath!;

                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity: 0.2,
                      child: CachedNetworkImage(
                        fadeInDuration: const Duration(seconds: 1),
                        imageUrl: url,
                        height: 127,
                        width: context.screenWidth,
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
                    );
                  },
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: isUnlocked
                      ? 0.5
                      : 1, // Change opacity based on unlock status
                  child: Container(
                    color:
                        universalGrayLight, // Change this to your desired gray color
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /* CustomSwitch(value: isUnlocked, onChanged: (value){
                           setState(() {
                                 isUnlocked = value; // Toggle isUnlocked
                               
                              });
                        }),*/
                        CustomSlider(
                          onChanged: (value) {
                            setState(() {
                              isUnlocked =
                                  !isUnlocked; // Update the switch state
                            });
                          },
                          initialValue: isUnlocked,
                        ),
                        20.heightBox,
                        isUnlocked
                            ? Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Unlocked.',
                                      style: TextStyle(
                                          color: universalWhitePrimary,
                                          fontSize: 24,
                                          fontFamily: milligramBold),
                                    ),
                                    SizedBox(
                                      width: 260,
                                      child: Text(
                                        'The outtakes from your shoot will be added on to your final bill.',
                                        style: TextStyle(
                                          color: universalWhitePrimary,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    20.heightBox,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Positioned(
                                          left: 20,
                                          bottom: 20,
                                          child: ourButton(
                                                  color:
                                                      universalColorPrimaryDefault,
                                                  title: "Continue to checkout",
                                                  textColor: universalBlackPrimary,
                                                  onPress: () async {
                                                    await Get.to(() =>
                                                        GratuityPhotographerScreen(
                                                            order: widget.order,
                                                            isUnlook: true,
                                                            lookPhotoCount:
                                                                orderLookPhotos
                                                                    .length));
                                                  })
                                              .box
                                              .width(context.screenWidth - 50)
                                              .height(50)
                                              .rounded
                                              .make(),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Unlock the outtakes.',
                                      style: TextStyle(
                                          color: universalWhitePrimary,
                                          fontSize: 24,
                                          fontFamily: milligramBold),
                                    ),
                                    SizedBox(
                                      width: 260,
                                      child: Text(
                                        'For an additional \$10.00, you can add on and access all of the unedited content from your shoot.',
                                        style: TextStyle(
                                          color: universalWhitePrimary,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget buildGridView(BuildContext context) {
    // Use a Container to set the height dynamically based on the itemCount
    return GridView.builder(
      physics:
          BouncingScrollPhysics(), // Use this to prevent scrolling within the GridView
      shrinkWrap: true,
      reverse: false,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.zero,

      itemCount: orderUnLookPhotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
      itemBuilder: (context, index) {
        OrderPhoto item = orderUnLookPhotos[index];
        var url = item.isVideo == true ? item.thumbnailPath! : item.imagePath!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(children: [
              CachedNetworkImage(
                fadeInDuration: const Duration(seconds: 1),
                imageUrl: url,
                height: 127,
                width: MediaQuery.of(context).size.width / 3 -
                    4, // Adjust width accordingly
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
              if (item.isVideo == true)
                const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(
                      FontAwesomeIcons.clapperboard,
                      color: universalWhitePrimary,
                    )),
            ]),
          ],
        );
      },
    );
  }
}
