import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/storage/registration_storage.dart';
import 'package:swarm/storage/token_storage.dart';
import 'package:swarm/utils/loader.dart';
import 'package:swarm/views/splash/splash_screen_login.dart';
import 'package:swarm/views/user_profile/contact_us.dart';
import 'package:swarm/views/user_profile/change_password.dart';
import 'package:swarm/views/user_profile/profile_screen.dart';

import '../../services/response/user.dart';
import '../../services/user_profile_service.dart';
import '../../storage/user_profile_storage.dart';
import '../../utils/toast_utils.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? user = null;

  @override
  void dispose(){
    LoaderHelper.hide();
    super.dispose();
  }

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
      if (userProfile == null) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }
      final jsonMap = userProfile.toJson();
      UserProfileStorage.setValue(jsonEncode(jsonMap));
      setState(() {
        user = userProfile;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await UserProfileService().setIsOnline(false);
    } catch (e) {}
    await TokenStorage.removeJwtToken();
    await UserProfileStorage.removeValue();
    await RegistrationStorage.removeValue();
    Get.offAll(() => const SplashScreenLogin());
  }

  Future<void> _deleteAccount() async {
    try {
      await UserProfileService().deleteAccount();
    } catch (e) {}
    await TokenStorage.removeJwtToken();
    await UserProfileStorage.removeValue();
    await RegistrationStorage.removeValue();
    Get.offAll(() => const SplashScreenLogin());
  }

  Future<void> _toggleNotification() async {
    try {
      LoaderHelper.show(context);
      final userProfileService = UserProfileService();
      final updated = await userProfileService.toggleNotification(
        context,
      );
      if (updated != true && user != null) {
        setState(() {
          user?.enablePushNotification = !user!.enablePushNotification;
        });
        ToastHelper.showErrorToast(context, unknownError);
      }
      final userProfile = await userProfileService.getUserProfile(null);
      if (userProfile == null) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }
      setState(() {
        user = userProfile;
      });
      final jsonMap = userProfile.toJson();
      UserProfileStorage.setValue(jsonEncode(jsonMap));
    } finally {
      LoaderHelper.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: universalWhitePrimary,
        surfaceTintColor: universalWhitePrimary,
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        //   child: Image.asset("assets/icons/arrow.png").onTap(() {
        //     if (user?.profileTypeId != PhotographerTypeId) {
        //       Get.offAll(() => HomeUserScreen());
        //     } else {
        //       Get.offAll(() => HomePhotoGrapherScreen());
        //     }
        //   }),
        // ),
      ),
      backgroundColor: universalWhitePrimary,
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2.0),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: user == null
                          ? null
                          : CachedNetworkImageProvider(user!.imageUrl),
                    ),
                    const Text(
                      'Edit my profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: (bold),
                      ),
                    )
                        .box
                        .roundedLg
                        .color(universalColorPrimaryDefault)
                        .padding(const EdgeInsets.only(
                            top: 12, bottom: 12, left: 20, right: 20))
                        .make()
                        .onTap(() {
                      Get.to(() => const ProfileScreen(fromHome: true))
                          ?.then((value) => _loadUserProfile());
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "${user == null ? "" : user!.name}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 35.0,
                    fontFamily: bold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              15.heightBox,
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account",
                        style: TextStyle(
                            fontSize: 15,
                            color: universalGary,
                            fontFamily: milligramRegular),
                      ),
                      5.heightBox,
                      ListTile(
                        shape: Border(
                            left: BorderSide(color: universalGary, width: 1),
                            right: BorderSide(color: universalGary, width: 1),
                            top: BorderSide(color: universalGary, width: 1)),
                        leading: Image.asset(
                          'assets/icons/Email-Icon.png',
                          width: 25,
                        ),
                        title: "Email"
                            .text
                            .size(15)
                            .fontFamily(milligramRegular)
                            .make(),
                        trailing: SizedBox(
                          width: 185,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 160,
                                child: Text(
                                  "${user == null ? "" : user!.email}",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: milligramRegular,
                                    color: universalColorPrimaryDefault,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 25,
                                color: universalGary,
                              ),
                            ],
                          ),
                        ),
                      ).box.make(),

                      ListTile(
                        leading: Image.asset(
                          'assets/icons/password-Icon.png',
                          width: 25,
                        ),
                        title: "Password"
                            .text
                            .size(15)
                            .fontFamily(milligramRegular)
                            .make(),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 25,
                          color: universalGary,
                        ),
                      )
                          .box
                          .border(color: universalGary, width: 1.0)
                          .make()
                          .onTap(() {
                        Get.to(() => ChangePassword(user: user!))
                            ?.then((value) => _loadUserProfile());
                      }),
                      //  7.heightBox,
                      //  Text("Payment",style: TextStyle(fontSize: 15,color: universalGary,fontFamily: regular),),
                      // 7.heightBox,
                      // ListTile(
                      //   leading:  Icon(Icons.shield,size: 30,color: universalGary,),
                      //   title: "Update Stripe Payment Details"
                      //       .text
                      //       .size(15)
                      //       .fontFamily(milligramRegular)
                      //       .make()
                      //       .onTap(() {
                      //     Get.to(() => ContactUsScreen(user: user!));
                      //   }),
                      // ).box.border(color: universalGary,width: 1.0).make(),
                      7.heightBox,
                      Text(
                        "Notifications",
                        style: TextStyle(
                            fontSize: 15,
                            color: universalGary,
                            fontFamily: regular),
                      ),
                      7.heightBox,
                      ListTile(
                        leading: Image.asset(
                          'assets/icons/Push-Icon.png',
                          width: 25,
                        ),
                        title: "Push notifications"
                            .text
                            .size(15)
                            .fontFamily(milligramRegular)
                            .make(),
                        trailing: Switch(
                          value: user == null
                              ? false
                              : user!.enablePushNotification,
                          activeTrackColor: universalColorPrimaryDefault,
                          activeColor: universalWhitePrimary,
                          onChanged: (value) async {
                            // setState(() {
                            //   user?.enablePushNotification =
                            //       !user!.enablePushNotification;
                            // });

                            await _toggleNotification();
                          },
                        ),
                      ).box.border(color: universalGary, width: 1.0).make(),
                      7.heightBox,
                      Text(
                        "Contact",
                        style: TextStyle(
                            fontSize: 15,
                            color: universalGary,
                            fontFamily: regular),
                      ),
                      7.heightBox,
                      ListTile(
                        leading: Image.asset(
                          'assets/icons/Contact-Icon.png',
                          width: 25,
                        ),
                        title: "Contact us"
                            .text
                            .size(15)
                            .fontFamily(milligramRegular)
                            .make()
                            .onTap(() {
                          Get.to(() => ContactUsScreen(user: user!));
                        }),
                      ).box.border(color: universalGary, width: 1.0).make(),
                      7.heightBox,
                      Text(
                        "Log out",
                        style: TextStyle(
                            fontSize: 15,
                            color: universalGary,
                            fontFamily: milligramRegular,
                            fontWeight: FontWeight.w500),
                      ),
                      7.heightBox,
                      ListTile(
                        shape: Border(
                            left: BorderSide(color: universalGary, width: 1),
                            right: BorderSide(color: universalGary, width: 1),
                            top: BorderSide(color: universalGary, width: 1)),
                        leading: Image.asset(
                          'assets/icons/Logout-Icon.png',
                          width: 25,
                        ),
                        title: "Logout of Swarm"
                            .text
                            .size(15)
                            .fontFamily(milligramRegular)
                            .make(),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 25,
                          color: universalGary,
                        ),
                      ).box.make().onTap(() async {
                        await _logout();
                      }),
                      ListTile(
                        leading: Icon(
                          Icons.delete_sweep,
                          size: 30,
                          color: universalGary,
                        ),
                        title: "Delete account"
                            .text
                            .size(15)
                            .fontFamily(milligramRegular)
                            .make(),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 25,
                          color: universalGary,
                        ),
                      )
                          .box
                          .border(color: universalGary, width: 1.0)
                          .make()
                          .onTap(() async {
                        await showGeneralDialog(
                          context: context,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AlertDialog(
                            backgroundColor: universalWhitePrimary,
                            surfaceTintColor: universalWhitePrimary,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      "Delete this account?",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: milligramBold,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 8),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Text(
                                          'Just wanted to confirm that you’d like to proceed?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: milligramRegular),
                                        )),
                                    SizedBox(height: 8),
                                  ],
                                ),
                                SizedBox(width: 350, child: Divider()),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      onTap: () async => await _deleteAccount(),
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                          fontFamily: milligramBold,
                                          fontSize: 22,
                                          color: universalColorPrimaryDefault,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      child: VerticalDivider(),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog after action
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontFamily: milligramBold,
                                          fontSize: 22,
                                          color:
                                              universalColorPrimaryDefault, // Optional: Different color for emphasis
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context)
                              .modalBarrierDismissLabel,
                          barrierColor: Colors.black45,
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, 1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              )),
                              child: child,
                            );
                          },
                          transitionDuration: Duration(milliseconds: 300),
                        );
                      }),
                      18.heightBox
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
