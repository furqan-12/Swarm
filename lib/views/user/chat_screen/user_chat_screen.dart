import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/controller/home_controller.dart';

import 'package:swarm/storage/token_storage.dart';
import 'package:swarm/views/user/chat_screen/sender_bubble.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../consts/api.dart';
import '../../../services/order_service.dart';
import '../../../services/response/photographer_order.dart';
import '../../../services/response/user.dart';
import '../../../storage/user_profile_storage.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';
import 'package:signalr_netcore/signalr_client.dart';

class UserChatScreen extends StatefulWidget {
  final String orderId;

  const UserChatScreen({super.key, required this.orderId});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  HubConnection? _hubConnection;
  bool _isSending = false;

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

  void _handleIncommingChatMessage(List<Object?>? args) {
    if (args == null) {
      return;
    }

    if (args[0].toString() == "Swarm.Shared.Notifications.OrderNotification") {
      var json = args[1] as Map<String, dynamic>;
      final String type = json["type"]!.toString();
      final String fromUserId = json["fromUserId"]!;
      final String toUserId = json["toUserId"]!;
      final String message = json["message"]!;
      final String? heading = json["heading"];
      final String orderId = json["orderId"]!;
      final String dateTime = json["dateTime"]!;
      final String? imagePath = json["imagePath"];
      final String? imageText = json["imageText"];
      final String? navigation = json["navigation"];
      final String? navigationText = json["navigationText"];
      final String fromSystem = json["fromSystem"]!.toString();
      if (orderId == order!.id && toUserId == user!.id && type == "0") {
        setState(() {
          orderChats.add(OrderChat(
            id: null,
            orderId: order!.id,
            fromUserId: fromUserId,
            toUserId: toUserId,
            heading: heading,
            message: message,
            dateTime: DateTime.parse(dateTime),
            imagePath: imagePath,
            imageText: imageText,
            navigation: navigation,
            navigationText: navigationText,
            isRead: true,
            fromSystem:
                bool.tryParse(fromSystem, caseSensitive: false) ?? false,
            isUserMessage: fromUserId == user!.id,
          ));

          Future.delayed(Duration(seconds: 1), () {
            scrollBottom();
          });
        });
      }
    }
    // if (args[0].toString() ==
    //     "Swarm.Shared.Notifications.IsOnlineNotification") {
    //   var json = args[1] as Map<String, String>;
    //   final String userId = json["userId"]!;
    //   final bool isOnline =
    //       bool.tryParse(json["isOnline"]!, caseSensitive: false) ?? false;
    //   if (order != null && order!.photographerUserId == userId) {
    //     order!.isOnline = isOnline;
    //   }
    // }
  }

  final _controller = Completer<GoogleMapController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  List<OrderChat> orderChats = [];
  List<String> chatTimes = [];
  UserProfile? user = null;
  PhotographerOrder? order = null;
  var controller = HomeController.instance;

  void _onMapCreated(GoogleMapController controller) async {
    _controller;
  }

