import 'package:get/get.dart';
import 'package:swarm/views/auth/reset_password.dart';
import 'package:swarm/views/splash/splash_screen_login.dart';

import '../../consts/consts.dart';
import '../../services/user_profile_service.dart';
import '../common/custom_textfield.dart';
import '../common/our_button.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _forgetPassword() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    UserProfileService userProfileService = UserProfileService();
    await userProfileService.forgetPassword(context, _emailController.text);
    Get.to(() => ResetPasswordScreen(
          email: _emailController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: universalWhitePrimary,
      body: Center(
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            (context.screenHeight * 0.2).heightBox,
            Align(
                alignment: Alignment.centerLeft,
                child:
                    forgetPassword.text.fontFamily(bold).black.size(40).make()),
            15.heightBox,
            customTextFiled(
                hint: email,
                controller: _emailController,
                isRequired: true,
                isEmail: true),
            10.heightBox,
            ourButton(
              color: universalColorPrimaryDefault,
              title: "Forget Password",
              textColor: universalBlackPrimary,
              onPress: () async {
                await _forgetPassword();
              },
            ).box.width(context.screenWidth - 50).height(50).make(),
            20.heightBox,
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                      text: donotHaveAccount,
                      style: TextStyle(
                          fontFamily: bold,
                          color: universalBlackSecondary,
                          fontSize: 17)),
                  TextSpan(
                      text: login,
                      style: TextStyle(
                          fontFamily: bold,
                          color: universalBlackPrimary,
                          fontSize: 17))
                ],
              ),
            ).onTap(() {
              Get.offAll(() => const SplashScreenLogin());
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
    );
  }
}
