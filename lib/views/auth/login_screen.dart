import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:swarm/consts/consts.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/views/auth/signup_screen.dart';
import 'package:swarm/views/common/username_field.dart';

import '../../consts/api.dart';
import '../../services/token_service.dart';
import '../../storage/registration_storage.dart';
import '../../storage/token_storage.dart';
import '../../utils/toast_utils.dart';
import '../photographer/home_photographer.dart';
import '../registration/profile_type_screen/profile_type_screen.dart';
import '../user/bottom_tab_screen_users/home_user.dart';
import '../common/our_button.dart';
import '../common/password_textfield.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:local_auth/local_auth.dart';

import 'forget_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _auth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    final isAvailable = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }
  String get biometric => Platform.isIOS ? "Face ID" : "Biometric Login";
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
  dynamic get biometricIconButton => Platform.isIOS
      ? CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: AssetImage("assets/icons/facialIcon.png"),
        )
      : Icon(Icons.fingerprint);
  Future<bool> authenticate() async {
    final isAuthAvailable = await hasBiometrics();
    final isAvailable = await _auth.canCheckBiometrics;
    List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    if (!isAvailable) {
      ToastHelper.showSuccessToast(
          context,
          biometricIcon,
          biometric,
          "Your device does not support ${biometric} Please use your username and password to log in.",
          "Ok", () {
        Navigator.of(context).pop();
      });
      return false;
    } else if (availableBiometrics.isEmpty) {
      ToastHelper.showSuccessToast(
          context,
          biometricIcon,
          biometric,
          "You have not set up ${biometric} on your device. Please set it up in your device settings to use it for logging in.",
          "Set Up Now", () {
        Navigator.of(context).pop();
        openDeviceSettings();
      });
      return false;
    }
    if (!isAuthAvailable) return false;
    var isBiometricEnable = await TokenStorage.isBiometricEnable;
    if (isBiometricEnable == "no") {
      ToastHelper.showSuccessToast(
          context,
          biometricIcon,
          biometric,
          "You first need to log in using your username and password to set up ${biometric}",
          "Ok", () {
        Navigator.of(context).pop();
      });
      return false;
    }
    bool authenticated = false;
    try {
      authenticated = await _auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face) to verfiy your identity',
          options: const AuthenticationOptions(
            biometricOnly: true,
            useErrorDialogs: true,
            stickyAuth: true,
          ));
      if (authenticated) {
        var credential = (await TokenStorage.getCredential).split(":");
        _loginButtonPressed(credential[0], credential[1], true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void openDeviceSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.security);
  }

  void _loginButtonPressed(
      String email, String password, bool fromBiometric) async {
    await RegistrationStorage.removeValue();
    await UserProfileStorage.removeValue();

    if (!fromBiometric && _formKey.currentState!.validate() == false) {
      return;
    }
    TextInput.finishAutofillContext();
    // Call the TokenRequest to get the JWT token
    final tokenRequest = TokenService();
    final tokenResponse =
        await tokenRequest.getJwtToken(context, email, password);

    if (tokenResponse != null && tokenResponse is String) {
      ToastHelper.showErrorToast(context, tokenResponse);
    } else if (tokenResponse != null) {
      await TokenStorage.setJwtToken(jsonEncode(tokenResponse));
      var isBiometricEnable = await TokenStorage.isBiometricEnable;
      if (isBiometricEnable == "no") {
        await TokenStorage.setCredential(email, password);
      }
      if (tokenResponse["profilesCompleted"] as bool) {
        await TokenStorage.fromLogin("yes");
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

  Future<void> _checkBiometricAuth() async {
    var isBiometricEnable = await TokenStorage.isBiometricEnable;
    if (isBiometricEnable == "yes") {
      await authenticate();
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _checkBiometricAuth();
    });
  }

  @override
  void dispose() {
    Loader.hide();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: universalWhitePrimary,
      body: Center(
        child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                children: [
                  (context.screenHeight * 0.2).heightBox,
                  Align(
                      alignment: Alignment.centerLeft,
                      child: login.text
                          .fontFamily(milligramBold)
                          .black
                          .size(40)
                          .make()),
                  15.heightBox,
                  usernameFiled(
                      hint: email,
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      isRequired: true,
                      isEmail: true,
                      fromLogin: true),
                  PasswordField(
                    hint: password,
                    controller: _passwordController,
                    isPatternValidate: false,
                    focusNode: _passwordFocusNode,
                  ),
                  Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                          onPressed: () {
                            Get.to(() => const ForgetPasswordScreen());
                          },
                          child: forgetPass.text.black
                              .fontFamily(milligramBold)
                              .size(16)
                              .make())),
                  15.heightBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly, // Adjusts buttons within the row
                    children: <Widget>[
                      ourButton(
                              onPress: () => _loginButtonPressed(
                                  _emailController.text,
                                  _passwordController.text,
                                  false),
                              color: universalColorPrimaryDefault,
                              textColor: universalBlackPrimary,
                              title: login)
                          .box
                          .width(context.screenWidth - 140)
                          .height(50)
                          .make(),
                      IconButton(
                        icon: biometricIconButton, // Biometric icon
                        onPressed: authenticate,
                        iconSize: 40,
                        color: universalColorPrimaryDefault,
                      ),
                    ],
                  ),
                  20.heightBox,
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                            text: createNewAccount,
                            style: TextStyle(
                                fontFamily: milligramSemiBold,
                                color: universalBlackSecondary,
                                fontSize: 17)),
                        TextSpan(
                            text: signup,
                            style: TextStyle(
                                fontFamily: milligramBold,
                                color: universalBlackPrimary,
                                fontSize: 17))
                      ],
                    ),
                  ).onTap(() {
                    Get.offAll(() => const SignUpScreen());
                  }),
                ],
              )
                  .box
                  .white
                  .rounded
                  .padding(const EdgeInsets.only(left: 40, right: 40))
                  .shadowSm
                  .make(),
            )),
      ),
    );
  }
}
