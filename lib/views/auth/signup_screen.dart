import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/storage/user_profile_storage.dart';

import 'package:swarm/views/common/username_field.dart';
import 'package:swarm/views/registration/profile_type_screen/profile_type_screen.dart';
import 'package:swarm/views/splash/privacy_policy.dart';
import 'package:swarm/views/splash/splash_screen_login.dart';
import 'package:swarm/views/splash/terms_use.dart';

import '../../services/registration_service.dart';
import '../../storage/registration_storage.dart';
import '../../storage/token_storage.dart';
import '../../utils/toast_utils.dart';
import '../common/our_button.dart';
import '../common/password_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isAgreed = false;

  void _signupButtonPressed() async {
    await RegistrationStorage.removeValue();
    await UserProfileStorage.removeValue();

    final email = _emailController.text;
    final password = _passwordController.text;

    if (_formKey.currentState!.validate() == false) {
      return;
    }

    TextInput.finishAutofillContext();

    if (!_isAgreed) {
      ToastHelper.showErrorToast(
          context, "Please agree to the terms and conditions.");
      return;
    }

    // Call the TokenRequest to get the JWT token
    final registrationRequest = RegistrationService();
    final tokenResponse =
        await registrationRequest.userRegistration(context, email, password);

    if (tokenResponse != null && tokenResponse is String) {
      ToastHelper.showErrorToast(context, tokenResponse);
    } else if (tokenResponse != null) {
      await TokenStorage.setJwtToken(jsonEncode(tokenResponse));
      Get.offAll(() => const ProfileType());
    } else {
      ToastHelper.showErrorToast(context, unknownError);
    }
  }

  @override
  void dispose() {
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
                    child: "Sign up"
                        .text
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
                    isEmail: true),
                PasswordField(
                  hint: password,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                ),
                25.heightBox,
                CheckboxListTile(
                  activeColor:
                      universalColorPrimaryDefault, // Color of the checkbox when it's checked
                  checkColor:
                      universalBlackSecondary, // Color of the check icon
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "I agree to the ",
                          style: TextStyle(
                            fontFamily: milligramSemiBold,
                            color: universalBlackSecondary,
                            fontSize: 17,
                          ),
                        ),
                        TextSpan(
                          text: "Terms of Service", // Add this for Terms link
                          style: TextStyle(
                            fontFamily: milligramSemiBold,
                            color:
                                universalColorPrimaryDefault, // Customize the link color
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to the Terms screen when clicked
                              Get.to(() =>
                                  TermsAndConditionsScreen()); // Replace with your Terms screen route
                            },
                        ),
                        TextSpan(
                          text: " and ",
                          style: TextStyle(
                            fontFamily: milligramSemiBold,
                            color: universalBlackSecondary,
                            fontSize: 17,
                          ),
                        ),
                        TextSpan(
                          text:
                              "Privacy Policy", // Add this for Privacy Policy link
                          style: TextStyle(
                            fontFamily: milligramSemiBold,
                            color:
                                universalColorPrimaryDefault, // Customize the link color
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to the Privacy Policy screen when clicked
                              Get.to(() =>
                                  PrivacyPolicyScreen()); // Replace with your Privacy Policy screen route
                            },
                        ),
                      ],
                    ),
                  ),
                  value: _isAgreed,
                  onChanged: (newValue) {
                    setState(() {
                      _isAgreed = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                15.heightBox,
                ourButton(
                        onPress: _signupButtonPressed,
                        color: universalColorPrimaryDefault,
                        textColor: universalBlackPrimary,
                        title: signup,
                        isDisabled: !_isAgreed)
                    .box
                    .width(context.screenWidth - 50)
                    .height(50)
                    .make(),
                20.heightBox,
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                              fontFamily: milligramSemiBold,
                              color: universalBlackSecondary,
                              fontSize: 17)),
                      TextSpan(
                          text: login,
                          style: TextStyle(
                              fontFamily: milligramBold,
                              color: universalBlackPrimary,
                              fontSize: 17))
                    ],
                  ),
                ).onTap(() {
                  Get.to(() => const SplashScreenLogin());
                }),
              ],
            )
                .box
                .white
                .rounded
                .padding(const EdgeInsets.only(left: 40, right: 40))
                .shadowSm
                .make(),
          ),
        ),
      ),
    );
  }
}
