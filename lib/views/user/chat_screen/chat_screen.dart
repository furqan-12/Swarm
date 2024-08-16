import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/order_service.dart';
import 'package:swarm/storage/models/order.dart';
import 'package:swarm/views/photographer/home_photographer.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';
import 'package:swarm/views/user/chat_screen/user_chat_screen.dart';

import '../../../consts/api.dart';
import '../../../services/response/photographer_order.dart';
import '../../../services/response/user.dart';
import '../../../services/user_profile_service.dart';
import '../../../storage/token_storage.dart';
import '../../../storage/user_profile_storage.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';
import '../../photographer/chat_screen/photograpers_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  HubConnection? _hubConnection;
  List<PhotographerOrder> listOrders = [];
  List<PhotographerOrder> filteredChats = [];
  List<PhotographerOrder> upcomingShootChats = [];
  List<PhotographerOrder> shootHistroyChats = [];

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
    // final String orderId = json["orderId"]!;
    final String toUserId = json["toUserId"]!;

    if (toUserId == user!.id && type == "0") {
      await _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    final user = await UserProfileStorage.getUserProfileModel;
    final orderService = OrderService();
    final orders = user?.profileTypeId == PhotographerTypeId
        ? await orderService.getPhotographerOrders(context, user!.id)
        : await orderService.getCustomerOrders(context, user!.id);
    if (orders == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      setState(() {
        listOrders = orders;
      });
    }
    setState(() {
      filteredChats = listOrders;
      upcomingShootChats = listOrders
          .where((e) =>
              e.timeLineType == 3 ||
              e.timeLineType == 2 ||
              (e.timeLineType == 1 &&
                  !e.orderPhotos
                      .any((element) => element.isSharedToCustomer == true)))
          .toList();
      shootHistroyChats = listOrders
          .where((e) =>
              e.timeLineType == 4 ||
              (e.timeLineType == 1 &&
                  e.orderPhotos
                      .any((element) => element.isSharedToCustomer == true)))
          .toList();
    });

    await openChatConnection();
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

  void _filterMessages(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredChats = listOrders.sortedBy((a, b) =>
            b.lastChatMessageDateTime!.compareTo(a.lastChatMessageDateTime!));
        upcomingShootChats =
            filteredChats.where((e) => e.timeLineType == 3).toList();
        shootHistroyChats =
            filteredChats.where((e) => e.timeLineType == 4).toList();
      });
    } else {
      if (user!.profileTypeId == PhotographerTypeId) {
        setState(() {
          filteredChats = listOrders
              .where((chat) =>
                  chat.customerName!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  chat.shootTypeName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  chat.shootSceneName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  chat.shortAddress
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  chat.orderChats
                      .where((element) => element.fromSystem != true)
                      .lastOrNull()
                      .message
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList()
              .sortedBy((a, b) => b.lastChatMessageDateTime!
                  .compareTo(a.lastChatMessageDateTime!));
          upcomingShootChats =
              filteredChats.where((e) => e.timeLineType == 3).toList();
          shootHistroyChats =
              filteredChats.where((e) => e.timeLineType == 4).toList();
        });
      } else {
        setState(() {
          filteredChats = listOrders
              .where((chat) =>
                  chat.photographerName!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  chat.shootTypeName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  chat.shootSceneName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  chat.shortAddress
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  chat.orderChats
                      .lastOrNull()
                      .message
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList()
              .sortedBy((a, b) => b.lastChatMessageDateTime!
                  .compareTo(a.lastChatMessageDateTime!));
          upcomingShootChats =
              filteredChats.where((e) => e.timeLineType == 3).toList();
          shootHistroyChats =
              filteredChats.where((e) => e.timeLineType == 4).toList();
        });
      }
    }
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
      if (userProfile is String) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }
      final jsonMap = userProfile.toJson();
      UserProfileStorage.setValue(jsonEncode(jsonMap));
      setState(() async {
        user = userProfile;
      });
    }
    _loadOrders();
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
            if (user?.profileTypeId != PhotographerTypeId) {
              Get.offAll(() => HomeUserScreen());
            } else {
              Get.offAll(() => HomePhotoGrapherScreen());
            }
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
                child: "Inbox"
                    .text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make(),
              ),
            ),
            10.heightBox,
            listOrders.isEmpty
                ? SizedBox(
                    height: context.screenHeight * 0.70,
                    child: const Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "You have no new chats.",
                          style: TextStyle(
                            color: universalBlackPrimary,
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )))
                : Container(
                    alignment: Alignment.center,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: universalSearch),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: TextFormField(
                        onChanged: (value) {
                          _filterMessages(value); // Call the filtering method
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: universalSearch,
                          prefixIcon: Image.asset(
                            'assets/icons/search.png',
                          ),
                          filled: true,
                          hintText: "Search",
                          hintStyle: TextStyle(color: universalBlackTertiary),
                        ),
                      ),
                    ),
                  ),
            if (listOrders.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      10.heightBox,
                      if (upcomingShootChats.isNotEmpty)
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Upcoming shoots",
                              style: TextStyle(color: universalBlackTertiary),
                            )),
                      if (upcomingShootChats.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 75),
                          child: Divider(),
                        ),
                      if (upcomingShootChats.isNotEmpty)
                        ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: upcomingShootChats.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              PhotographerOrder item =
                                  upcomingShootChats[index];
                              var chats = item.orderChats;
                              String chatUserName =
                                  item.customerUserId == user!.id
                                      ? item.photographerName!
                                      : item.customerName!;
                              return Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: InkWell(
                                    onTap: () {
                                      if (user!.profileTypeId ==
                                          PhotographerTypeId) {
                                        Get.to(() => PhotographersChatScreen(
                                                  orderId: item.id,
                                                ))
                                            ?.then((value) async =>
                                                await _loadOrders());
                                      } else {
                                        Get.to(() => UserChatScreen(
                                                  orderId: item.id,
                                                ))
                                            ?.then((value) async =>
                                                await _loadOrders());
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            user!.profileTypeId ==
                                                    PhotographerTypeId
                                                ? CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(item
                                                            .customerProfileImage!))
                                                : CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            item.photographerProfileImage!)),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 4,
                                                                right: 4),
                                                        child: (chatUserName
                                                                        .length >
                                                                    25
                                                                ? chatUserName
                                                                        .substring(
                                                                            0,
                                                                            25) +
                                                                    "..."
                                                                : chatUserName)
                                                            .text
                                                            .size(17)
                                                            .fontFamily(
                                                                milligramBold)
                                                            .make(),
                                                      ),
                                                      if (chats.count((e) =>
                                                              e.isUserMessage ==
                                                                  false &&
                                                              e.isRead ==
                                                                  false) >
                                                          0)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 0),
                                                          child: CircleAvatar(
                                                            radius: 8.0,
                                                            backgroundColor:
                                                                universalColorPrimaryDefault,
                                                            child: Text(
                                                              chats
                                                                  .count((e) =>
                                                                      e.isUserMessage ==
                                                                          false &&
                                                                      e.isRead ==
                                                                          false)
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      universalWhitePrimary),
                                                            ),
                                                          ),
                                                        ),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            left: (chatUserName
                                                                        .length >
                                                                    25
                                                                ? 0
                                                                : ((25 - chatUserName.length) /
                                                                        25) *
                                                                    (200 -
                                                                        (chats.count((e) => e.isUserMessage == false && e.isRead == false) >
                                                                                0
                                                                            ? 20
                                                                            : 0)))),
                                                        child: (formatDateTimeChat(item
                                                                .lastChatMessageDateTime!))
                                                            .text
                                                            .size(12)
                                                            .color(
                                                                universalTransblackSecondary)
                                                            .make(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: Icon(
                                                          Icons
                                                              .arrow_forward_ios_outlined,
                                                          size: 12,
                                                          color:
                                                              universalTransblackSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 280,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              top: 1,
                                                              right: 0.1),
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: "${item.shootTypeName}, ${item.shootSceneName}, ${formatDate(item.orderDateTime)}"
                                                              .text
                                                              .size(13)
                                                              .color(
                                                                  universalBlackPrimary)
                                                              .make()),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 280,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5,
                                                                  top: 1),
                                                          child: (item.lastChatMessage!
                                                                          .length >
                                                                      30
                                                                  ? "${item.lastChatMessage!.substring(0, 30)}..."
                                                                  : item
                                                                      .lastChatMessage!)
                                                              .text
                                                              .color(
                                                                  universalTransblackSecondary)
                                                              .fontFamily(chats.count((e) =>
                                                                          e.isUserMessage ==
                                                                              false &&
                                                                          e.isRead ==
                                                                              false) >
                                                                      0
                                                                  ? milligramBold
                                                                  : milligramRegular)
                                                              .make(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 75),
                                          child: Divider(),
                                        ),
                                      ],
                                    )),
                              );
                            }),
                      if (shootHistroyChats.isNotEmpty) 30.heightBox,
                      if (shootHistroyChats.isNotEmpty)
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Shoot history",
                              style: TextStyle(color: universalBlackTertiary),
                            )),
                      if (shootHistroyChats.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 75),
                          child: Divider(),
                        ),
                      if (shootHistroyChats.isNotEmpty)
                        ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: shootHistroyChats.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              PhotographerOrder item = shootHistroyChats[index];
                              var chats = item.orderChats;
                              String chatUserName =
                                  item.customerUserId == user!.id
                                      ? item.photographerName!
                                      : item.customerName!;
                              return Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: InkWell(
                                    onTap: () {
                                      if (user!.profileTypeId ==
                                          PhotographerTypeId && shootHistroyChats[index].orderDateTime.isBefore (new DateTime.now())) {
                                        Get.to(() => PhotographersChatScreen(
                                                  orderId: item.id,
                                                ))
                                            ?.then((value) async =>
                                                await _loadOrders());
                                      } else {
                                        Get.to(() => UserChatScreen(
                                                  orderId: item.id,
                                                ))
                                            ?.then((value) async =>
                                                await _loadOrders());
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            user!.profileTypeId ==
                                                    PhotographerTypeId
                                                ? CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(item
                                                            .customerProfileImage!))
                                                : CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            item.photographerProfileImage!)),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5,
                                                                right: 5),
                                                        child: (chatUserName
                                                                        .length >
                                                                    25
                                                                ? chatUserName
                                                                        .substring(
                                                                            0,
                                                                            25) +
                                                                    "..."
                                                                : chatUserName)
                                                            .text
                                                            .color(
                                                                universalBlackTertiary)
                                                            .size(17)
                                                            .fontFamily(
                                                                milligramBold)
                                                            .make(),
                                                      ),
                                                      if (chats.count((e) =>
                                                              e.isUserMessage ==
                                                                  false &&
                                                              e.isRead ==
                                                                  false) >
                                                          0)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 0),
                                                          child: CircleAvatar(
                                                            radius: 8.0,
                                                            backgroundColor:
                                                                universalColorPrimaryDefault,
                                                            child: Text(
                                                              chats
                                                                  .count((e) =>
                                                                      e.isUserMessage ==
                                                                          false &&
                                                                      e.isRead ==
                                                                          false)
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                height: 1,
                                                                  fontSize: 12,
                                                                  color:
                                                                      universalWhitePrimary),
                                                            ),
                                                          ),
                                                        ),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            left: (chatUserName
                                                                        .length >
                                                                    25
                                                                ? 0
                                                                : ((25 - chatUserName.length) /
                                                                        25) *
                                                                    (200 -
                                                                        (chats.count((e) => e.isUserMessage == false && e.isRead == false) >
                                                                                0
                                                                            ? 20
                                                                            : 0)))),
                                                        child: (formatDateTimeChat(item
                                                                .lastChatMessageDateTime!))
                                                            .text
                                                            .size(12)
                                                            .color(
                                                                universalTransblackTertiary)
                                                            .make(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: Icon(
                                                          Icons
                                                              .arrow_forward_ios_outlined,
                                                          size: 12,
                                                          color:
                                                              universalTransblackSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5,
                                                            top: 1,
                                                            right: 0.1),
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: "${item.shootTypeName}, ${item.shootSceneName}, ${formatDate(item.orderDateTime)}"
                                                            .text
                                                            .size(13)
                                                            .color(
                                                                universalBlackTertiary)
                                                            .make()),
                                                  ),
                                                  SizedBox(
                                                    width: 280,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5,
                                                                  top: 1),
                                                          child: (item.lastChatMessage!
                                                                          .length >
                                                                      30
                                                                  ? "${item.lastChatMessage!.substring(0, 30)}..."
                                                                  : item
                                                                      .lastChatMessage!)
                                                              .text
                                                              .color(
                                                                  universalTransblackSecondary)
                                                              .fontFamily(chats.count((e) =>
                                                                          e.isUserMessage ==
                                                                              false &&
                                                                          e.isRead ==
                                                                              false) >
                                                                      0
                                                                  ? milligramBold
                                                                  : milligramRegular)
                                                              .make(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 75),
                                          child: Divider(),
                                        ),
                                      ],
                                    )),
                              );
                            }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
