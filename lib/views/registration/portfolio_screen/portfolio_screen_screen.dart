import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/registration/connect_stripe/connect_stripe.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/portfolio_service.dart';
import 'package:swarm/utils/loader.dart';

import '../../../services/photographer_service.dart';
import '../../../storage/registration_storage.dart';
import '../../common/our_button.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class SwarmFile {
  File file;
  bool isVideo;
  File? thumbNail;
  SwarmFile({required this.file, required this.isVideo, this.thumbNail});
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<SwarmFile?> _imageFiles = List.generate(12, (_) => null);

  @override
  void dispose() {
    for (int i = 0; i < _imageFiles.length; i++) {}
    LoaderHelper.hide();
    super.dispose();
  }

  Future<void> _openImagePicker(
      BuildContext context, ImageSource source, int index) async {
    if (source == ImageSource.camera) {
      final pickedImage = await ImagePicker().pickImage(source: source);

      if (pickedImage != null) {
        setState(() {
          _imageFiles[index] =
              SwarmFile(file: File(pickedImage.path), isVideo: false);
        });
      }
    } else {
      final List<XFile>? pickedImages = await ImagePicker().pickMultiImage();
      if (pickedImages != null) {
        setState(() {
          for (var i = index; i < index + pickedImages.count(); i++) {
            if (i >= 12) {
              break;
            }
            _imageFiles[i] = SwarmFile(
                file: File(pickedImages[i - index].path), isVideo: false);
          }
        });
      }
    }
  }

  Future<void> _openVideoPicker(
      BuildContext context, ImageSource source, int index) async {
    final pickedImage = await ImagePicker()
        .pickVideo(source: source, maxDuration: Duration(seconds: 30));

    if (pickedImage != null) {
      try {
        var file = File(pickedImage.path);
        String? thumbnail = await VideoThumbnail.thumbnailFile(
          video: file.path,
          headers: {
            "USERHEADER1": "user defined header1",
            "USERHEADER2": "user defined header2",
          },
          imageFormat: ImageFormat.JPEG,
          maxHeight: 500,
          maxWidth: 500,
          quality: 100,
        );
        setState(() {
          _imageFiles[index] =
              SwarmFile(file: file, isVideo: true, thumbNail: File(thumbnail!));
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> setProfileInfo() async {
    if (_imageFiles.where((element) => element != null).isEmpty) {
      ToastHelper.showErrorToast(
          context, "Please upload your portfolio first.");
      return;
    }

    final registration = await RegistrationStorage.getRegistrationModel;
    if (registration != null) {
      try {
        LoaderHelper.show(context);
        final portfolioService = PortfolioService();

        for (var imageFile in _imageFiles.where((element) => element != null)) {
          await portfolioService.addPortfolioImage(
              context, imageFile!.file, imageFile.thumbNail);
        }

        final service = PhotographerService();
        final response = await service.updateProfile(context, registration);
        if (response as bool == true) {
          Get.to(() => ConnectStripe());
        }
      } finally {
        LoaderHelper.hide();
      }
    }
  }

  String getImageName(File? imageFile) {
    if (imageFile == null) return "";
    // Get the file name with extension
    String fileNameWithExtension = imageFile.path.split('/').last;
    // Get the file name without extension
    return fileNameWithExtension.split('.').first;
  }

  String getImageExtension(File? imageFile) {
    if (imageFile == null) return "";
    // Get the file name with extension
    String fileNameWithExtension = imageFile.path.split('/').last;
    // Get the file extension
    return fileNameWithExtension.split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      width: 240,
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
                    style: TextStyle(
                        fontSize: 14, color: universalColorPrimaryDefault),
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
      body: Column(
        children: [
          10.heightBox,
          Align(
              alignment: Alignment.centerLeft,
              child: "Portfolio"
                  .text
                  .fontFamily(milligramBold)
                  .black
                  .size(40)
                  .make()),
          10.heightBox,
          Expanded(
            child: GridView.builder(
                shrinkWrap: true,
                itemCount: _imageFiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4),
                itemBuilder: (context, index) {
                  return InkWell(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                        context, ImageSource.gallery, index);
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
                                if (_imageFiles
                                            .where((element) =>
                                                element != null &&
                                                element.isVideo)
                                            .length <
                                        3 ||
                                    (_imageFiles[index] != null &&
                                        _imageFiles[index]!.isVideo == true))
                                  SizedBox(width: 350, child: Divider()),
                                if (_imageFiles
                                            .where((element) =>
                                                element != null &&
                                                element.isVideo)
                                            .length <
                                        3 ||
                                    (_imageFiles[index] != null &&
                                        _imageFiles[index]!.isVideo == true))
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _openVideoPicker(
                                          context, ImageSource.gallery, index);
                                    },
                                    child: Text(
                                      'Upload video',
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
                                        context, ImageSource.camera, index);
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
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(
                              1.0), // Adjust the spacing here
                          child: Center(
                                  child: _imageFiles[index] != null
                                      ? Container(
                                          width: 200,
                                          height: 200,
                                          decoration: const BoxDecoration(
                                              color: universalBlackCell),
                                          child: _imageFiles[index]!.isVideo ==
                                                  true
                                              ? Stack(children: [
                                                  Image.file(
                                                    _imageFiles[index]!
                                                        .thumbNail!,
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  const Positioned(
                                                      bottom: 10,
                                                      left: 15,
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        color:
                                                            universalBlackCell,
                                                      )),
                                                ])
                                              : Image.file(
                                                  _imageFiles[index]!.file,
                                                  width: 200.0,
                                                  height: 200.0,
                                                  fit: BoxFit.cover,
                                                ))
                                      : Container(
                                          width: 200,
                                          height: 200,
                                          decoration: const BoxDecoration(
                                              color: universalBlackCell),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: universalBlackCell),
                                            width: 200,
                                            height: 200,
                                            child: Image.asset(
                                              "assets/icons/cameraiconsm.png",
                                              width: 50,
                                              height: 50,
                                              color: universalBlackPrimary,
                                            ),
                                          ),
                                        ))
                              .box
                              .color(universalBlackCell)
                              .make()));
                }),
          ),
          ourButton(
            color: universalColorPrimaryDefault,
            title: "Continue",
            textColor: universalBlackPrimary,
            onPress: () async {
              await setProfileInfo();
            },
          ).box.width(context.screenWidth - 50).height(50).rounded.make(),
        ],
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
