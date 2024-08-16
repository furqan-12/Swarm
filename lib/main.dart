import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swarm/consts/colors.dart';

import 'package:swarm/consts/styles.dart';
import 'package:swarm/services/response/photographer_order.dart';

import 'package:swarm/storage/registration_storage.dart';
import 'package:swarm/storage/token_storage.dart';
import 'package:swarm/storage/user_profile_storage.dart';

import 'package:swarm/views/registration/thanks_you_screen/thanks_you_screen.dart';

import 'package:swarm/views/splash/splash_screen.dart';


import 'consts/strings.dart';
import 'package:uni_links/uni_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _linkSubscription;
  

  _MyAppState() {}

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Attach a listener to the Uri links stream
    _linkSubscription = uriLinkStream.listen((Uri? uri) async {
      if (!mounted) return;
      final registration = await RegistrationStorage.getRegistrationModel;
      if (registration != null) {
        await TokenStorage.removeJwtToken();
        await RegistrationStorage.removeValue();
        await UserProfileStorage.removeValue();
        Get.offAll(() => ThankYouScreen(
              imageUrl: registration.profileImageUrl!,
              name: registration.userName!,
            ));
      }
      setState(() {});
    }, onError: (Object err) {
      print('Got error $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    final PhotographerOrder order;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appname,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: universalWhitePrimary),
              elevation: 0.0,
              backgroundColor: Colors.transparent),
          fontFamily: regular),
      home: const SplashScreen(),
    );
  }
}
