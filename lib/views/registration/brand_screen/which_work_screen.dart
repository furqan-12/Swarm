import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/storage/token_storage.dart';
import 'package:swarm/views/order/shoot_type/shoot_type_screen.dart';

import '../../../services/customer_service.dart';
import '../../../storage/registration_storage.dart';
import '../../../utils/toast_utils.dart';
import '../../common/our_button.dart';

class WhichWorksScreen extends StatefulWidget {
  const WhichWorksScreen({super.key});

  @override
  State<WhichWorksScreen> createState() => _WhichWorksScreenState();
}

class _WhichWorksScreenState extends State<WhichWorksScreen> {
  Future<void> selectWorkForYou(String brandChoiceId) async {
    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null) {
      registration.brandChoiceId = brandChoiceId;
      final jsonMap = registration.toJson();
      RegistrationStorage.setValue(jsonEncode(jsonMap));
      final service = CustomerService(registration);
      final response = await service.updateProfile(
        context,
      );
      if (response is bool && response == true) {
        await TokenStorage.updateProfileCompletedToken();
        Get.to(() => const ShootTypeScreen(
              fromHome: false,
            ));
      } else {
        ToastHelper.showErrorToast(context, response);
      }
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
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: "Which works best \nfor you?"
                        .text
                        .fontFamily(milligramBold)
                        .black
                        .size(40)
                        .make()),
              ),
              15.heightBox,
              15.heightBox,
              ourButton(
                color: universalColorPrimaryDefault,
                title: singleShoot,
                textColor: universalBlackPrimary,
                onPress: () async {
                  await selectWorkForYou(singleShoot);
                },
              ).box.width(context.screenWidth - 50).height(60).rounded.make(),
              13.heightBox,
              ourButton(
                color: universalColorPrimaryDefault,
                title: seriesShoot,
                textColor: universalBlackPrimary,
                onPress: () async {
                  await selectWorkForYou(seriesShoot);
                },
              ).box.width(context.screenWidth - 50).height(60).rounded.make(),
              13.heightBox,
              ourButton(
                color: universalColorPrimaryDefault,
                title: corporate,
                textColor: universalBlackPrimary,
                onPress: () async {
                  await selectWorkForYou(corporate);
                },
              ).box.width(context.screenWidth - 50).height(60).rounded.make(),
            ],
          ),
        ));
  }
}
