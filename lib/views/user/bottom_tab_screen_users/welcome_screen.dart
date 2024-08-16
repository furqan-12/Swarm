import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/photographer_order.dart';

import 'package:swarm/views/common/our_button.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/gratuity_photographer/collection_unlock_screen.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';

import '../../../consts/api.dart';

import '../../../services/order_service.dart';
import '../../../services/response/user.dart';
import '../../../services/user_profile_service.dart';
import '../../../storage/token_storage.dart';
import '../../../storage/user_profile_storage.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';
import '../chat_screen/user_chat_screen.dart';

class WelcomeScreen extends StatefulWidget {
  String? orderId = null;
  WelcomeScreen({super.key, String? this.orderId});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  HubConnection? _hubConnection;
  PhotographerOrder? payOrder = null;
  bool dialogShown = false;

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

    if (toUserId == user!.id && type != "0") {
      var order = await OrderService().getOrder(context, orderId, toUserId);
      if (order != null) {
        await _loadOrders();
      }
    }
  }

  List<PhotographerOrder> inProgressOrders = [];
  Future<void> _loadOrders() async {
    final user = await UserProfileStorage.getUserProfileModel;
    final orderService = OrderService();
    final orders = await orderService.getCustomerOrders(context, user!.id);
    if (orders == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      setState(() {
        inProgressOrders =
            orders.where((element) => element.timeLineType == 3).toList();
        if (widget.orderId != null) {
          payOrder =
              inProgressOrders.firstWhereOrNull((e) => e.id == widget.orderId);
        }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.orderId != null) {
        // dialogShown =
        //     KeyValueStorage.getValue(widget.orderId! + "WelcomeScreenInner") !=
        //         "";
        if (widget.orderId != null && payOrder != null && !dialogShown) {
          ToastHelper.showSuccessToast(
              context,
              CircleAvatar(
                radius: 35,
                backgroundImage: CachedNetworkImageProvider(
                    payOrder!.photographerProfileImage!),
              ),
              "Your shoot is ready!",
              "To view your portfolio from your shoot, please pay the balance first.",
              "Pay now", () {
            Navigator.of(context).pop();
            Get.to(CollectionUnLockScreen(
              order: payOrder!,
            ));
          });
          dialogShown = true;
          // KeyValueStorage.setValue(
          //     widget.orderId! + "WelcomeScreenInner", "true");
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        //   child: Image.asset("assets/icons/arrow.png").onTap(() {
        //     Navigator.of(context).pop();
        //   }),
        // ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: user == null
                  ? null
                  : CachedNetworkImageProvider(user!.imageUrl),
            ),
            20.heightBox,
            "Welcome back,\n${user == null ? "" : user?.name}"
                .text
                .fontFamily(bold)
                .color(universalBlackPrimary)
                .size(36)
                .make(),
            10.heightBox,
            "Your upcoming shoots"
                .text
                .fontFamily(bold)
                .color(universalBlackPrimary)
                .size(20)
                .make(),
            10.heightBox,
            if (!inProgressOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 80),
                child: Divider(),
              ),
            Expanded(
              child: inProgressOrders.isEmpty
                  ? const Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "You haven’t booked any new shoots.\nWould you like to book one now?",
                          style: TextStyle(
                            color: universalBlackPrimary,
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ))
                  : ListView.builder(
                      itemCount: inProgressOrders.length,
                      itemBuilder: (context, index) {
                        return OrderItemWidget(item: inProgressOrders[index]);
                      },
                    ),
            ),
            10.heightBox,
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
              child: ourButton(
                      color: universalColorPrimaryDefault,
                      title: "Book a new shoot",
                      textColor: universalBlackPrimary,
                      onPress: () {
                        Get.offAll(() => HomeUserScreen(index: 0));
                      })
                  .box
                  .width(context.screenWidth - 30)
                  .height(47)
                  .rounded
                  .make(),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItemWidget extends StatelessWidget {
  final PhotographerOrder item;
  const OrderItemWidget({required this.item});

  void _openChat(PhotographerOrder item) {
    Get.to(() => UserChatScreen(orderId: item.id));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: InkWell(
          onTap: () {
            _openChat(item);
          },
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.only(left: 4, right: 4),
                leading: item.photographerProfileImage.isEmptyOrNull
                    ? Image.asset(
                        "assets/icons/cameraicon.png",
                        width: 50,
                        height: 50,
                        color: universalBlackPrimary,
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundImage: CachedNetworkImageProvider(
                            item.photographerProfileImage!),
                      ),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (item.photographerName! + "  "),
                        style: TextStyle(
                            fontFamily: bold, color: universalBlackPrimary),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            remainingDays(item.orderDateTime),
                            style: TextStyle(
                                fontFamily: milligramRegular,
                                fontSize: 14,
                                color: universalBlackTertiary),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 13,
                            color: universalBlackTertiary,
                          )
                        ],
                      )
                    ]),
                subtitle: Text(
                  "${item.shootTypeName}, ${item.shootSceneName}, ${formatDate(item.orderDateTime)}",
                  style:
                      TextStyle(color: universalBlackPrimary, fontSize: 12.9),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80),
                child: Divider(),
              ),
            ],
          )),
    );
  }
}
