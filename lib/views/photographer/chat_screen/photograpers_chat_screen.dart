import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/controller/home_controller.dart';
import 'package:swarm/services/response/photographer_order.dart';

import '../../../consts/api.dart';
import '../../../services/order_service.dart';
import '../../../services/response/user.dart';
import '../../../storage/token_storage.dart';
import '../../../storage/user_profile_storage.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';
import '../../user/chat_screen/sender_bubble.dart';

class PhotographersChatScreen extends StatefulWidget {
  final String orderId;

  const PhotographersChatScreen({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<PhotographersChatScreen> createState() =>
      _PhotographersChatScreenState();
}

class _PhotographersChatScreenState extends State<PhotographersChatScreen> {
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

      if (orderId == widget.orderId && toUserId == user!.id && type == "0") {
        setState(() {
          orderChats.add(OrderChat(
            id: null,
            orderId: widget.orderId,
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
    //   if (order != null && order!.customerUserId == userId) {
    //     order!.isOnline = isOnline;
    //   }
    // }
  }

  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<OrderChat> orderChats = [];
  List<String> chatTimes = [];
  UserProfile? user = null;
  PhotographerOrder? order = null;
  bool _isSending = false;
  var controller = HomeController.instance;

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
      //     await userProfileService.getIsOnline(_order.customerUserId);

      setState(() {
        order = _order;
      });
    }

    final chats =
        await orderService.getOrderChats(context, widget.orderId, user!.id);
    if (chats == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }
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

  // Scroll to the bottom after sending a message
  void scrollBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmptyOrNull) {
      return;
    }
    final orderService = OrderService();
    final chat = await orderService.sendMessage(
        context, widget.orderId, message, user!.id);
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
              padding: const EdgeInsets.only(left: 18),
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
                order == null || order!.customerProfileImage.isEmptyOrNull
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: universalWhitePrimary,
                        backgroundImage: AssetImage(
                          "assets/icons/cameraicon.png",
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: universalWhitePrimary,
                          backgroundImage: CachedNetworkImageProvider(
                            order!.customerProfileImage!,
                          ),
                        ),
                      ),
                "${order == null ? "" : order?.customerName!}"
                    .text
                    .size(20)
                    .fontFamily(milligramBold)
                    .make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    "${order == null ? "" : order!.shootTypeName},"
                        .text
                        .size(10)
                        .color(universalBlackPrimary)
                        .fontFamily(milligramRegular)
                        .make(),
                    2.widthBox,
                    "${order == null ? "" : order!.shootSceneName},"
                        .text
                        .size(10)
                        .color(universalBlackPrimary)
                        .fontFamily(milligramRegular)
                        .make(),
                    2.widthBox,
                    "${order == null ? "" : formatDate(order!.orderDateTime)}"
                        .text
                        .size(10)
                        .color(universalBlackPrimary)
                        .fontFamily(regular)
                        .make(),
                  ],
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
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
                          null,
                          orderChats.length - 1 == index,
                          showTime
                              ? time
                              : null // Pass the time only if showTime is true
                          );
                },
              ),
            ),
            Row(children: [
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
            ])
                .box
                .padding(const EdgeInsets.all(5))
                .border(
                  width: 1.0,
                  color: universalBlackTertiary,
                )
                .roundedLg
                .padding(const EdgeInsets.only(left: 5, right: 5))
                .margin(const EdgeInsets.only(
                    top: 12, bottom: 30, left: 12, right: 12))
                .make(),
          ],
        ));
  }
}
