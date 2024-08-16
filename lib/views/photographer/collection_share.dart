import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../../services/order_service.dart';
import '../../services/response/photographer_order.dart';
import '../../utils/toast_utils.dart';
import 'chat_screen/photograpers_chat_screen.dart';

class CollectionSharePhotographerScreen extends StatefulWidget {
  final PhotographerOrder order;

  const CollectionSharePhotographerScreen({super.key, required this.order});

  @override
  State<CollectionSharePhotographerScreen> createState() =>
      _CollectionSharePhotographerScreenState();
}

class _CollectionSharePhotographerScreenState
    extends State<CollectionSharePhotographerScreen> {
  List<OrderPhoto> orderUnLookPhotos = [];
  List<OrderPhoto> orderLookPhotos = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadOrderPhotos();
    });
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

  Future<void> _sharePortfolio() async {
    if (orderUnLookPhotos.isEmpty) {
      ToastHelper.showErrorToast(
          context, "Please add atlease one unlock photo.");
      return;
    }
    final orderService = OrderService();
    final isShared =
        await orderService.sharePortfolio(context, widget.order.id);
    if (isShared == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      Get.off(() => PhotographersChatScreen(orderId: widget.order.id));
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
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderUnLookPhotos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
                itemBuilder: (context, index) {
                  OrderPhoto item = orderUnLookPhotos[index];
                  var url = item.isVideo == true
                      ? item.thumbnailPath!
                      : item.imagePath!;
                  return InkWell(
                      onTap: () {},
                      child: Column(
                        children: [
                          Stack(children: [
                            CachedNetworkImage(
                              fadeInDuration: const Duration(seconds: 1),
                              imageUrl: url,
                              height: 125,
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
                                  bottom: 10,
                                  left: 15,
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: universalBlackCell,
                                  )),
                          ]),
                        ],
                      ));
                }),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "${widget.order.customerName}'s portfolio"
                  .text
                  .color(universalBlackPrimary)
                  .fontFamily(milligramBold)
                  .size(25)
                  .make(),
              widget.order.shortAddress.text
                  .color(universalBlackPrimary)
                  .size(15)
                  .make(),
              20.heightBox,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: universalColorSecondaryDefault,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: () async {
                  await _sharePortfolio();
                },
                child: "Share it"
                    .text
                    .color(universalWhitePrimary)
                    .fontFamily(milligramBold)
                    .size(15)
                    .make(),
              ).box.width(140).height(40).roundedSM.make(),
            ],
          )
              .box
              .color(universalColorPrimaryDefault)
              .width(context.screenWidth)
              .margin(const EdgeInsets.only(top: 2, bottom: 2))
              .padding(const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 30))
              .make(),
          Expanded(
            child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderLookPhotos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
                itemBuilder: (context, index) {
                  OrderPhoto item = orderLookPhotos[index];
                  var url = item.isVideo == true
                      ? item.thumbnailPath!
                      : item.imagePath!;
                  return InkWell(
                      onTap: () {},
                      child: Column(
                        children: [
                          Stack(children: [
                            ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                  sigmaX: 1.5,
                                  sigmaY: 1.5,
                                  tileMode: TileMode.decal),
                              child: CachedNetworkImage(
                                fadeInDuration: const Duration(seconds: 1),
                                imageUrl: url,
                                height: 125,
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
                            ),
                            if (item.isVideo == true)
                              const Positioned(
                                  bottom: 10,
                                  left: 15,
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: universalBlackCell,
                                  )),
                            const Positioned(
                                bottom: 10,
                                right: 15,
                                child: Icon(
                                  Icons.lock,
                                  color: universalWhitePrimary,
                                )),
                          ]),
                        ],
                      ));
                }),
          ),
        ],
      ),
    );
  }
}
