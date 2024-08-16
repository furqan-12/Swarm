import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/borough.dart';

import '../../../services/hood_service.dart';
import '../../../services/response/hood.dart';
import '../../../storage/registration_storage.dart';
import '../../../utils/toast_utils.dart';
import '../my_days_hours/my_days_and_hours.dart';
import '../../common/our_button.dart';

class MyHoodsScreen extends StatefulWidget {
  final List<Borough> boroughs; // Add a cityID parameter to the constructor

  const MyHoodsScreen({Key? key, required this.boroughs}) : super(key: key);

  @override
  State<MyHoodsScreen> createState() => _MyHoodsScreenState();
}

class _MyHoodsScreenState extends State<MyHoodsScreen> {
  List<String> selectedHoods = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadHoods(widget.boroughs);
    });
  }

  Future<void> _loadHoods(List<Borough> boroughs) async {
    final hoodRequest = HoodService();
    final registration = await RegistrationStorage.getRegistrationModel;
    for (var borough in boroughs) {
      final hoods = await hoodRequest.getHoods(context, borough.id);
      borough.hoods = hoods;
      if (hoods == null) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }
    }
    if (registration != null &&
        registration.hoodIds != null &&
        registration.hoodIds!.length > 0) {
      setState(() {
        selectedHoods = registration.hoodIds!;
      });
    } else {
      setState(() {
        boroughs = boroughs;
      });
    }
  }

  Future<void> selectHood() async {
    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null && selectedHoods.length > 0) {
      registration.hoodId = selectedHoods.firstOrNull();
      registration.hoodIds = selectedHoods;
      final jsonMap = registration.toJson();
      RegistrationStorage.setValue(jsonEncode(jsonMap));
      Get.to(() => const MyDaysAndHours(
            fromHome: false,
          ));
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
                        width: 120,
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
                      style: TextStyle(fontSize: 14, color: universalGary),
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
                child: ListView.builder(
                  itemCount: widget.boroughs.length,
                  itemBuilder: (context, boroughIndex) {
                    Borough borough = widget.boroughs[boroughIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: 25, top: boroughIndex == 0 ? 0 : 25),
                          child: borough.name.text
                              .fontFamily(milligramBold)
                              .black
                              .size(40)
                              .make(),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: borough.hoods?.length ?? 0,
                          itemBuilder: (context, hoodIndex) {
                            Hood item = borough.hoods![hoodIndex];
                            item.isSelected = selectedHoods.contains(item.id);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedHoods.contains(item.id)) {
                                    selectedHoods.remove(item.id);
                                  } else {
                                    selectedHoods.add(item.id);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  child: ListTile(
                                    title: Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 15, left: 45),
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontFamily: milligramBold,
                                            color: item.isSelected
                                                ? universalWhitePrimary
                                                : universalTransblackPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    trailing: item.isSelected
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
                                  ),
                                )
                                    .box
                                    .width(context.screenWidth - 20)
                                    .height(50)
                                    .color(item.isSelected
                                        ? universalColorSecondaryDefault
                                        : universalBlackCell)
                                    .roundedSM
                                    .make(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              10.heightBox,
              ourButton(
                color: universalColorPrimaryDefault,
                title: "Continue",
                textColor: universalBlackPrimary,
                isDisabled: selectedHoods.length <= 0,
                onPress: selectedHoods.length > 0
                    ? () async {
                        await selectHood();
                      }
                    : null,
              ).box.width(context.screenWidth - 50).height(50).rounded.make(),
            ],
          )
              .box
              .white
              .rounded
              .padding(const EdgeInsets.only(left: 15, right: 15, bottom: 30))
              .shadowSm
              .make(),
        ));
  }
}
