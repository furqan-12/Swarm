import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/views/common/chip.dart';
import 'package:swarm/views/order/shoot_location/shoot_location_screen.dart';

import '../../../services/response/shoot_scene.dart';
import '../../../services/shoot_scene_service.dart';
import '../../../storage/models/order.dart';
import '../../../storage/order_storage.dart';
import '../../../utils/toast_utils.dart';

class ShootSceneScreen extends StatefulWidget {
  final OrderModel order;
  ShootSceneScreen({super.key, required this.order});

  @override
  State<ShootSceneScreen> createState() => _ShootSceneScreenState();
}

class _ShootSceneScreenState extends State<ShootSceneScreen> {
  List<ShootScene> items = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadShootScenes();
    });
  }

  Future<void> _loadShootScenes() async {
    final shootSceneRequest = ShootSceneService();
    final shootScenes = await shootSceneRequest.getList(
      context,
    );
    if (shootScenes == null || shootScenes is String) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }
    setState(() {
      items = (shootScenes as List<ShootScene>).sortedBy((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> selectShootScene(ShootScene shootScene) async {
    final order = await OrderStorage.getOrderModel;
    if (order != null) {
      order.shootSceneId = shootScene.id;
      order.shootSceneName = shootScene.name;
      final jsonMap = order.toJson();
      await OrderStorage.setValue(jsonEncode(jsonMap));
      Get.to(() => ShootLocationScreen(order: order));
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
              alignment: Alignment.centerLeft,
              child: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight + 20),
                  child: Wrap(spacing: 4.0, children: [
                    chip(widget.order.shootTypeName),
                  ])),
            )),
        body: Column(children: [
          15.heightBox,
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 50),
            child: Align(
                alignment: Alignment.centerLeft,
                child: "Shoot scene"
                    .text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make()),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 5),
              child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 14,
                      mainAxisExtent: 100),
                  itemBuilder: (context, index) {
                    ShootScene item = items[index];
                    return InkWell(
                        onTap: () {},
                        child: Container(
                          key: ValueKey(item.id),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                     width: 350,
                                  height: 350,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      image: DecorationImage(
                                              colorFilter: ColorFilter.mode(
                                                  Colors.black.withOpacity(0.3),
                                                  BlendMode.darken),
                                              image: CachedNetworkImageProvider(
                                                item.imagePath,
                                              ),
                                              fit: BoxFit.fill,
                                            )
                                    ),
                                  ),
                               Positioned(
                                  bottom: 10,
                                  left: 15,
                                  child: item.name.text.white
                                      .fontFamily(milligramBold)
                                      .size(17)
                                      .make()),
                            ],
                          ).box.rounded.make().onTap(() async {
                            await selectShootScene(item);
                          }),
                        ));
                  }),
            ),
          ),
        ]));
  }
}
