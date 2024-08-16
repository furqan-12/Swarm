import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/photographer_service.dart';
import 'package:swarm/services/response/photographerstat.dart';
import 'package:swarm/services/user_profile_service.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/common/cardview.dart';
import 'package:swarm/views/common/earned_cardview.dart';
import 'package:swarm/views/common/vxrating_cardview.dart';
import 'package:swarm/views/photographer/stats_screen/recent_reviews_listview.dart';

import '../../../services/response/user.dart';

class PhotographerStats extends StatefulWidget {
  const PhotographerStats({super.key});

  @override
  State<PhotographerStats> createState() => _PhotographerStatsState();
}

class _PhotographerStatsState extends State<PhotographerStats> {
  UserProfile? user = null;
  PhotographerStat? photographer = null;
  int initReview = 5;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    final userProfile = await UserProfileStorage.getUserProfileModel;
    if (userProfile != null) {
      setState(() {
        user = userProfile;
      });
    } else {
      final userProfileService = UserProfileService();
      final userProfile = await userProfileService.getUserProfile(
        context,
      );
      if (userProfile is String) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }
      final jsonMap = userProfile.toJson();
      UserProfileStorage.setValue(jsonEncode(jsonMap));
      setState(() async {
        user = userProfile;
      });
    }
    final photographerService = PhotographerService();
    photographer = await photographerService.getStats(context, user!.id);
    setState(() {
      photographer = photographer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        //   child: Image.asset("assets/icons/arrow.png").onTap(() {
        //     Get.offAll(() => HomePhotoGrapherScreen());
        //   }),
        // ),
      ),
      backgroundColor: universalWhitePrimary,
      body: photographer == null
          ? null
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: user == null
                            ? CircleAvatar(
                                radius: 45,
                                backgroundColor: universalWhitePrimary,
                                backgroundImage: AssetImage(
                                  "assets/icons/swarmicon.png",
                                ),
                              )
                            : CircleAvatar(
                                radius: 45,
                                backgroundColor: universalBlackCell,
                                backgroundImage: user == null
                                    ? null
                                    : CachedNetworkImageProvider(
                                        user!.imageUrl),
                              ),
                      ),
                    ),
                    20.heightBox,
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: "Your stats"
                            .text
                            .fontFamily(milligramBold)
                            .color(universalBlackPrimary)
                            .size(36)
                            .make(),
                      ),
                    ),
                    10.heightBox,
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              "You're a ",
                              style: TextStyle(
                                  fontSize: 17, fontFamily: milligramRegular),
                            ),
                            Text(
                              photographer!.experienceName,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: milligramBold,
                                color: universalColorPrimaryDefault,
                              ),
                            ),
                            Text(
                              " photographer",
                              style: TextStyle(
                                  fontSize: 17, fontFamily: milligramRegular),
                            ),
                          ],
                        ),
                      ),
                    ),
                    10.heightBox,
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              "You earn ",
                              style: TextStyle(
                                  fontSize: 17, fontFamily: milligramRegular),
                            ),
                            Text(
                              "\$${photographer!.perHourRate.numCurrency}/hr",
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: milligramBold,
                                color: universalColorPrimaryDefault,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    10.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CardView(
                            "Profile went live",
                            formatDateString(photographer!.profileLive),
                            17,
                            15),
                        CardView("Shoots to date",
                            photographer!.totalOrder.toString(), 30, 3),
                        VxRatingCardView(
                            "Real-time rating", photographer!.rating),
                      ],
                    ),
                    8.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        EarnedCardView(
                            "Earned so far in 2024",
                            "\$${photographer!.YealyEarned.numCurrency}",
                            universalColorPrimaryDefault),
                        EarnedCardView(
                            "Earned so far in January",
                            "\$${photographer!.MonthlyEarned.numCurrency}",
                            universalWhitePrimary),
                      ],
                    ),
                    20.heightBox,
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              photographer!.reviews.length.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: milligramBold,
                                color: universalBlackPrimary,
                              ),
                            ),
                            Text(
                              " recent reviews",
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: milligramBold,
                                color: universalBlackPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    10.heightBox,
                    SizedBox(
                        height: context.screenHeight * 0.55,
                        child: RecentReviewsList(
                            photographer!.reviews.length > initReview
                                ? photographer!.reviews.sublist(0, initReview)
                                : photographer!.reviews)),
                    if (photographer!.reviews.length > initReview) Divider(),
                    if (photographer!.reviews.length > initReview)
                      Text(
                        "Show more",
                        style: TextStyle(
                            color: universalColorPrimaryDefault,
                            fontFamily: milligramBold),
                      ).onTap(() {
                        setState(() {
                          initReview = initReview + 5;
                        });
                      }),
                    if (photographer!.reviews.length > initReview) Divider()
                  ],
                ),
              ),
            ),
    );
  }
}
