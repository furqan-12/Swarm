import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swarm/services/user_profile_service.dart';
import 'package:swarm/views/common/custom_multilines_text_field.dart';
import 'package:swarm/services/response/user.dart';
import 'package:swarm/utils/toast_utils.dart';

import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';
import '../../consts/consts.dart';
import '../common/our_button.dart';

class ContactUsScreen extends StatefulWidget {
  final UserProfile user;
  const ContactUsScreen({super.key, required this.user});

  @override
  State<ContactUsScreen> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUsScreen> {
  final TextEditingController _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _ContactUs() async {
    if (_formKey.currentState!.validate() == false ||
        _messageController.text.trim().isEmpty) {
      return;
    }
    UserProfileService userProfileService = UserProfileService();
    final updated = await userProfileService.sendMessage(context,
        "${_messageController.text.trim()} /n User Email: ${widget.user.email}");
    if (updated) {
      ToastHelper.showSuccessToast(
          context,
          CircleAvatar(
            backgroundColor: Colors.white,
                radius: 40,
               backgroundImage: AssetImage(
                          "assets/icons/universal-done-small.png",
                        ),
              ),
          "Message received!",
          "Thanks for reaching out. We’ll get back to you ASAP.",
          "Back to home", () {
        Get.to(HomeUserScreen());
      });
    } else {
      ToastHelper.showErrorToast(context, unknownError);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
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
        body: Stack(children: [
          SingleChildScrollView(
            child: Center(
                child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: "Contact us"
                          .text
                          .fontFamily(milligramBold)
                          .black
                          .size(40)
                          .make()),
                  10.heightBox,
                  Align(
                      alignment: Alignment.centerLeft,
                      child:
                          "Please reach out with any questions, comments, or feedback. A member of the Swarm team will get back to you asap."
                              .text
                              .fontFamily(milligramRegular)
                              .color(universalBlackSecondary)
                              .size(15)
                              .make()),
                  15.heightBox,
                  customMultilineTextFiled(
                      name: "Message",
                      hint: "Send a message",
                      controller: _messageController,
                      maxLength: 1000,
                      isRequired: true,
                      maxLines: 9),
                  (context.screenHeight * 0.5).heightBox,
                ],
              )
                  .box
                  .white
                  .rounded
                  .padding(const EdgeInsets.only(left: 20, right: 20))
                  .shadowSm
                  .make(),
            )),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              color: universalWhitePrimary,
              child: ourButton(
                color: universalColorPrimaryDefault,
                title: submit,
                textColor: universalBlackPrimary,
                onPress: () async {
                  await _ContactUs();
                },
              ),
            ),
          ),
        ]));
  }
}
