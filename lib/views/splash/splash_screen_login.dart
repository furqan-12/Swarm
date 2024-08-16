import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:swarm/consts/api.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/token_service.dart';
import 'package:swarm/storage/registration_storage.dart';
import 'package:swarm/storage/token_storage.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/photographer/home_photographer.dart';
import 'package:swarm/views/registration/profile_type_screen/profile_type_screen.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';

import '../auth/login_screen.dart';
import '../common/applogo_widgets.dart';
import '../common/appname_widgets.dart';
import '../common/bg_widget.dart';

class SplashScreenLogin extends StatefulWidget {
  const SplashScreenLogin({super.key});

  @override
  State<SplashScreenLogin> createState() => _SplashScreenLoginState();
}

class _SplashScreenLoginState extends State<SplashScreenLogin> {
  void _loginButtonPressed(String authCode) async {
    await RegistrationStorage.removeValue();
    await UserProfileStorage.removeValue();

    // Call the TokenRequest to get the JWT token
    final tokenRequest = TokenService();
    final tokenResponse =
        await tokenRequest.getJwtTokenAppleIds(context, authCode);

    if (tokenResponse != null && tokenResponse is String) {
      ToastHelper.showErrorToast(context, unknownError);
    } else if (tokenResponse != null) {
      await TokenStorage.setJwtToken(jsonEncode(tokenResponse));
      if (tokenResponse["profilesCompleted"] as bool) {
        if (tokenResponse["profileType"] as String == PhotographerType) {
          Get.offAll(() => const HomePhotoGrapherScreen());
        } else {
          Get.offAll(() => HomeUserScreen());
        }
      } else {
        Get.offAll(() => const ProfileType());
      }
    } else {
      ToastHelper.showErrorToast(context, unknownError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  (context.screenHeight * 0.28).heightBox,
                  applogoWidget(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      appnameWidget(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text(
                          "TM",
                          style: TextStyle(
                              color: universalWhitePrimary, fontSize: 17),
                        ),
                      )
                    ],
                  ),
                  10.heightBox,
                  "Anywhere, anytime photoshoots"
                      .text
                      .size(22)
                      .fontFamily(milligramSemiBold)
                      .white
                      .make(),
                  50.heightBox,
                ],
              ),
            ),
            if (Platform.isIOS)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.apple,
                            color: universalWhitePrimary,
                            size: 32,
                          )),
                      "    Sign in with Apple"
                          .text
                          .size(17)
                          .fontFamily(milligramBold)
                          .white
                          .make(),
                    ],
                  ),
                ],
              )
                  .box
                  .roundedLg
                  .width(320)
                  .padding(const EdgeInsets.only(left: 25, right: 25))
                  .color(black)
                  .border(color: Vx.white, width: 1.0, style: BorderStyle.solid)
                  .make()
                  .onTap(() async {
                try {
                  final credential = await SignInWithApple.getAppleIDCredential(
                    scopes: [
                      AppleIDAuthorizationScopes.email,
                      AppleIDAuthorizationScopes.fullName,
                    ],
                  );
                  _loginButtonPressed(credential.identityToken!);
                  print(credential);
                } catch (e) {}
              }),
            (10).heightBox,
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.email,
                          color: universalWhitePrimary,
                          size: 32,
                        )),
                    "    Continue with Email"
                        .text
                        .size(17)
                        .fontFamily(milligramBold)
                        .white
                        .make(),
                  ],
                )
              ],
            )
                .box
                .roundedLg
                .width(320)
                .padding(const EdgeInsets.only(left: 25, right: 25))
                .color(universalBlackTertiary.withOpacity(0.5))
                .border(color: Vx.white, width: 1.0, style: BorderStyle.solid)
                .make()
                .onTap(() {
              Get.to(() => const LoginScreen());
            }),
            (context.screenHeight * 0.12).heightBox,
          ],
        ),
      ),
    ));
  }
}
