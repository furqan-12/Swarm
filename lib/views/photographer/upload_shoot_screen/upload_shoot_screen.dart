import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/views/photographer/recipt_screen.dart';

import '../../../consts/api.dart';
import '../../../services/order_service.dart';
import '../../../services/response/photographer_order.dart';
import '../../../services/response/user.dart';
import '../../../services/user_profile_service.dart';
import '../../../storage/token_storage.dart';
import '../../../storage/user_profile_storage.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';
import '../chat_screen/photograpers_chat_screen.dart';

class UploadShootsScreen extends StatefulWidget {
  const UploadShootsScreen({Key? key}) : super(key: key);

  @override
  State<UploadShootsScreen> createState() => _UploadShootsScreenState();
}

class _UploadShootsScreenState extends State<UploadShootsScreen> {
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

    if (toUserId == user!.id && type == "1" && type == "5") {
      var order = await OrderService().getOrder(context, orderId, toUserId);
      if (order != null) {
        await _loadOrders();
      }
    }
  }

  Future<void> _loadOrders() async {
    final user = await UserProfileStorage.getUserProfileModel;
    final orderService = OrderService();
    final orders = await orderService.getPhotographerOrders(context, user!.id);
    if (orders == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      setState(() {
        listOrders = orders;
      });
    }
  }

  List<PhotographerOrder> listOrders = [];
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
      final userProfile = await userProfileService.getUserProfile(context);
      if (userProfile is String) {
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

  void _openChat(PhotographerOrder item) {
    if (item.timeLineType == 3) {
      Get.to(() => OrderReciptScreen(orderId: item.id));
    } else {
      Get.to(() => PhotographersChatScreen(orderId: item.id));
    }
  }

  Map<String, List<PhotographerOrder>> groupOrdersByDate(
      List<PhotographerOrder> orders) {
    Map<String, List<PhotographerOrder>> groupedOrders = {};

    for (var order in orders) {
      String dateKey = formatDateString(order.orderDateTime);
      if (!groupedOrders.containsKey(dateKey)) {
        groupedOrders[dateKey] = [];
      }
      groupedOrders[dateKey]!.add(order);
    }

    return groupedOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: universalWhitePrimary,
        body: DefaultTabController(
          length: 3,
          child: Center(
            child: Column(children: [
              (context.screenHeight * 0.1).heightBox,
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 50),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: "Photo shoots"
                        .text
                        .fontFamily(milligramBold)
                        .black
                        .size(40)
                        .make()),
              ),
              Column(
                children: [
                  SizedBox(
                    width: context.screenWidth,
                    height: 60,
                    child: TabBar(
                      padding: EdgeInsets.only(bottom: 7),
                      indicatorColor: universalBlackPrimary,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 2,
                      labelStyle:
                          TextStyle(fontSize: 17, fontFamily: milligramBold),
                      unselectedLabelColor: universalBlackTertiary,
                      labelColor: universalBlackPrimary,
                      tabs: [
                        Tab(text: 'In Progress'),
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Completed'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: context.screenHeight * 0.66,
                    child: TabBarView(
                      children: [
                        SizedBox(
                            width: context.screenWidth,
                            height: context.screenHeight,
                            child: buildTabContent('In Progress')),
                        SizedBox(
                            width: context.screenWidth,
                            height: context.screenHeight,
                            child: buildTabContent('Upcoming')),
                        SizedBox(
                            width: context.screenWidth,
                            height: context.screenHeight,
                            child: buildTabContent('Completed')),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ));
  }

  Widget buildTabContent(String tabTitle) {
    final filteredOrders = listOrders.where((order) {
      switch (tabTitle) {
        case 'Upcoming':
          return order.timeLineType == 1;
        case 'In Progress':
          return order.timeLineType == 2;
        case 'Completed':
          return order.timeLineType == 3;
        default:
          return false;
      }
    }).toList();

    Map<String, List<PhotographerOrder>> groupedOrders =
        groupOrdersByDate(filteredOrders);

    return groupedOrders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "No ${tabTitle} Orders",
                  style: TextStyle(
                    color: universalBlackSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: groupedOrders.length,
            itemBuilder: (context, index) {
              String dateKey = groupedOrders.keys.elementAt(index);
              List<PhotographerOrder> orders = groupedOrders[dateKey]!;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      dateKey,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Wrap the orders in a Column or SingleChildScrollView
                  Column(
                    children: orders.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 5),
                        child: InkWell(
                          onTap: () {
                            _openChat(item);
                          },
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  (item.customerName! + "  "),
                                  style: TextStyle(
                                      fontFamily: milligramBold,
                                      color: universalBlackPrimary),
                                ),
                                Text(
                                  (item.orderStatusName),
                                  style: TextStyle(
                                      fontFamily: milligramBold,
                                      fontSize: 12,
                                      color: universalWhitePrimary),
                                )
                                    .box
                                    .color(
                                        getColorForStatus(item.orderStatusNo))
                                    .padding(EdgeInsets.only(
                                        left: 4, right: 4, top: 2, bottom: 2))
                                    .roundedSM
                                    .make(),
                              ],
                            ),
                            subtitle: Text(
                              "${item.shootTypeName}, ${item.shootSceneName}, ${formatDate(item.orderDateTime)}, ${item.shortAddress}  ${item.shootLengthName} • \$${item.orderAmount}",
                              style: TextStyle(
                                  color: universalTransblackPrimary,
                                  fontSize: 12),
                            ),
                            trailing: item.customerProfileImage.isEmptyOrNull
                                ? Image.asset(
                                    "assets/icons/cameraicon.png",
                                    width: 50,
                                    height: 50,
                                    color: universalBlackPrimary,
                                  )
                                : CachedNetworkImage(
                                    fadeInDuration: const Duration(seconds: 1),
                                    imageUrl: item.customerProfileImage!,
                                    width: 50,
                                    height: 50,
                                    placeholder: (context, url) => Center(
                                      child: const CircularProgressIndicator(
                                        color: universalColorPrimaryDefault,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      color: specialError,
                                    ),
                                  ).box.roundedSM.make(),
                          )
                              .box
                              .width(context.screenWidth - 20)
                              .padding(const EdgeInsets.all(5.0))
                              .height(90)
                              .color(universalBlackCell)
                              .border(color: universalBlackLine, width: 1.0)
                              .roundedSM
                              .make(),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          );
  }
}
