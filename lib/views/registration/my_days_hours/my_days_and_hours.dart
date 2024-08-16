import 'dart:convert';

import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/utils/toast_utils.dart';

import '../../../services/photographer_schedule_service.dart';
import '../../../storage/models/registration.dart';
import '../../../storage/registration_storage.dart';
import '../my_experience/my_experience_screen.dart';
import '../../common/our_button.dart';

class MyDaysAndHours extends StatefulWidget {
  final bool fromHome;
  const MyDaysAndHours({super.key, required this.fromHome});

  @override
  State<MyDaysAndHours> createState() => _MyDaysAndHoursState();
}

class _MyDaysAndHoursState extends State<MyDaysAndHours> {
  List<Schedule> items = [
    Schedule('a24c50e7-2c23-4cfe-95f7-9c53d0a9149b', 'Monday', DateTime.now(),
        DateTime.now(), 1, 1, false),
    Schedule('b83aa755-3f09-43fb-9e2b-382f5dfb0d1c', 'Tuesday', DateTime.now(),
        DateTime.now(), 1, 1, false),
    Schedule('c14b749b-877e-4622-b14e-e1f64809c133', 'Wednesday',
        DateTime.now(), DateTime.now(), 1, 1, false),
    Schedule('d30c1b16-8b4f-4b98-9ca1-3d43950bf47c', 'Thursday', DateTime.now(),
        DateTime.now(), 1, 1, false),
    Schedule('e40988b5-887e-4242-8b45-27c3082ed8c1', 'Friday', DateTime.now(),
        DateTime.now(), 1, 1, false),
    Schedule('f0c2d5b4-27af-49f6-af1b-7ad4bde9eefa', 'Saturday', DateTime.now(),
        DateTime.now(), 1, 1, false),
    Schedule('1b01d8ea-3ad2-431f-a3e6-37fc252d5375', 'Sunday', DateTime.now(),
        DateTime.now(), 1, 1, false),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadSchedules();
    });
  }

  Future<void> _loadSchedules() async {
    if (widget.fromHome) {
      PhotographerScheduleService photographerScheduleService =
          PhotographerScheduleService();
      List<Schedule>? schedules = await photographerScheduleService.getSchedule(
        context,
      );
      List<Schedule> days = [];
      for (var item in items) {
        if (schedules!.any((element) =>
            element.dayId == item.dayId && element.isActive == true)) {
          final _schedule = schedules
              .where((element) => element.dayId == item.dayId)
              .firstOrNull();
          _schedule.toHour = _schedule.fromHour > _schedule.toHour
              ? _schedule.fromHour
              : _schedule.toHour;
          days.add(Schedule(item.dayId, item.name, DateTime.now(),
              DateTime.now(), _schedule.fromHour, _schedule.toHour, true));
        } else {
          days.add(Schedule(item.dayId, item.name, DateTime.now(),
              DateTime.now(), item.fromHour, item.toHour, false));
        }
      }

      setState(() {
        items = days;
      });
    } else {
      final registration = await RegistrationStorage.getRegistrationModel;
      if (registration != null && registration.schedules != null) {
        List<Schedule> days = [];
        for (var item in items) {
          if (registration.schedules!.any((element) =>
              element['dayId'] == item.dayId && element['isActive'] == true)) {
            final d = registration.schedules
                ?.where((element) => element['dayId'] == item.dayId)
                .firstOrNull();
            days.add(Schedule(item.dayId, item.name, DateTime.now(),
                DateTime.now(), d!['fromHour'], d['toHour'], true));
          } else {
            days.add(Schedule(item.dayId, item.name, DateTime.now(),
                DateTime.now(), item.fromHour, item.toHour, false));
          }
        }

        setState(() {
          items = days;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper function to convert the range values to 12-hour format
    String formatTime(double time) {
      int hour = time.toInt();
      int minute = ((time - hour) * 60).toInt();
      String period = 'am';
      if (hour >= 12) {
        period = 'pm';
        if (hour > 12) {
          hour -= 12;
        }
      }
      return '$hour:${minute.toString().padLeft(2, '0')}$period';
    }

    DateTime convertHourToDateTime(int hour) {
      // Set a fixed date, for example, January 1, 2023
      final fixedDate = DateTime(2023, 1, 1);

      // Create a new DateTime object with the specified hour
      final dateTime = fixedDate.add(Duration(hours: hour == 24 ? 23 : hour));

      return dateTime;
    }

    Future<void> selectDays() async {
      if (widget.fromHome) {
        PhotographerScheduleService photographerScheduleService =
            PhotographerScheduleService();
        for (var element in items) {
          element.from = convertHourToDateTime(element.fromHour);
          element.to = convertHourToDateTime(element.toHour);
        }
        final updated =
            await photographerScheduleService.updateSchedule(context, items);
        if (updated) {
          // ToastHelper.showSuccessToast(context, "Updated", height: 60);
        } else {
          ToastHelper.showErrorToast(context, unknownError);
        }
      } else {
        final registration = await RegistrationStorage.getRegistrationModel;
        if (registration != null) {
          registration.schedules = [];
          for (var element in items) {
            final schedule = Schedule(
              element.dayId,
              element.name,
              convertHourToDateTime(element.fromHour),
              convertHourToDateTime(element.toHour),
              element.fromHour,
              element.toHour,
              element.isActive,
            );

            // Convert Schedule object to JSON-encodable map using toJson
            final scheduleJson = schedule.toJson();

            // Add the JSON-encodable schedule to the schedules list
            registration.schedules?.add(scheduleJson);
          }

          final jsonMap = registration.toJson();
          RegistrationStorage.setValue(jsonEncode(jsonMap));
          Get.to(() => const MyExperienceScreen());
        }
      }
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          surfaceTintColor: universalWhitePrimary,
          backgroundColor: universalWhitePrimary,
          leading: widget.fromHome != true
              ? Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                  child: Image.asset("assets/icons/arrow.png").onTap(() {
                    Get.back();
                  }),
                )
              : null,
          bottom: widget.fromHome == true
              ? null
              : PreferredSize(
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
                                fontSize: 14,
                                color: universalColorPrimaryDefault),
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
                ),
        ),
        backgroundColor: universalWhitePrimary,
        body: Center(
          child: Column(
            children: [
              widget.fromHome == true ? 36.heightBox : 10.heightBox,
              Align(
                  alignment: Alignment.centerLeft,
                  child: "Schedule "
                      .text
                      .fontFamily(milligramBold)
                      .black
                      .size(40)
                      .make()),
              15.heightBox,
              Expanded(
                  child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        Schedule item = items[index];
                        bool isSelected = item.isActive;
                        RangeValues rangeValues = isSelected
                            ? RangeValues(item.fromHour.toDouble(),
                                item.toHour.toDouble())
                            : const RangeValues(1, 1);
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                              onTap: () {
                                isSelected = !isSelected;
                                setState(() {
                                  item.isActive = isSelected;
                                });
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontFamily: milligramBold,
                                            color: isSelected
                                                ? universalBlackPrimary
                                                : universalTransblackPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        height: 27,
                                        child: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                color:
                                                    universalColorPrimaryDefault,
                                                size: 30,
                                              )
                                            : Icon(
                                                Icons.add_circle,
                                                color: universalBlackPrimary,
                                                size: 30,
                                              ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected)
                                    Column(
                                      children: [
                                        10.heightBox,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${formatTime(rangeValues.start)} - ',
                                              style: TextStyle(
                                                fontFamily: milligramRegular,
                                              ),
                                            ),
                                            Text(
                                              '${formatTime(rangeValues.end)}',
                                              style: TextStyle(
                                                fontFamily: milligramRegular,
                                              ),
                                            ),
                                          ],
                                        ),
                                        RangeSlider(
                                          values: rangeValues,
                                          min: 0,
                                          max: 24,
                                          divisions: 1000,
                                          labels: RangeLabels(
                                            formatTime(rangeValues.start),
                                            formatTime(rangeValues.end),
                                          ),
                                          inactiveColor: universalBlackLine,
                                          activeColor: universalWhitePrimary,
                                          overlayColor:
                                              MaterialStatePropertyAll(
                                                  Colors.black),
                                          onChanged: (RangeValues values) {
                                            setState(() {
                                              rangeValues = values;
                                              item.fromHour =
                                                  values.start.toInt();
                                              item.toHour = values.end.toInt();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                ],
                              )
                                  .box
                                  .width(context.screenWidth - 20)
                                  .padding(
                                    isSelected
                                        ? const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 10,
                                            right: 10)
                                        : const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 10,
                                            right: 10),
                                  )
                                  .height(isSelected ? 125 : 50)
                                  .color(isSelected
                                      ? universalLemonSecondary
                                      : universalBlackCell)
                                  .roundedSM
                                  .make()),
                        );
                      })),
              10.heightBox,
              ourButton(
                      color: universalColorPrimaryDefault,
                      title: widget.fromHome ? "Submit" : "Continue",
                      textColor: universalBlackPrimary,
                      onPress: () async {
                        await selectDays();
                      })
                  .box
                  .width(context.screenWidth - 50)
                  .height(50)
                  .rounded
                  .make(),
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
