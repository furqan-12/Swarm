import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';

import '../../../consts/api.dart';
import '../../../storage/registration_storage.dart';
import '../my_skills/my_skills_screen.dart';
import '../../common/our_button.dart';

class ShootingWithScreen extends StatefulWidget {
  const ShootingWithScreen({super.key});

  @override
  State<ShootingWithScreen> createState() => _ShootingWithScreenState();
}

class _ShootingWithScreenState extends State<ShootingWithScreen> {
  Future<void> selectDevice(String shootingDeviceId) async {
    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null) {
      registration.shootingDeviceId = shootingDeviceId;
      final jsonMap = registration.toJson();
      RegistrationStorage.setValue(jsonEncode(jsonMap));
      Get.to(() => const MySkillsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: universalWhitePrimary,
      body: Center(
        child: Column(
          children: [
            (context.screenHeight * 0.1).heightBox,
            Align(
                alignment: Alignment.centerLeft,
                child: "I'm shooting with"
                    .text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make()),
            50.heightBox,
            ourButton(
                    color: universalColorPrimaryDefault,
                    title: myPhone,
                    textColor: universalBlackPrimary,
                    onPress: () async {
                      await selectDevice(ShootingDevice['Phone'] as String);
                    })
                .box
                .width(context.screenWidth - 50)
                .height(50)
                .rounded
                .make(),
            13.heightBox,
            ourButton(
                    color: universalColorPrimaryDefault,
                    title: camera,
                    textColor: universalBlackPrimary,
                    onPress: () async {
                      await selectDevice(ShootingDevice['Camera'] as String);
                    })
                .box
                .width(context.screenWidth - 50)
                .height(50)
                .rounded
                .make(),
          ],
        ),
      ).box.white.rounded.padding(const EdgeInsets.all(20)).shadowSm.make(),
    );
  }
}
