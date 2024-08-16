import 'dart:async';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/storage/registration_storage.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/views/splash/splash_screen_login.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';
import 'package:swarm/views/common/applogo_widgets.dart';
import 'package:video_player/video_player.dart';

import '../../consts/api.dart';
import '../../services/payment_service.dart';
import '../../storage/token_storage.dart';
import '../../utils/connectivity.dart';
import '../photographer/home_photographer.dart';
import '../registration/profile_type_screen/profile_type_screen.dart';
import '../common/appname_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  changeScreen() async {
    await RegistrationStorage.removeValue();
    await UserProfileStorage.removeValue();

    Future.delayed(const Duration(seconds: 2), () async {
      var isConnected = await checkInternetConnection(context);
      if (isConnected) {
        var key = await PaymentService().getPublishableKey();
        if (key != null) {
          Stripe.publishableKey = key;
          Stripe.merchantIdentifier = 'Swarm App';
          await Stripe.instance.applySettings();
        }
      }
      var token = await TokenStorage.getToken;
      if (token != null && isConnected) {
        if (token.profilesCompleted == false) {
          Get.offAll(() => const ProfileType());
          return;
        } else {
          if (token.profileType == PhotographerType) {
            Get.offAll(() => const HomePhotoGrapherScreen());
            return;
          } else {
            Get.offAll(() => HomeUserScreen());
            return;
          }
        }
      }
      Get.offAll(() => const SplashScreenLogin());
    });
  }

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.asset('assets/images/splash_video.mov')
          ..initialize().then((_) {
            _videoController.play();
            _videoController.setLooping(true);
          });
    Future.delayed(Duration.zero, () {
      changeScreen();
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          bgVedioWidget(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Your logo widget
                applogoWidget(),
                const SizedBox(height: 16), // Adjust spacing as needed
                // Your app name widget
                appnameWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bgVedioWidget({Widget? child}) {
    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: context.screenWidth,
        height: context
            .screenHeight, // Aspect ratio will be maintained automatically
        child: VideoPlayer(_videoController),
      ),
    );
  }
}
