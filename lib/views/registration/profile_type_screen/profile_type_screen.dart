import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';

import '../../../consts/api.dart';
import '../../../storage/models/registration.dart';
import '../../../storage/registration_storage.dart';
import '../../user_profile/profile_screen.dart';
import '../../common/our_button.dart';

class ProfileType extends StatelessWidget {
  const ProfileType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: universalWhitePrimary,
          backgroundColor: universalWhitePrimary,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            // child: Image.asset("assets/icons/arrow.png").onTap(() {
            //   Navigator.pop(context);
            // }),
          ),
        ),
        backgroundColor: universalWhitePrimary,
        body: Container(
          padding: const EdgeInsets.all(12),
          width: context.screenWidth,
          height: context.screenHeight,
          child: Column(
            children: [
              36.heightBox,
              Align(
                  alignment: Alignment.topLeft,
                  child: "Profile type"
                      .text
                      .color(universalBlackPrimary)
                      .size(34)
                      .fontFamily(milligramBold)
                      .make()),
              15.heightBox,
              15.heightBox,
              ourButton(
                      color: universalColorPrimaryDefault,
                      title: model,
                      textColor: universalBlackPrimary,
                      onPress: () {
                        setProfileType(ModelTypeId);
                      })
                  .box
                  .width(context.screenWidth - 50)
                  .height(50)
                  .rounded
                  .make(),
              13.heightBox,
              ourButton(
                      color: universalColorPrimaryDefault,
                      title: photographer,
                      textColor: universalBlackPrimary,
                      onPress: () async {
                        await setProfileType(PhotographerTypeId);
                      })
                  .box
                  .width(context.screenWidth - 50)
                  .height(50)
                  .rounded
                  .make(),
            ],
          ),
        ));
  }

  Future<void> setProfileType(String typeId) async {
    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null) {
      registration.profileTypeId = typeId;
      final jsonMap = registration.toJson();
      RegistrationStorage.setValue(jsonEncode(jsonMap));
    } else {
      final registration = RegistrationModel(
        profileTypeId: typeId,
      );

      final json = registration.toJson();

      RegistrationStorage.setValue(jsonEncode(json));
    }
    Get.to(() => const ProfileScreen(
          fromHome: false,
        ));
  }
}
