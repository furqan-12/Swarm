import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swarm/services/response/user.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/utils/toast_utils.dart';

import 'package:swarm/views/common/update_password_textfield.dart';

import '../../consts/consts.dart';
import '../../services/user_profile_service.dart';
import '../common/our_button.dart';

class ChangePassword extends StatefulWidget {
  final UserProfile user;
  const ChangePassword({super.key, required this.user});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _changePasswordController =
      TextEditingController();
  final TextEditingController _retryPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate() == false ||
        _retryPasswordController.text != _changePasswordController.text) {
      if (_formKey.currentState!.validate() == true &&
          _retryPasswordController.text != _changePasswordController.text) {
        ToastHelper.showErrorToast(context, 'Retype password not matched.');
      }
      return;
    }
    UserProfileService userProfileService = UserProfileService();
    final updated = await userProfileService.changePassword(
        context,
        _oldPasswordController.text,
        _changePasswordController.text,
        _retryPasswordController.text);

    if (updated is String) {
      ToastHelper.showErrorToast(context, updated);
      return;
    }
    if (updated == null) {
      ToastHelper.showErrorToast(context, 'Failed to change password.');
      return;
    }

    try {
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
          "Your password has been updated.",
          "Back to profile", () {
        Get.back();
        Get.back();
      });
    } catch (e) {
      print(e);
    } // Show the dialog
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _changePasswordController.dispose();
    _retryPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          child: Image.asset("assets/icons/arrow.png").onTap(() {
            Navigator.pop(context);
          }),
        ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Center(
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: UpdatePassword.text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make()),
            15.heightBox,
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(_passwordVisible
                        ? Icons.password
                        : Icons.remove_red_eye),
                    Text(
                      _passwordVisible ? " Hide" : " Show",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ).onTap(() {
                  _togglePasswordVisibility();
                })
              ],
            ),
            UpdatePasswordField(
              hint: oldPassword,
              controller: _oldPasswordController,
              isPatternValidate: false,
              isPasswordVisible: _passwordVisible,
              onToggleVisibility: (bool isVisible) {
                _togglePasswordVisibility();
              },
            ),
            10.heightBox,
            UpdatePasswordField(
              hint: newPassword,
              controller: _changePasswordController,
              isPasswordVisible: _passwordVisible,
              onToggleVisibility: (bool isVisible) {
                _togglePasswordVisibility();
              },
            ),
            10.heightBox,
            UpdatePasswordField(
              hint: retypePassword,
              controller: _retryPasswordController,
              isPatternValidate: false,
              isPasswordVisible: _passwordVisible,
              onToggleVisibility: (bool isVisible) {
                _togglePasswordVisibility();
              },
            ),
            25.heightBox,
            Expanded(
                child: Column(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password must:",
                      style: TextStyle(fontFamily: milligramBold, fontSize: 15),
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                      children: [
                        TextSpan(
                          text: '    • Be at least 6 characters long ',
                        ),
                        if (_changePasswordController.text.length > 0)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: _changePasswordController.text.length >= 6
                                ? Icon(Icons.check_circle,
                                    size: 16.0,
                                    color: universalColorSecondaryDefault)
                                : Icon(FontAwesomeIcons.solidCircleXmark,
                                    size: 16.0, color: Colors.red),
                          ),
                        TextSpan(
                          text: '\n',
                        ),
                        TextSpan(
                          text: '    • Include at least one numder ',
                        ),
                        if (_changePasswordController.text.length > 0)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child:
                                _changePasswordController.text.isAlphabetOnly ==
                                        false
                                    ? Icon(Icons.check_circle,
                                        size: 16.0,
                                        color: universalColorSecondaryDefault)
                                    : Icon(FontAwesomeIcons.solidCircleXmark,
                                        size: 16.0, color: Colors.red),
                          ),
                        TextSpan(
                          text: '\n',
                        ),
                        TextSpan(
                          text: '    • Include at least one capital letter ',
                        ),
                        if (_changePasswordController.text.length > 0)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: containsUpperCase(
                                    _changePasswordController.text)
                                ? Icon(Icons.check_circle,
                                    size: 16.0,
                                    color: universalColorSecondaryDefault)
                                : Icon(FontAwesomeIcons.solidCircleXmark,
                                    size: 16.0, color: Colors.red),
                          ),
                        TextSpan(
                          text: '\n',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
            ourButton(
              color: universalColorPrimaryDefault,
              title: "Submit",
              textColor: universalBlackPrimary,
              onPress: () async {
                await _changePassword();
              },
            ).box.width(context.screenWidth - 50).height(50).make(),
            10.heightBox
          ],
        )
            .box
            .white
            .rounded
            .padding(const EdgeInsets.only(left: 20, right: 20))
            .shadowSm
            .make(),
      )),
    );
  }
}
