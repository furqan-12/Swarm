import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/views/registration/portfolio_screen/portfolio_screen_screen.dart';

import '../../../consts/api.dart';
import '../../../storage/registration_storage.dart';
import '../../common/our_button.dart';

class MyExperienceScreen extends StatefulWidget {
  const MyExperienceScreen({super.key});

  @override
  State<MyExperienceScreen> createState() => _MyExperienceScreenState();
}

class _MyExperienceScreenState extends State<MyExperienceScreen> {
  String? experienceSelected = "";
  String? servicesSelected = "";
  String? equipmentSelected = "";
  List<Map<String, String>> experienceOptions = [
    {'title': amateur, 'id': Experiences['Starter'] as String},
    {'title': hobbyist, 'id': Experiences['Experienced'] as String},
    {'title': pro, 'id': Experiences['Pro'] as String},
  ];
  List<Map<String, String>> equipmentOptions = [
    {'title': camera, 'id': ShootingDevice['Camera'] as String},
    {'title': myPhone, 'id': ShootingDevice['Phone'] as String},
    {'title': other, 'id': ShootingDevice['Other'] as String},
  ];

  List<Map<String, String>> skillsOptions = [
    {'title': photography, 'id': Skills['Photography'] as String},
    {'title': videography, 'id': Skills['Videography'] as String},
    {'title': both, 'id': Skills['Both'] as String},
  ];

