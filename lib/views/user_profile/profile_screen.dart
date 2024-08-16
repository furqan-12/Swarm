import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swarm/consts/api.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/user_profile_service.dart';
import 'package:swarm/utils/toast_utils.dart';

import '../../services/response/user.dart';
import '../../storage/registration_storage.dart';
import '../../storage/user_profile_storage.dart';
import '../registration/my_city_screen/my_city_screen.dart';
import '../common/custom_multilines_text_field.dart';
import '../common/custom_textfield.dart';
import '../common/our_button.dart';

class ProfileScreen extends StatefulWidget {
  final bool fromHome;
  const ProfileScreen({super.key, required this.fromHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  var _profileTypeId = "";
  String? profileImageUrl = "assets/icons/cameraicon.png";
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  UserProfile? user = null;

  Future<void> _openImagePicker(
      BuildContext context, ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      var image = File(pickedImage.path);
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> setProfileInfo() async {
    if (widget.fromHome) {
      if (_formKey.currentState!.validate() == false) {
        return;
      }
    } else {
      if (_formKey.currentState!.validate() == false || _imageFile == null) {
        if (_imageFile == null) {
          ToastHelper.showErrorToast(
              context, 'Please upload your profile image');
        }
        return;
      }
    }

    UserProfileService userProfileService = UserProfileService();
    if (_imageFile != null) {
      final updated = await userProfileService.updateUserProfile(
          context, _usernameController.text, _bioController.text, _imageFile);
      if (updated != true) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }
    } else {
      final updated = await userProfileService.updateUserProfile(
          context, _usernameController.text, _bioController.text, null);
      if (updated != true) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      }
    }
    final userProfile = await userProfileService.getUserProfile(null);
    if (userProfile == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }
    final jsonMap = userProfile.toJson();
    UserProfileStorage.setValue(jsonEncode(jsonMap));

    if (widget.fromHome) {
      ToastHelper.showSuccessToast(
          context,
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40,
            backgroundImage: AssetImage(
              "assets/icons/universal-done-small.png",
            ),
          ),
          "Profile updated!",
          "Your profile has been shared.",
          "Back", () {
        Get.back();
      });
    } else {
      final registration = await RegistrationStorage.getRegistrationModel;
      if (registration != null) {
        registration.userName = _usernameController.text;
        registration.bio = _bioController.text;

        registration.profileImageUrl = userProfile.imageUrl;

        final jsonMap = registration.toJson();

        RegistrationStorage.setValue(jsonEncode(jsonMap));

        Get.to(() => const MyCityScreen());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (widget.fromHome) {
      final userProfile = await UserProfileStorage.getUserProfileModel;
      if (userProfile != null) {
        setState(() {
          user = userProfile;
          _usernameController.text = userProfile.name;
          _bioController.text = userProfile.bio;
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
        setState(() {
          user = userProfile;
          _usernameController.text = userProfile.name;
          _bioController.text = userProfile.bio;
        });
      }
    } else {
      final registration = await RegistrationStorage.getRegistrationModel;
      _profileTypeId = registration!.profileTypeId;
      if (!registration.userName.isEmptyOrNull) {
        setState(() {
          _usernameController.text = registration.userName!;
          _bioController.text = registration.bio!;
          profileImageUrl = registration.profileImageUrl;
        });
      } else {
        setState(() {
          profileImageUrl = "assets/icons/cameraicon.png";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
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
                              width: 50,
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
                            style:
                                TextStyle(fontSize: 14, color: universalGary),
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
        body: Stack(children: [
          SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _profileTypeId == PhotographerTypeId
                        ? 10.heightBox
                        : 36.heightBox,
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Profile"
                            .text
                            .fontFamily(milligramBold)
                            .black
                            .size(40)
                            .make()),
                    10.heightBox,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 8),
                                      const Text(
                                        'Choose an option',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: milligramBold),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                  SizedBox(width: 350, child: Divider()),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _openImagePicker(
                                          context, ImageSource.gallery);
                                    },
                                    child: Text(
                                      'Upload image',
                                      style: TextStyle(
                                        fontFamily: milligramRegular,
                                        fontSize: 22,
                                        color: universalColorPrimaryDefault,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 350, child: Divider()),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _openImagePicker(
                                          context, ImageSource.camera);
                                    },
                                    child: Text(
                                      'Use your camera',
                                      style: TextStyle(
                                        fontFamily: milligramRegular,
                                        fontSize: 22,
                                        color: universalColorPrimaryDefault,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            barrierDismissible: true,
                            barrierLabel: MaterialLocalizations.of(context)
                                .modalBarrierDismissLabel,
                            barrierColor: Colors.black45,
                            transitionBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                        },
                        child: widget.fromHome && _imageFile == null
                            ? CircleAvatar(
                                radius: 70,
                                backgroundColor: universalBlackCell,
                                backgroundImage: user == null
                                    ? null
                                    : CachedNetworkImageProvider(
                                        user!.imageUrl))
                            : CircleAvatar(
                                radius: 60,
                                backgroundColor: universalBlackCell,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : null,
                                child: _imageFile == null
                                    ? Image.asset(
                                        profileImageUrl!,
                                        width: 50,
                                        height: 50,
                                        color: universalBlackPrimary,
                                      )
                                    : null,
                              ),
                      ),
                    ),
                    25.heightBox,
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "Username"
                            .text
                            .fontFamily(milligramBold)
                            .black
                            .size(17)
                            .make()),
                    customTextFiled(
                        hint: "",
                        controller: _usernameController,
                        isRequired: true),
                    15.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "Bio"
                            .text
                            .fontFamily(milligramBold)
                            .black
                            .size(17)
                            .make(),
                      ],
                    ),
                    customMultilineTextFiled(
                        name: "Bio",
                        hint: "Tell us about yourself",
                        controller: _bioController,
                        maxLength: 300),
                    (context.screenHeight * 0.26).heightBox,
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                    )
                  ],
                )
                    .box
                    .white
                    .rounded
                    .padding(const EdgeInsets.only(left: 15, right: 15))
                    .shadowSm
                    .make(),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
              color: universalWhitePrimary,
              child: ourButton(
                color: universalColorPrimaryDefault,
                title: widget.fromHome ? "Update" : "Continue",
                textColor: universalBlackPrimary,
                onPress: () async {
                  setProfileInfo();
                },
              ),
            ),
          ),
        ]));
  }
}
