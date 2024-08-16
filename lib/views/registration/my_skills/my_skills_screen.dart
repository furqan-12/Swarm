import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';

import '../../../services/response/skill.dart';
import '../../../services/skill_service.dart';
import '../../../storage/models/registration.dart';
import '../../../storage/registration_storage.dart';
import '../../../utils/toast_utils.dart';
import '../portfolio_screen/portfolio_screen_screen.dart';
import '../../common/our_button.dart';

class MySkillsScreen extends StatefulWidget {
  const MySkillsScreen({super.key});

  @override
  State<MySkillsScreen> createState() => _MySkillsScreenState();
}

class _MySkillsScreenState extends State<MySkillsScreen> {
  List<Skill> items = [];
  List<String> selectedSkills = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadSkills();
    });
  }

  Future<void> _loadSkills() async {
    final skillRequest = SkillService();
    final skills = await skillRequest.getSkills(
      context,
    );
    if (skills == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }

    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null && registration.skillIds != null) {
      setState(() {
        items = skills;
        selectedSkills = registration.skillIds!;
      });
    } else {
      setState(() {
        items = skills;
      });
    }
  }

  Future<void> selectSkill() async {
    final jsonStr = await RegistrationStorage.getValue;
    if (jsonStr != null) {
      // Convert the JSON string back to a JSON map
      final json = jsonDecode(jsonStr);

      final registration = RegistrationModel.fromJson(json);
      registration.skillIds = selectedSkills;
      final jsonMap = registration.toJson();
      RegistrationStorage.setValue(jsonEncode(jsonMap));
      Get.to(() => const PortfolioScreen());
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
                  child: "My skills"
                      .text
                      .fontFamily(milligramBold)
                      .black
                      .size(40)
                      .make()),
              Expanded(
                  child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        Skill item = items[index];
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (selectedSkills.contains(item.id)) {
                                    selectedSkills.remove(item.id);
                                  } else {
                                    selectedSkills.add(item.id);
                                  }
                                });
                              },
                              child: ListTile(
                                title: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      item.name.toString(),
                                      style: TextStyle(
                                          fontFamily: milligramBold,
                                          color:
                                              selectedSkills.contains(item.id)
                                                  ? universalWhitePrimary
                                                  : universalTransblackPrimary),
                                    ),
                                  ),
                                ),
                                trailing: selectedSkills.contains(item.id)
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: universalWhitePrimary,
                                          size: 27,
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                      ),
                              )
                                  .box
                                  .width(context.screenWidth - 20)
                                  .height(50)
                                  .color(selectedSkills.contains(item.id)
                                      ? universalColorSecondaryDefault
                                      : universalBlackCell)
                                  .roundedSM
                                  .make()),
                        );
                      })),
              10.heightBox,
              ourButton(
                color: universalColorPrimaryDefault,
                title: "Continue",
                textColor: universalBlackPrimary,
                onPress: selectedSkills.length > 0
                    ? () async {
                        // Handle button press when a city is selected
                        await selectSkill();
                      }
                    : null,
              ).box.width(context.screenWidth - 50).height(50).rounded.make(),
            ],
          )
              .box
              .white
              .rounded
              .padding(const EdgeInsets.only(left: 30, right: 30, bottom: 40))
              .shadowSm
              .make(),
        ));
  }
}
