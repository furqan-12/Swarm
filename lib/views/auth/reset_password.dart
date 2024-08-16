import 'package:get/get.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/auth/login_screen.dart';

import '../../consts/consts.dart';
import '../../services/user_profile_service.dart';
import '../common/custom_textfield.dart';
import '../common/our_button.dart';
import '../common/password_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _resetPasswordController =
      TextEditingController();
  final TextEditingController _retryPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate() == false ||
        _retryPasswordController.text != _resetPasswordController.text) {
      if (_formKey.currentState!.validate() == true &&
          _retryPasswordController.text != _resetPasswordController.text) {
        ToastHelper.showErrorToast(context, 'Retype password not matched.');
      }
      return;
    }

    UserProfileService userProfileService = UserProfileService();
    final updated = await userProfileService.resetPassword(context,
        widget.email, _resetPasswordController.text, _tokenController.text);

    if (updated == null) {
      ToastHelper.showErrorToast(context, 'Failed to reset password.');
      return;
    }

    if (updated is String) {
      ToastHelper.showSuccessToast(
          context,
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40,
            backgroundImage: AssetImage(
              "assets/icons/universal-done-small.png",
            ),
          ),
          "Password updated!",
          updated,
          "Back to login", () {
        Get.offAll(const LoginScreen());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ToastHelper.showSuccessToast(
          context,
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40,
            backgroundImage: AssetImage(
              "assets/icons/universal-done-small.png",
            ),
          ),
          "OTP Sent",
          "OTP has been sent to your authorized Email.",
          "Ok", () {
        Get.back();
      });
    });
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
                child: resetPassword.text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make()),
            15.heightBox,
            customTextFiled(
                hint: oneTimePassword,
                controller: _tokenController,
                isRequired: true,
                isEmail: false),
            10.heightBox,
            PasswordField(
                hint: "New Password", controller: _resetPasswordController),
            10.heightBox,
            PasswordField(
                hint: "Re-Type Password",
                controller: _retryPasswordController,
                isPatternValidate: false),
            40.heightBox,
            ourButton(
              color: universalColorPrimaryDefault,
              title: "Reset Password",
              textColor: universalBlackPrimary,
              onPress: () async {
                await _resetPassword();
              },
            ).box.width(context.screenWidth - 50).height(50).make(),
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
