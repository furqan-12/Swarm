import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/collection_screen/collection_item_detail.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';

import '../../../../consts/api.dart';
import '../../../../services/order_service.dart';
import '../../../../services/response/user.dart';
import '../../../../services/user_profile_service.dart';
import '../../../../storage/token_storage.dart';
import '../../../../storage/user_profile_storage.dart';
import '../../../../utils/toast_utils.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  HubConnection? _hubConnection;

  Future<void> openChatConnection() async {
    if (_hubConnection == null) {
      final httpConnectionOptions = HttpConnectionOptions(
          accessTokenFactory: () => TokenStorage.getJwtToken);

      _hubConnection = HubConnectionBuilder()
          .withUrl("$signalRUrl/notifications", options: httpConnectionOptions)
          .withAutomaticReconnect(
              retryDelays: [2000, 5000, 10000, 20000]).build();

      _hubConnection?.on("NotificationFromServer", _handleIncommingChatMessage);
    }

    if (_hubConnection?.state != HubConnectionState.Connected) {
      await _hubConnection?.start();
    }
  }

  Future<void> _handleIncommingChatMessage(List<Object?>? args) async {
    if (args == null) {
      return;
    }

    if (args[0].toString() != "Swarm.Shared.Notifications.OrderNotification") {
      return;
    }
    var json = args[1] as Map<String, dynamic>;
    final String type = json["type"]!.toString();
    final String orderId = json["orderId"]!;
    final String toUserId = json["toUserId"]!;

    if (toUserId == user!.id && type == "5") {
      var order = await OrderService().getOrder(context, orderId, toUserId);
      if (order != null) {
        await _loadOrders();
      }
    }
  }

  List<PhotographerOrder> compeletedOrders = [];

  Future<void> _loadOrders() async {
    final user = await UserProfileStorage.getUserProfileModel;
    final orderService = OrderService();
    final orders = await orderService.getCustomerOrders(context, user!.id);
    if (orders == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      setState(() {
        compeletedOrders =
            orders.where((element) => element.timeLineType == 4).toList();
        compeletedOrders
            .sort((a, b) => b.orderDateTime.compareTo(a.orderDateTime));
      });
    }
  }

  UserProfile? user = null;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadUserProfile();
    });
  }

  @override
  void dispose() {
    _hubConnection?.stop();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final userProfile = await UserProfileStorage.getUserProfileModel;
    if (userProfile != null) {
      setState(() {
        user = userProfile;
      });
    } else {
      final userProfileService = UserProfileService();
      final userProfile = await userProfileService.getUserProfile(
        context,
      );
      if (userProfile == null) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }
      final jsonMap = userProfile.toJson();
      UserProfileStorage.setValue(jsonEncode(jsonMap));
      setState(() {
        user = userProfile;
      });
    }
    await _loadOrders();
    await openChatConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: universalWhitePrimary,
          backgroundColor: universalWhitePrimary,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            child: Image.asset("assets/icons/arrow.png").onTap(() {
              Get.offAll(() => HomeUserScreen());
            }),
          ),
        ),
        backgroundColor: universalWhitePrimary,
        body: Container(
            padding: const EdgeInsets.only(left: 12, right: 12),
            width: context.screenWidth,
            height: context.screenHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: "Your collections"
                        .text
                        .fontFamily(milligramBold)
                        .black
                        .size(40)
                        .make(),
                  ),
                ),
                10.heightBox,
                compeletedOrders.isEmpty
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          300.heightBox,
                          Text(
                            "No collections",
                            style: TextStyle(
                                color: universalBlackSecondary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ))
                    : Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: compeletedOrders.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              PhotographerOrder item = compeletedOrders[index];
                              return InkWell(
                                  onTap: () {
                                    Get.to(() =>
                                            CollectionItemDetail(order: item))
                                        ?.then((value) async =>
                                            await _loadOrders());
                                  },
                                  child: Container(
                                      child: Column(children: [
                                    Stack(children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3)),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(seconds: 1),
                                          imageUrl: item.orderPhotos
                                              .firstWhere((e) =>
                                                  e.isVideo == false &&
                                                  e.isLocked == false)
                                              .imagePath!,
                                          height: 174,
                                          width: context.screenWidth,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child:
                                                const CircularProgressIndicator(
                                              color:
                                                  universalColorPrimaryDefault,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            color: specialError,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                          bottom: 30,
                                          left: 10,
                                          child:
                                              "${item.shootTypeName},\n${formatDateString(item.orderDateTime)}"
                                                  .text
                                                  .white
                                                  .fontFamily(milligramBold)
                                                  .size(17)
                                                  .make()),
                                      Positioned(
                                          bottom: 10,
                                          left: 10,
                                          child:
                                              "${item.orderPhotos.length} photos"
                                                  .text
                                                  .white
                                                  .fontFamily(milligramRegular)
                                                  .size(13)
                                                  .make())
                                    ])
                                  ])));
                            }),
                      ),
              ],
            )));
  }
}
