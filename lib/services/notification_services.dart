import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/storage/key_value_storage.dart';
import 'package:swarm/views/photographer/chat_screen/photograpers_chat_screen.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/gratuity_photographer/order_review_screen.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';
import 'package:swarm/views/user/chat_screen/user_chat_screen.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  requestNotficationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitializationSettings = DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload) =>
          {handleMessage(context, message)},
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title);
        print(message.notification!.body);
      }

      if (Platform.isIOS) {
        forGroudMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        "High Importance Notifiction",
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: "Description",
            importance: Importance.high,
            priority: Priority.high,
            ticker: "ticker");

    DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSNotificationDetails);

    Future.delayed(
        Duration.zero,
        () => {
              _flutterLocalNotificationsPlugin.show(
                  0,
                  message.notification!.title,
                  message.notification!.body,
                  notificationDetails)
            });
  }

  Future<String?> getDeviceToken() async {
    return await messaging.getToken();
    //call api to save this token
  }

  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      //call api to save this token
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == "order-user") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => UserChatScreen(
                  orderId: message.data['orderid'].toString()))));
    } else if (message.data['type'] == "order-photographer") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => PhotographersChatScreen(
                  orderId: message.data['orderid'].toString()))));
    } else if (message.data['type'] == "pay-order") {
      KeyValueStorage.getValue(
              message.data['orderid'].toString() + "WelcomeScreen")
          .then((value) {
        if (value.isEmptyOrNull) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => HomeUserScreen(
                      orderId: message.data['orderid'].toString()))));
          KeyValueStorage.setValue(
              message.data['orderid'].toString() + "WelcomeScreen", "true");
        }
      });
    } else if (message.data['type'] == "order-review") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => OrderReviewScreen(
                  orderId: message.data['orderid'].toString()))));
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // when app is terminated
    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    // when app is in backgroud
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  Future forGroudMessage() async {
    await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
  }
}
