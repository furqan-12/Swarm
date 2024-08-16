import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:swarm/consts/consts.dart';
import 'package:intl/intl.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/views/photographer/home_photographer.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/new_request_widget.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/photographer_shoot_detail.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/shoots_upload_widget.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/upcoing_shoots_widget.dart';
import 'package:swarm/views/photographer/upload_shoot_screen/upload_first_shoots.dart';
import '../../../consts/api.dart';

import '../../../services/order_service.dart';
import '../../../services/response/user.dart';
import '../../../services/user_profile_service.dart';
import '../../../storage/token_storage.dart';
import '../../../storage/user_profile_storage.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';
import '../chat_screen/photograpers_chat_screen.dart';

class UpcomingShootsScreen extends StatefulWidget {
  UpcomingShootsScreen({Key? key}) : super(key: key);

  @override
  State<UpcomingShootsScreen> createState() => _UpcomingShootsScreenState();
}

class _UpcomingShootsScreenState extends State<UpcomingShootsScreen> {
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

    if (toUserId == user?.id && type == "1" && type == "5") {
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
        upcomingOrders = orders.where((e) => e.timeLineType == 3).toList();
        newBookingOrders = orders.where((e) => e.timeLineType == 2).toList();
        shootToUploadOrder = orders
            .where((e) =>
                e.timeLineType == 1 &&
                !e.orderPhotos.any((o) => o.isSharedToCustomer == true))
            .toList();
      });
    }
  }

  List<PhotographerOrder> upcomingOrders = [];
  List<PhotographerOrder> newBookingOrders = [];
  List<PhotographerOrder> shootToUploadOrder = [];
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
    Get.to(() => PhotographersChatScreen(orderId: item.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: universalWhitePrimary,
        surfaceTintColor: universalWhitePrimary,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          child: Image.asset("assets/icons/arrow.png").onTap(() {
            Get.offAll(() => HomePhotoGrapherScreen());
          }),
        ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: user == null
                      ? null
                      : CachedNetworkImageProvider(user!.imageUrl),
                ),
              ),
            ),
            20.heightBox,
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: "Your schedule"
                    .text
                    .fontFamily(milligramBold)
                    .color(universalBlackPrimary)
                    .size(36)
                    .make(),
              ),
            ),
            10.heightBox,
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      "Here’s your to-do list for ",
                      style: TextStyle(
                          fontSize: 15, fontFamily: milligramSemiBold),
                    ),
                    DateFormat('M/d/y')
                        .format(DateTime.now())
                        .toString()
                        .text
                        .fontFamily(milligramSemiBold)
                        .color(universalBlackPrimary)
                        .size(15)
                        .make(),
                  ],
                ),
              ),
            ),
            20.heightBox,
            SizedBox(
              height: context.screenHeight * 0.55,
              child: upcomingOrders.isEmpty &&
                      newBookingOrders.isEmpty &&
                      shootToUploadOrder.isEmpty
                  ? const Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "You haven’t received any new orders",
                          style: TextStyle(
                            color: universalBlackPrimary,
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          if (upcomingOrders.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        "Upcoming shoots"
                                            .text
                                            .fontFamily(milligramSemiBold)
                                            .color(universalBlackPrimary)
                                            .size(15)
                                            .make(),
                                        const SizedBox(width: 5),
                                        upcomingOrders.length > 0
                                            ? CircleAvatar(
                                                radius: 10.0,
                                                backgroundColor:
                                                    universalColorPrimaryDefault, // You can change the color
                                                child: Text(
                                                  upcomingOrders.length
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color:
                                                        universalBlackPrimary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                    Text(
                                      "See all",
                                      style: TextStyle(
                                          color: universalColorSecondaryDefault,
                                          fontSize: 14,
                                          fontFamily: milligramSemiBold),
                                    ).onTap(() {
                                      Get.to(() => PhotographerShootDetails(
                                              user: user,
                                              selecter: UpcomingShoots(
                                                  upcomingOrders),
                                              name: "Upcoming Shoots"))!
                                          .then((value) => {_loadOrders()});
                                    })
                                  ],
                                ),
                              ),
                            ),
                          if (upcomingOrders.isNotEmpty) 10.heightBox,
                          if (upcomingOrders.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: upcomingOrders.length > 2
                                  ? 2
                                  : upcomingOrders.length,
                              itemBuilder: (context, index) {
                                PhotographerOrder item = upcomingOrders[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 5),
                                  child: InkWell(
                                    onTap: () {
                                      _openChat(item);
                                    },
                                    child: ListTile(
                                      leadingAndTrailingTextStyle: TextStyle(),
                                      leading: item.customerProfileImage
                                              .isEmptyOrNull
                                          ? CircleAvatar(
                                              radius: 30,
                                              backgroundImage:
                                                  AssetImage(swarmLogoColor))
                                          : CircleAvatar(
                                              radius: 30,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(item
                                                      .customerProfileImage!),
                                            ),
                                      title: Text(
                                        (item.customerName! + "  "),
                                        style: TextStyle(
                                            fontFamily: milligramBold,
                                            color: universalWhitePrimary),
                                      ),
                                      subtitle: Text(
                                        "${item.shootTypeName}, ${item.shootSceneName}, ${formatDate(item.orderDateTime)}",
                                        style: TextStyle(
                                            color: universalWhitePrimary,
                                            fontSize: 12),
                                      ),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 25),
                                        child: Row(
                                          mainAxisSize: MainAxisSize
                                              .min, // Prevents overflow by minimizing the row size to its children size
                                          children: [
                                            Text(
                                              remainingDays(item.orderDateTime),
                                              style: TextStyle(
                                                fontFamily: milligramRegular,
                                                fontSize: 14,
                                                color: universalBlackTertiary,
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                    8), // Provides spacing between the text and the icon
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 13,
                                              color: universalBlackTertiary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                        .box
                                        .width(context.screenWidth - 20)
                                        .color(universalColorSecondaryDefault)
                                        .shadowXs
                                        .make(),
                                  ),
                                );
                              },
                            ),
                          if (newBookingOrders.isNotEmpty) 20.heightBox,
                          if (newBookingOrders.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        "New shoot requests"
                                            .text
                                            .fontFamily(milligramSemiBold)
                                            .color(universalBlackPrimary)
                                            .size(15)
                                            .make(),
                                        const SizedBox(width: 5),
                                        newBookingOrders.length > 0
                                            ? CircleAvatar(
                                                radius: 10.0,
                                                backgroundColor:
                                                    universalColorPrimaryDefault, // You can change the color
                                                child: Text(
                                                  newBookingOrders.length
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color:
                                                        universalBlackPrimary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                    Text(
                                      "See all",
                                      style: TextStyle(
                                          color: universalColorSecondaryDefault,
                                          fontSize: 14,
                                          fontFamily: milligramSemiBold),
                                    ).onTap(() {
                                      Get.to(() => PhotographerShootDetails(
                                              user: user,
                                              selecter: NewRequestsWidget(
                                                  newBookingOrders:
                                                      newBookingOrders),
                                              name: "New requests"))!
                                          .then((value) => {_loadOrders()});
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          if (newBookingOrders.isNotEmpty) 10.heightBox,
                          if (newBookingOrders.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: newBookingOrders.length > 2
                                  ? 2
                                  : newBookingOrders.length,
                              itemBuilder: (context, index) {
                                PhotographerOrder item =
                                    newBookingOrders[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 5),
                                  child: InkWell(
                                    onTap: () {
                                      _openChat(item);
                                    },
                                    child: ListTile(
                                      leadingAndTrailingTextStyle: TextStyle(),
                                      leading: item.customerProfileImage
                                              .isEmptyOrNull
                                          ? CircleAvatar(
                                              radius: 30,
                                              backgroundImage:
                                                  AssetImage(swarmLogoColor))
                                          : CircleAvatar(
                                              radius: 30,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(item
                                                      .customerProfileImage!),
                                            ),
                                      title: Text(
                                        (item.customerName! + "  "),
                                        style: TextStyle(
                                            fontFamily: milligramBold,
                                            color: universalBlackPrimary),
                                      ),
                                      subtitle: Text(
                                        "${item.shootTypeName}, ${item.shootSceneName}, ${formatDate(item.orderDateTime)}",
                                        style: TextStyle(
                                            color: universalBlackPrimary,
                                            fontSize: 12),
                                      ),
                                      trailing: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 25),
                                          child: Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            size: 14,
                                          )),
                                    )
                                        .box
                                        .width(context.screenWidth - 20)
                                        .color(universalBlackCell)
                                        .shadowXs
                                        .make(),
                                  ),
                                );
                              },
                            ),
                          if (shootToUploadOrder.isNotEmpty) 20.heightBox,
                          if (shootToUploadOrder.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        "Shoots to upload"
                                            .text
                                            .fontFamily(milligramSemiBold)
                                            .color(universalBlackPrimary)
                                            .size(15)
                                            .make(),
                                        const SizedBox(width: 5),
                                        shootToUploadOrder.length > 0
                                            ? CircleAvatar(
                                                radius: 10.0,
                                                backgroundColor:
                                                    universalColorPrimaryDefault, // You can change the color
                                                child: Text(
                                                  shootToUploadOrder.length
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color:
                                                        universalBlackPrimary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                    Text(
                                      "See all",
                                      style: TextStyle(
                                          color: universalColorSecondaryDefault,
                                          fontSize: 14,
                                          fontFamily: milligramSemiBold),
                                    ).onTap(() {
                                      Get.to(() => PhotographerShootDetails(
                                              user: user,
                                              selecter: ShootToUpload(
                                                  shootToUploadOrder),
                                              name: "Shoots to upload"))!
                                          .then((value) => {_loadOrders()});
                                    })
                                  ],
                                ),
                              ),
                            ),
                          if (shootToUploadOrder.isNotEmpty) 10.heightBox,
                          if (shootToUploadOrder.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: shootToUploadOrder.length > 2
                                  ? 2
                                  : shootToUploadOrder.length,
                              itemBuilder: (context, index) {
                                PhotographerOrder item =
                                    shootToUploadOrder[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 5),
                                  child: InkWell(
                                    onTap: () {
                                      _openChat(item);
                                    },
                                    child: ListTile(
                                            leadingAndTrailingTextStyle:
                                                TextStyle(),
                                            leading: item.customerProfileImage
                                                    .isEmptyOrNull
                                                ? CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage: AssetImage(
                                                        swarmLogoColor))
                                                : CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            item.customerProfileImage!),
                                                  ),
                                            title: Text(
                                              (item.customerName! + "  "),
                                              style: TextStyle(
                                                  fontFamily: milligramBold,
                                                  color: universalBlackPrimary),
                                            ),
                                            subtitle: RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  color:
                                                      universalBlackPrimary, // Make sure this color is defined in your app
                                                  fontSize: 12,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text:
                                                          "${item.shootTypeName}, ${item.shootSceneName}, "),
                                                  TextSpan(
                                                    text:
                                                        "${remainingHours(item.orderDateTime)}",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            milligramBold),
                                                  ),
                                                  TextSpan(
                                                      text: " left to upload"),
                                                ],
                                              ),
                                            ),
                                            trailing: Image.asset(
                                              "assets/icons/cameraicon.png",
                                              width: 40,
                                              height: 40,
                                            ).onTap(() {
                                              Get.to(() => UploadFirstShoot(
                                                      user: user, order: item))!
                                                  .then((value) =>
                                                      {_loadOrders()});
                                            }))
                                        .box
                                        .width(context.screenWidth - 20)
                                        .padding(EdgeInsets.all(5))
                                        .color(universalWhitePrimary)
                                        .shadowXs
                                        .border(
                                            color: universalTransblackSecondary,
                                            width: 1.0)
                                        .make(),
                                  ),
                                );
                              },
                            ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