  Future<void> select() async {
    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null) {
      registration.experienceId = experienceSelected;
      registration.shootingDeviceId = equipmentSelected;
      registration.skillIds = [];
      registration.skillIds!.add(servicesSelected!);

      final jsonMap = registration.toJson();
      RegistrationStorage.setValue(jsonEncode(jsonMap));
    }
    Get.to(() => const PortfolioScreen());
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null) {
      setState(() {
        experienceSelected = registration.experienceId;
        equipmentSelected = registration.shootingDeviceId;
        servicesSelected =
            registration.skillIds != null ? registration.skillIds!.first : "";
      });
    }
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(26.0), // Set your preferred height
          child: Column(
            children: [
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      padding: EdgeInsets.all(3.0),
                      color: universalColorPrimaryDefault,
                    ),
                  ],
                ),
              )
                  .box
                  .color(universalGary)
                  .margin(EdgeInsets.only(right: 15, left: 15))
                  .make(),
              5.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Profile",
                    style: TextStyle(
                        fontSize: 14,
                        color: universalColorPrimaryDefault,
                        fontFamily: milligramSemiBold),
                  ),
                  Text(
                    "Location",
                    style: TextStyle(
                        fontSize: 14,
                        color: universalColorPrimaryDefault,
                        fontFamily: milligramSemiBold),
                  ),
                  Text(
                    "Schedule",
                    style: TextStyle(
                        fontSize: 14, color: universalColorPrimaryDefault),
                  ),
                  Text(
                    "Portfolio",
                    style: TextStyle(fontSize: 14, color: universalGary),
                  ),
                  Text(
                    "Get paid",
                    style: TextStyle(fontSize: 14, color: universalGary),
                  ),
                  Text(
                    "Submit",
                    style: TextStyle(fontSize: 14, color: universalGary),
                  )
                ],
              ).box.margin(EdgeInsets.only(left: 15, right: 15)).make()
            ],
          ),
        ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Center(
        child: Column(
          children: [
            10.heightBox,
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Experience"
                            .text
                            .fontFamily(milligramBold)
                            .black
                            .size(40)
                            .make()),
                    25.heightBox,
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: experienceOptions.length,
                        itemBuilder: (context, index) {
                          var item = experienceOptions[index];
                          return InkWell(
                              onTap: () {
                                setState(() {
                                  experienceSelected = item['id'];
                                });
                              },
                              child: ListTile(
                                title: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 15, left: 45),
                                    child: Text(
                                      item['title']!,
                                      style: TextStyle(
                                          fontFamily: milligramBold,
                                          color:
                                              experienceSelected == item['id']
                                                  ? universalWhitePrimary
                                                  : universalTransblackPrimary),
                                    ),
                                  ),
                                ),
                                trailing: experienceSelected == item['id']
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: universalWhitePrimary,
                                          size: 27,
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 15, left: 30),
                                      ),
                              )
                                  .box
                                  .width(context.screenWidth - 20)
                                  .margin(EdgeInsets.only(bottom: 10))
                                  .height(50)
                                  .color(experienceSelected == item['id']
                                      ? universalColorSecondaryDefault
                                      : universalBlackCell)
                                  .roundedSM
                                  .make());
                        },
                      ),
                    ),
                    20.heightBox,
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Services"
                            .text
                            .fontFamily(milligramBold)
                            .black
                            .size(40)
                            .make()),
                    25.heightBox,
                    Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: skillsOptions.length,
                          itemBuilder: (context, index) {
                            var item = skillsOptions[index];
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      servicesSelected = item['id'];
                                    });
                                  },
                                  child: ListTile(
                                    title: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 15, left: 45),
                                        child: Text(
                                          item['title']!,
                                          style: TextStyle(
                                              fontFamily: milligramBold,
                                              color: servicesSelected ==
                                                      item['id']
                                                  ? universalWhitePrimary
                                                  : universalTransblackPrimary),
                                        ),
                                      ),
                                    ),
                                    trailing: servicesSelected == item['id']
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15),
                                            child: const Icon(
                                              Icons.check_circle,
                                              color: universalWhitePrimary,
                                              size: 27,
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15, left: 30),
                                          ),
                                  )
                                      .box
                                      .width(context.screenWidth - 20)
                                      .height(50)
                                      .color(servicesSelected == item['id']
                                          ? universalColorSecondaryDefault
                                          : universalBlackCell)
                                      .roundedSM
                                      .make()),
                            );
                          }),
                    ),
                    20.heightBox,
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Equipment"
                            .text
                            .fontFamily(milligramBold)
                            .black
                            .size(40)
                            .make()),
                    25.heightBox,
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: equipmentOptions.length,
                      itemBuilder: (context, index) {
                        var item = equipmentOptions[index];
                        return InkWell(
                            onTap: () {
                              setState(() {
                                equipmentSelected = item['id'];
                              });
                            },
                            child: ListTile(
                              title: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 15, left: 45),
                                  child: Text(
                                    item['title']!,
                                    style: TextStyle(
                                        fontFamily: milligramBold,
                                        color: equipmentSelected == item['id']
                                            ? universalWhitePrimary
                                            : universalTransblackPrimary),
                                  ),
                                ),
                              ),
                              trailing: equipmentSelected == item['id']
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: universalWhitePrimary,
                                        size: 27,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 15, left: 30),
                                    ),
                            )
                                .box
                                .width(context.screenWidth - 20)
                                .margin(EdgeInsets.only(bottom: 10))
                                .height(50)
                                .color(equipmentSelected == item['id']
                                    ? universalColorSecondaryDefault
                                    : universalBlackCell)
                                .roundedSM
                                .make());
                      },
                    ),
                  ],
                ),
              ),
            ),
            10.heightBox,
            ourButton(
                    color: universalColorPrimaryDefault,
                    title: "Continue",
                    textColor: universalBlackPrimary,
                    onPress: experienceSelected.isEmptyOrNull ||
                            servicesSelected.isEmptyOrNull ||
                            equipmentSelected.isEmptyOrNull
                        ? null
                        : () async {
                            select();
                          })
                .box
                .width(context.screenWidth - 50)
                .height(50)
                .rounded
                .make(),
          ],
        ),
      )
          .box
          .white
          .rounded
          .padding(const EdgeInsets.only(left: 15, right: 15, bottom: 30))
          .shadowSm
          .make(),
    );
  }
}