  void openGoogleMapsApp(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    Uri googleUri = Uri.parse(googleUrl);

    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri);
    } else {
      ToastHelper.showErrorToast(context, 'Could not launch Google Maps app');
    }
  }

  void _slider() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: universalWhitePrimary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return Stack(children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          "assets/icons/downarrow.png",
                          width: 32,
                        ).onTap(() {
                          Navigator.pop(context);
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Align(
                          alignment: Alignment.center,
                          child:
                              "${order!.shootTypeName}, ${order!.shootSceneName}, ${order?.shootLengthName}, ${formatDate(order!.orderDateTime)}"
                                  .text
                                  .fontFamily(milligramRegular)
                                  .color(universalColorPrimaryDefault)
                                  .size(17)
                                  .make()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 15, left: 95, right: 95),
                      child: Align(
                          alignment: Alignment.center,
                          child: order?.shortAddress.text.center
                              .color(universalBlackPrimary)
                              .size(17)
                              .make()),
                    ),
                    SizedBox(
                      height: 400,
                      width: context.screenWidth,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(order!.latitude, order!.longitude),
                          zoom: 17.0,
                        ),
                      ),
                    ),
                    20.heightBox,
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: universalColorPrimaryDefault,
                          fixedSize: Size.fromWidth(context.screenWidth * 0.9),
                          maximumSize:
                              Size.fromHeight(context.screenWidth * 0.12),
                          padding: const EdgeInsets.all(12),
                          shadowColor: null,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        openGoogleMapsApp(order!.latitude, order!.longitude);
                      },
                      child: "Open maps"
                          .text
                          .color(universalBlackPrimary)
                          .fontFamily(milligramSemiBold)
                          .fontWeight(FontWeight.w700)
                          .size(17)
                          .letterSpacing(1)
                          .make(),
                    ).box.roundedSM.make()
                  ],
                ),
                Positioned(
                  // Place the marker at the center of the map
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Center(
                    child: Image.asset(
                      "assets/icons/marker.png",
                      width: 120,
                    ),
                  ),
                ),
              ]);
            }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadOrderChats();
    });
  }

  @override
  void dispose() {
    _hubConnection?.stop();
    super.dispose();
  }

  Future<void> _loadOrderChats() async {
    user = (await UserProfileStorage.getUserProfileModel)!;
    final orderService = OrderService();
    final _order =
        await orderService.getOrder(context, widget.orderId, user!.id);
    if (_order == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
      // var userProfileService = UserProfileService();
      // _order.isOnline =
      //     await userProfileService.getIsOnline(_order.photographerUserId);
      setState(() {
        order = _order;
      });
    }

    final chats =
        await orderService.getOrderChats(context, widget.orderId, user!.id);
    if (chats == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    } else {
       var count = await OrderService().unreadCount();
    controller.unReadCount.value = count;
      setState(() {
        orderChats = chats;
        Future.delayed(Duration(seconds: 1), () {
          scrollBottom();
        });
      });
      await openChatConnection();
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmptyOrNull) {
      return;
    }
    final orderService = OrderService();
    final chat =
        await orderService.sendMessage(context, order!.id, message, user!.id);
    if (chat != null) {
      setState(() {
        orderChats.add(chat);
        Future.delayed(Duration(seconds: 1), () {
          scrollBottom();
        });
      });

      _textEditingController.clear();
    }
  }

  // Scroll to the bottom after sending a message
  void scrollBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      appBar: AppBar(
        backgroundColor: universalWhitePrimary,
        surfaceTintColor: universalWhitePrimary,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          child: Image.asset("assets/icons/arrow.png").onTap(() {
            Navigator.pop(context);
          }),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Align(
              alignment: Alignment.centerLeft,
              child:
                  "Chat".text.fontFamily(milligramBold).black.size(40).make(),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (order != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(
                      order!.photographerProfileImage!,
                    ),
                  ),
                ),
              (order == null ? "" : order?.photographerName!)!
                  .text
                  .size(17)
                  .fontFamily(milligramBold)
                  .make(),
              (order == null
                      ? ""
                      : "${order!.shootTypeName}, ${order!.shootSceneName}, ${formatDate(order!.orderDateTime)}")
                  .text
                  .size(16)
                  .fontFamily(milligramRegular)
                  .make(),
            ],
          ).onTap(() {
            _slider();
          }),
          10.heightBox,
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: orderChats.length,
              itemBuilder: (BuildContext context, int index) {
                // Format the current chat's date and time
                var time = formatDateTimeString(orderChats[index].dateTime);
                // Determine whether to show the time.
                // Show it only if it's the first message or if the time is different from the previous message's time.
                bool showTime = index == 0 ||
                    time !=
                        formatDateTimeString(orderChats[index - 1].dateTime);
                // Build the chat message widget accordingly
                return order == null
                    ? null
                    : buildChatMessage(
                        orderChats[index],
                        order!,
                        _slider,
                        null,
                        showTime
                            ? time
                            : null // Pass the time only if showTime is true
                        );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.send,
                      color: universalColorPrimaryDefault,
                    ),
                    border: InputBorder.none,
                    hintText: "Message"),
              )),
              IconButton(
                  onPressed: () async {
                    if (_isSending == true) {
                      return;
                    }
                    setState(() {
                      _isSending = true;
                    });
                    await _sendMessage(_textEditingController.text);
                    setState(() {
                      _isSending = false;
                    });
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.circleArrowUp,
                    color: universalColorPrimaryDefault,
                    size: 30,
                  )),
            ],
          )
              .box
              .border(
                width: 1.0,
                color: universalBlackLine,
              )
              .roundedLg
              .padding(const EdgeInsets.only(left: 5, right: 0))
              .margin(const EdgeInsets.only(
                  top: 12, bottom: 30, left: 12, right: 12))
              .make(),
        ],
      ),
    );
  }
}
