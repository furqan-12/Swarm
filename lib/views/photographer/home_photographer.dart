import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:swarm/consts/api.dart';
import 'package:swarm/storage/token_storage.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/controller/home_controller.dart';
import 'package:swarm/services/order_service.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/photographer/stats_screen/photographer_stats.dart';
import 'package:swarm/views/photographer/upcoming_shoots_screen/upcoming_shoots_screen.dart';

import '../../services/notification_services.dart';
import '../../services/user_profile_service.dart';
import '../registration/my_days_hours/my_days_and_hours.dart';
import '../user/chat_screen/chat_screen.dart';
import '../user_profile/user_profile_screen.dart';

class HomePhotoGrapherScreen extends StatefulWidget {
  const HomePhotoGrapherScreen({super.key});

  @override
  State<HomePhotoGrapherScreen> createState() => _HomePhotoGrapherScreenState();
}

class _HomePhotoGrapherScreenState extends State<HomePhotoGrapherScreen>
    with WidgetsBindingObserver {
  List<bool> notificationDots = [false, false, false, false, false];
  NotificationService notificationService = NotificationService();
  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  bool isOnline = false; // Track online status locally
  var controller = HomeController.instance;
  HubConnection? _hubConnection;
  final _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    notificationService.requestNotficationPermission();
    notificationService.forGroudMessage();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    notificationService.isTokenRefresh();
    notificationService.getDeviceToken().then((token) {
      if (token != null) {
        UserProfileService().sendDeviceToken(token).then((value) => {});
      }
    });
    WidgetsBinding.instance.addObserver(this);
    listenConnectivityChanges();
    openChatConnection();
  }

  String get biometric => Platform.isIOS ? "Face ID" : "Biometric Login";
  String get biometricDetail => Platform.isIOS ? "Face ID" : "Touch ID";

  dynamic get biometricIcon => Platform.isIOS
      ? CircleAvatar(
          backgroundColor: Colors.white,
          radius: 40,
          backgroundImage: AssetImage("assets/icons/facialIcon.png"),
        )
      : Icon(Icons.fingerprint, color: universalWhitePrimary, size: 40)
          .box
          .roundedFull
          .padding(EdgeInsets.all(7))
          .color(universalColorPrimaryDefault)
          .make();

  void openDeviceSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.security)
        .then((value) => () async {
              var availableBiometrics = await _auth.getAvailableBiometrics();
              final isAvailable = await _auth.canCheckBiometrics;
              if (isAvailable && availableBiometrics.isNotEmpty) {
                ToastHelper.showSuccessToast(
                    context,
                    biometricIcon,
                    biometric,
                    "Enable ${biometricDetail} to quickly and securely access your account without needing to type your password each time.",
                    "Enable", () {
                  Navigator.of(context).pop();
                  TokenStorage.enableBiometric();
                });
              }
            });
  }

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
    final String toUserId = json["toUserId"]!;
    final user = await UserProfileStorage.getUserProfileModel;
    if (toUserId == user!.id && type == "0") {
      controller.unReadCount.value = await OrderService().unreadCount();
    }
  }

  Future<void> listenConnectivityChanges() async {
    final Connectivity connectivity = Connectivity();

    connectivitySubscription = connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      final bool newIsOnline = result != ConnectivityResult.none;
      if (newIsOnline != isOnline) {
        isOnline = newIsOnline;
        await UserProfileService().setIsOnline(isOnline);
      }
    });

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      controller.currentNavIndex.value = 2;
    });

    OrderService().unreadCount().then((value) => () {
          controller.unReadCount.value = value;
        });
    final userProfileService = UserProfileService();
    final userProfile = await userProfileService.getUserProfile(
      context,
    );

    var isBiometricEnable = await TokenStorage.isBiometricEnable;
    var fromLogin = await TokenStorage.getFromLogin;
    if (isBiometricEnable == "no" && fromLogin == "yes") {
      TokenStorage.fromLogin("no");
      final isAvailable = await _auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        ToastHelper.showSuccessToast(
            context,
            biometricIcon,
            biometric,
            "You have not set up ${biometric} on your device. Please set it up in your device settings to use it for logging in.",
            "Set Up Now", () {
          Navigator.of(context).pop();
          openDeviceSettings();
        });
      }
      if (isAvailable && availableBiometrics.isNotEmpty) {
        ToastHelper.showSuccessToast(
            context,
            biometricIcon,
            biometric,
            "Enable ${biometricDetail} to quickly and securely access your account without needing to type your password each time.",
            "Enable", () {
          Navigator.of(context).pop();
          TokenStorage.enableBiometric();
        });
      }
    }

    final orderService = OrderService();
    final orders =
        await orderService.getPhotographerOrders(context, userProfile!.id);
    if (orders != null) {
      controller.newOrders.value =
          orders.where((e) => e.timeLineType == 2).length;
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final bool newIsOnline = state == AppLifecycleState.resumed;
    if (newIsOnline != isOnline) {
      isOnline = newIsOnline;
      await UserProfileService().setIsOnline(isOnline);
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return (await showGeneralDialog<bool>(
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
            backgroundColor: universalWhitePrimary,
            surfaceTintColor: universalWhitePrimary,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      "Are you sure?",
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: milligramBold,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          'Do you want to leave the application?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontFamily: milligramRegular),
                        )),
                    SizedBox(height: 8),
                  ],
                ),
                SizedBox(width: 350, child: Divider()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Text(
                        "No",
                        style: TextStyle(
                          fontFamily: milligramBold,
                          fontSize: 22,
                          color: universalColorPrimaryDefault,
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      child: VerticalDivider(),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          fontFamily: milligramBold,
                          fontSize: 22,
                          color:
                              universalColorPrimaryDefault, // Optional: Different color for emphasis
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black45,
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 300),
        )) ??
        false; // Clicking outside the dialog returns null which is handled by ?? false
  }

  @override
  Widget build(BuildContext context) {
    //init home controller

    var navbarItem = [
      BottomNavigationBarItem(
          icon: Obx(() => controller.currentNavIndex.value == 0
              ? new Image.asset('assets/icons/stats-active.png',
                  height: 30, width: 30)
              : new Image.asset('assets/icons/stats.png',
                  height: 30, width: 30)),
          label: ""),
      BottomNavigationBarItem(
          icon: Obx(() => controller.currentNavIndex.value == 1
              ? new Image.asset('assets/icons/schedule-active.png',
                  height: 30, width: 30)
              : new Image.asset('assets/icons/schedule.png',
                  height: 30, width: 30)),
          label: ""),
      BottomNavigationBarItem(
          icon: Obx(
            () => Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: controller.currentNavIndex.value == 2
                      ? new Image.asset('assets/icons/home-active.png',
                          height: 30, width: 30)
                      : new Image.asset('assets/icons/home.png',
                          height: 30, width: 30),
                ),
                if (controller.newOrders.value > 0)
                  Positioned(
                      top: 0,
                      right: 0,
                      child: Text(
                        "${controller.newOrders}",
                        style: TextStyle(
                            fontSize: 10, color: universalWhitePrimary),
                      )
                          .box
                          .roundedFull
                          .color(specialError)
                          .padding(EdgeInsets.all(5))
                          .make()),
              ],
            ),
          ),
          label: ""),
      BottomNavigationBarItem(
          icon: Obx(
            () => Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: controller.currentNavIndex.value == 3
                      ? new Image.asset('assets/icons/chat-active.png',
                          height: 30, width: 30)
                      : new Image.asset('assets/icons/chat.png',
                          height: 30, width: 30),
                ),
                if (controller.unReadCount.value > 0)
                  Positioned(
                      top: 0,
                      right: 0,
                      child: Text(
                        "${controller.unReadCount}",
                        style: TextStyle(
                            fontSize: 10, color: universalWhitePrimary),
                      )
                          .box
                          .roundedFull
                          .color(specialError)
                          .padding(EdgeInsets.all(5))
                          .make()),
              ],
            ),
          ),
          label: ""),
      BottomNavigationBarItem(
          icon: Obx(() => controller.currentNavIndex.value == 4
              ? new Image.asset('assets/icons/person-active.png',
                  height: 30, width: 30)
              : new Image.asset('assets/icons/person.png',
                  height: 30, width: 30)),
          label: ""),
    ];
    var navBody = [
      PhotographerStats(),
      const MyDaysAndHours(fromHome: true),
      UpcomingShootsScreen(),
      ChatScreen(),
      const UserProfileScreen()
    ];

    return WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          body: Column(
            children: [
              Obx(() => Expanded(
                    child: navBody.elementAt(controller.currentNavIndex.value),
                  )),
            ],
          ),
          bottomNavigationBar: Obx(
            () => BottomNavigationBar(
              currentIndex: controller.currentNavIndex.value,
              type: BottomNavigationBarType.fixed,

              backgroundColor: universalWhitePrimary,
              selectedItemColor: universalColorPrimaryDefault,
              unselectedItemColor: universalBlackPrimary,
              selectedFontSize: 0, // Set to 0 to hide labels
              unselectedFontSize: 0, // Set to 0 to hide labels
              iconSize: 15,
              items: navbarItem,
              onTap: (value) {
                controller.currentNavIndex.value = value;
              },
            ),
          ),
        ));
  }
}
