import 'dart:convert';

import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/shoot_type_service.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';

import '../../../services/response/shoot_type.dart';
import '../../../storage/models/order.dart';
import '../../../storage/order_storage.dart';
import '../../../utils/toast_utils.dart';
import '../shoot_scene/shoot_scene_screen.dart';

class ShootTypeScreen extends StatefulWidget {
  final bool fromHome;
  const ShootTypeScreen({super.key, required this.fromHome});

  @override
  State<ShootTypeScreen> createState() => _ShootTypeScreenState();
}

class _ShootTypeScreenState extends State<ShootTypeScreen> {
  List<ShootType> items = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadShootTypes();
    });
  }

  Future<void> _loadShootTypes() async {
    final shootTypeRequest = ShootTypeService();
    final shootTypes = await shootTypeRequest.getList(
      context,
    );
    if (shootTypes == null || shootTypes is String) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }

    setState(() {
      items = shootTypes;
    });
  }

  Future<void> selectShootType(ShootType shootType) async {
    OrderModel? order = null;
    try {
      order = await OrderStorage.getOrderModel;
    } catch (e) {}
    if (order != null) {
      order.shootTypeId = shootType.id;
      order.shootTypeName = shootType.name;
      final jsonMap = order.toJson();
      await OrderStorage.setValue(jsonEncode(jsonMap));
    } else {
      order =
          OrderModel(shootTypeId: shootType.id, shootTypeName: shootType.name);

      final json = order.toJson();

      await OrderStorage.setValue(jsonEncode(json));
    }
    Get.to(() => ShootSceneScreen(order: order!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            surfaceTintColor: universalWhitePrimary,
            backgroundColor: universalWhitePrimary,
            toolbarHeight: 100,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
              child: Image.asset("assets/icons/arrow.png").onTap(() {
                Get.offAll(() => HomeUserScreen());
              }),
            )),
        backgroundColor: universalWhitePrimary,
        body: Column(children: [
          15.heightBox,
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 50),
            child: Align(
                alignment: Alignment.centerLeft,
                child: "Shoot type"
                    .text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make()),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8, right: 10, bottom: 10, top: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: List.generate(items.length, (index) {
                    ShootType item = items[index];
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                              child: SizedBox(
                                width: 400,
                                height: 140,
                                child: CachedNetworkImage(
                                  fadeInDuration: const Duration(seconds: 1),
                                  imageUrl: item.imagePath,
                                  fit: BoxFit.fitWidth,
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
                            ),
                            Positioned(
                                bottom: 10,
                                left: 10,
                                child: item.name.text.white
                                    .fontFamily(milligramBold)
                                    .size(24)
                                    .make()),
                          ],
                        ),
                      )
                          .box
                          .padding(const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20))
                          .make()
                          .onTap(() async {
                        await selectShootType(item);
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
        ]));
  }
}
