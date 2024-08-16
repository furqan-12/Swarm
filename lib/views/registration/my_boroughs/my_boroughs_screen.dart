import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';

import '../../../services/borough_service.dart';
import '../../../services/response/borough.dart';
import '../../../storage/registration_storage.dart';
import '../../../utils/toast_utils.dart';
import '../my_hoods/my_hoods_screen.dart';
import '../../common/our_button.dart';

class MyBoroughsScreen extends StatefulWidget {
  final String cityId; // Add a cityID parameter to the constructor

  const MyBoroughsScreen({Key? key, required this.cityId}) : super(key: key);

  @override
  State<MyBoroughsScreen> createState() => _MyBoroughsScreenState();
}

class _MyBoroughsScreenState extends State<MyBoroughsScreen> {
  List<Borough> items = [];
  List<Borough> selectedBoroughs = [];
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadBoroughs(widget.cityId);
    });
  }

  Future<void> _loadBoroughs(String cityId) async {
    final boroughRequest = BoroughService();
    final boroughs = await boroughRequest.getBoroughs(context, cityId);
    if (boroughs == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }

    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null && !registration.boroughId.isEmptyOrNull) {
      setState(() {
        items = boroughs;
        selectedBoroughs = items
            .where((borough) => registration.boroughId!.contains(borough.id))
            .toList();
        isAllSelected = selectedBoroughs.length == items.length;
      });
    } else {
      setState(() {
        items = boroughs;
      });
    }
  }

  Future<void> selectBorough() async {
    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null) {
      List<String> selectedBoroughIds =
          selectedBoroughs.map((borough) => borough.id).toList();
      registration.boroughId = selectedBoroughIds.join(",");
      final jsonMap = registration.toJson();
      RegistrationStorage.setValue(jsonEncode(jsonMap));
      Get.to(() => MyHoodsScreen(boroughs: selectedBoroughs));
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
              Align(
                  alignment: Alignment.centerLeft,
                  child: "Boroughs"
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
                        Borough item = items[index];
                        return GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (selectedBoroughs.contains(item)) {
                                      selectedBoroughs.remove(item);
                                    } else {
                                      selectedBoroughs.add(item);
                                    }
                                    isAllSelected =
                                        selectedBoroughs.length == items.length;
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
                                            color: selectedBoroughs
                                                    .contains(item)
                                                ? universalWhitePrimary
                                                : universalTransblackPrimary),
                                      ),
                                    ),
                                  ),
                                  trailing: selectedBoroughs.contains(item)
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
                                    .color(selectedBoroughs.contains(item)
                                        ? universalColorSecondaryDefault
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
                onPress: selectedBoroughs.isNotEmpty
                    ? () async {
                        // Handle button press when a city is selected
                        await selectBorough();
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
