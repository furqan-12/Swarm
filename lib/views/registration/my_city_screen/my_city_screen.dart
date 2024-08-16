import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/city_service.dart';
import 'package:swarm/storage/token_storage.dart';
import 'package:swarm/views/registration/brand_screen/which_work_screen.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/home_user.dart';

import '../../../consts/api.dart';
import '../../../services/customer_service.dart';
import '../../../services/response/city.dart';
import '../../../storage/registration_storage.dart';
import '../../../utils/toast_utils.dart';
import '../my_boroughs/my_boroughs_screen.dart';
import '../../common/our_button.dart';

class MyCityScreen extends StatefulWidget {
  const MyCityScreen({super.key});

  @override
  State<MyCityScreen> createState() => _MyCityScreenState();
}

class _MyCityScreenState extends State<MyCityScreen> {
  List<City> items = [];
  City? selected = null;
  int selectedIndex = -1;
  var _profileTypeId = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadCities();
    });
  }

  Future<void> _loadCities() async {
    final cityRequest = CityService();
    final cities = await cityRequest.getCities(
      context,
    );
    if (cities == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }

    final registration = await RegistrationStorage.getRegistrationModel;
    _profileTypeId = registration!.profileTypeId;
    items = cities;
    items.add(City("", "Los Angeles", isDisable: true));
    items.add(City("", "San Francisco", isDisable: true));
    items.add(City("", "Boston", isDisable: true));
    items.add(City("", "Miami", isDisable: true));
    items.add(City("", "Chicago", isDisable: true));
    items.add(City("", "Austin", isDisable: true));
    items.add(City("", "San Diego", isDisable: true));
    if (!registration.cityId.isEmptyOrNull) {
      setState(() {
        items = items;
        selectedIndex =
            items.indexWhere((element) => element.id == registration.cityId);
        selected = items[selectedIndex];
      });
    } else {
      setState(() {
        items = items;
      });
    }
  }

  Future<void> selectCity() async {
    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null) {
      registration.cityId = selected!.id;
      final jsonMap = registration.toJson();
      RegistrationStorage.setValue(jsonEncode(jsonMap));

      if (registration.profileTypeId == ModelTypeId) {
        final service = CustomerService(registration);
        final response = await service.updateProfile(
          context,
        );
        if (response is bool && response == true) {
          await TokenStorage.updateProfileCompletedToken();
          Get.offAll(() => HomeUserScreen(
                index: 0,
              ));
        } else {
          ToastHelper.showErrorToast(context, response);
        }
      } else if (registration.profileTypeId == BrandTypeId) {
        Get.to(() => const WhichWorksScreen());
      } else if (registration.profileTypeId == PhotographerTypeId) {
        Get.to(() => MyBoroughsScreen(cityId: selected!.id));
      }
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
          bottom: _profileTypeId == PhotographerTypeId
              ? PreferredSize(
                  preferredSize:
                      Size.fromHeight(26.0), // Set your preferred height
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
                            style:
                                TextStyle(fontSize: 14, color: universalGary),
                          ),
                          Text(
                            "Portfolio",
                            style:
                                TextStyle(fontSize: 14, color: universalGary),
                          ),
                          Text(
                            "Get paid",
                            style:
                                TextStyle(fontSize: 14, color: universalGary),
                          ),
                          Text(
                            "Submit",
                            style:
                                TextStyle(fontSize: 14, color: universalGary),
                          )
                        ],
                      ).box.margin(EdgeInsets.only(left: 15, right: 15)).make()
                    ],
                  ),
                )
              : null,
        ),
        backgroundColor: universalWhitePrimary,
        body: Center(
          child: Column(
            children: [
              _profileTypeId == PhotographerTypeId
                  ? 10.heightBox
                  : 36.heightBox,
              Align(
                  alignment: Alignment.centerLeft,
                  child: "City"
                      .text
                      .fontFamily(milligramBold)
                      .black
                      .size(40)
                      .make()),
              25.heightBox,
              Expanded(
                  child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        City item = items[index];
                        return GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                                onTap: item.isDisable
                                    ? null
                                    : () {
                                        for (var i in items) {
                                          i.isSelected = false;
                                        }
                                        setState(() {
                                          item.isSelected = !item.isSelected;
                                          selectedIndex = index;
                                          if (item.isSelected) {
                                            selected = item;
                                          } else {
                                            selected == null;
                                          }
                                        });
                                      },
                                child: ListTile(
                                  title: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 15, left: 45),
                                      child: Text(
                                        item.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: milligramBold,
                                            color: item.isSelected ||
                                                    item.isDisable
                                                ? universalWhitePrimary
                                                : universalTransblackPrimary),
                                      ),
                                    ),
                                  ),
                                  trailing: item.isSelected
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
                                    .height(50)
                                    .color(item.isSelected
                                        ? universalColorSecondaryDefault
                                        : item.isDisable
                                            ? universalDisableCell
                                            : universalBlackCell)
                                    .roundedSM
                                    .make()),
                          ),
                        );
                      })),
              10.heightBox,
              ourButton(
                color: universalColorPrimaryDefault,
                title: "Continue",
                textColor: universalBlackPrimary,
                onPress: selectedIndex > -1
                    ? () async {
                        await selectCity();
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
