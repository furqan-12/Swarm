import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swarm/services/order_service.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/services/response/user.dart';
import 'package:swarm/utils/loader.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/common/our_button.dart';
import 'package:swarm/views/photographer/home_photographer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../consts/consts.dart';

class UploadSecondShoot extends StatefulWidget {
  final PhotographerOrder order;
  final UserProfile? user;
  const UploadSecondShoot(
      {super.key,
      required PhotographerOrder this.order,
      UserProfile? this.user});

  @override
  State<UploadSecondShoot> createState() => _UploadSecondShootState();
}

class SwarmFile {
  String? id;
  File? file;
  bool isVideo;
  File? thumbNail;
  String? imageUrl;
  String? thumbNailImageUrl;
  SwarmFile(
      {required this.isVideo,
      this.file,
      this.thumbNail,
      this.imageUrl,
      this.thumbNailImageUrl,
      this.id});
}

class _UploadSecondShootState extends State<UploadSecondShoot> {
  List<SwarmFile?> _imageFiles = List.generate(18, (_) => null);
  bool dialogShown = false;
  List<String> deleteUploadedPhoto = [];

  @override
  void dispose() {
    for (int i = 0; i < _imageFiles.length; i++) {}
    LoaderHelper.hide();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    _loadOrderPhotos();
  }

  Future<void> _loadOrderPhotos() async {
    var photos = widget.order.orderPhotos
        .where((element) => element.isLocked == true)
        .toList();
    _imageFiles = [];
    for (var photo in photos) {
      _imageFiles.add(SwarmFile(
          file: null,
          imageUrl: photo.imagePath,
          thumbNail: null,
          thumbNailImageUrl: photo.thumbnailPath,
          isVideo: photo.isVideo!,
          id: photo.id));
    }

    if (_imageFiles.length < 18) {
      do {
        _imageFiles.add(null);
      } while (_imageFiles.length < 18);
    }
    setState(() {
      _imageFiles = _imageFiles;
    });
  }

  Future<void> _openImagePicker(
      BuildContext context, ImageSource source, int index) async {
    if (source == ImageSource.camera) {
      final pickedImage = await ImagePicker().pickImage(source: source);

      if (pickedImage != null) {
        if (_imageFiles[index]?.id != null &&
            !deleteUploadedPhoto.contains(_imageFiles[index]?.id)) {
          deleteUploadedPhoto.add(_imageFiles[index]!.id!);
        }
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
            if (i >= 18) {
              break;
            }
            if (_imageFiles[index]?.id != null &&
                !deleteUploadedPhoto.contains(_imageFiles[index]?.id)) {
              deleteUploadedPhoto.add(_imageFiles[index]!.id!);
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

  Future<void> uploadOrderPhotos() async {
    LoaderHelper.show(context);
    try {
      for (var imageFile
          in _imageFiles.where((e) => e != null && e.file != null)) {
        await OrderService().uploadOrderPhoto(context, widget.order.id, true,
            imageFile!.file!, imageFile.thumbNail);
      }
      for (var orderPhotoId in deleteUploadedPhoto) {
        await OrderService()
            .deleteUploadedOrderPhoto(context, widget.order.id, orderPhotoId);
      }
      final orderService = OrderService();
      final isShared =
          await orderService.sharePortfolio(context, widget.order.id);
      if (isShared == null) {
        ToastHelper.showErrorToast(context, unknownError);
        return;
      } else {
        ToastHelper.showSuccessToast(
            context,
            Icon(Icons.check, color: universalWhitePrimary, size: 40)
                .box
                .roundedFull
                .padding(EdgeInsets.all(7))
                .color(universalColorPrimaryDefault)
                .make(),
            "Success!",
            "${widget.order.customerName}’s shoot has been shared.",
            "Back to schedule", () {
          Get.offAll(const HomePhotoGrapherScreen());
        });
      }
    } catch (e) {
    } finally {
      LoaderHelper.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // dialogShown =
      //     KeyValueStorage.getValue(widget.order.id + "UploadSecondShoot") != "";
      if (dialogShown == false)
        ToastHelper.showSuccessToast(
            context,
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 40,
              backgroundImage: AssetImage(
                "assets/icons/universal-done-small.png",
              ),
            ),
            "Next, upload the outtakes.",
            "Upload additional raw images from the shoot. Your customer will be able to unlock these.",
            "Upload now", () {
          Navigator.of(context).pop();
          showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) =>
                AlertDialog(
              backgroundColor: universalWhitePrimary,
              surfaceTintColor: universalWhitePrimary,
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
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
                        style:
                            TextStyle(fontSize: 20, fontFamily: milligramBold),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                  SizedBox(width: 350, child: Divider()),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _openImagePicker(context, ImageSource.gallery, 0);
                    },
                    child: Text(
                      'Upload images',
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
                      _openVideoPicker(context, ImageSource.gallery, 0);
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
                ],
              ),
            ),
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black45,
            transitionBuilder: (context, animation, secondaryAnimation, child) {
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
        });
      dialogShown = true;
      // KeyValueStorage.setValue(widget.order.id + "UploadSecondShoot", "true");
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: universalWhitePrimary,
        surfaceTintColor: universalWhitePrimary,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          child: Image.asset("assets/icons/arrow.png").onTap(() {
            Navigator.pop(context);
          }),
        ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Center(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: widget.user == null
                    ? CachedNetworkImageProvider(
                        widget.order.customerProfileImage!)
                    : null,
              ),
            ),
            10.heightBox,
            Align(
              alignment: Alignment.centerLeft,
              child: "${widget.order.customerName}'s shoot"
                  .text
                  .fontFamily(milligramBold)
                  .color(universalBlackPrimary)
                  .size(36)
                  .make(),
            ),
            10.heightBox,
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  "${widget.order.shootLengthName}, "
                      .text
                      .fontFamily(milligramRegular)
                      .color(universalBlackSecondary)
                      .size(14)
                      .make(),
                  "${widget.order.shootTypeName}, "
                      .text
                      .fontFamily(milligramRegular)
                      .color(universalBlackSecondary)
                      .size(14)
                      .make(),
                  "${widget.order.shootSceneName}"
                      .text
                      .fontFamily(milligramRegular)
                      .color(universalBlackSecondary)
                      .size(14)
                      .make(),
                ],
              ),
            ),
            10.heightBox,
            Expanded(
              child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: _imageFiles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4),
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          showGeneralDialog(
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
                                          context, ImageSource.gallery, index);
                                    },
                                    child: Text(
                                      'Open Image Gallery',
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
                                      _openVideoPicker(
                                          context, ImageSource.gallery, index);
                                    },
                                    child: Text(
                                      'Open Video Gallery',
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
                                            child: _imageFiles[index]!
                                                        .isVideo ==
                                                    true
                                                ? Stack(children: [
                                                    _imageFiles[index]!
                                                                .thumbNail ==
                                                            null
                                                        ? CachedNetworkImage(
                                                            fadeInDuration:
                                                                const Duration(
                                                                    seconds: 1),
                                                            imageUrl: _imageFiles[
                                                                    index]!
                                                                .thumbNailImageUrl!,
                                                            fit: BoxFit.cover,
                                                            height: 200,
                                                            width: 200,
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Center(
                                                              child:
                                                                  const CircularProgressIndicator(
                                                                color:
                                                                    universalColorPrimaryDefault,
                                                              ),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Icon(
                                                              Icons.error,
                                                              color:
                                                                  specialError,
                                                            ),
                                                          )
                                                        : Image.file(
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
                                                : _imageFiles[index]!.file ==
                                                        null
                                                    ? CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                seconds: 1),
                                                        imageUrl:
                                                            _imageFiles[index]!
                                                                .imageUrl!,
                                                        fit: BoxFit.cover,
                                                        height: 200,
                                                        width: 200,
                                                        placeholder:
                                                            (context, url) =>
                                                                Center(
                                                          child:
                                                              const CircularProgressIndicator(
                                                            color:
                                                                universalColorPrimaryDefault,
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                          Icons.error,
                                                          color: specialError,
                                                        ),
                                                      )
                                                    : Image.file(
                                                        _imageFiles[index]!
                                                            .file!,
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
            20.heightBox,
            ourButton(
              color: universalColorPrimaryDefault,
              title: "Upload",
              textColor: universalBlackPrimary,
              onPress: () async {
                uploadOrderPhotos();
              },
            ).box.width(context.screenWidth - 50).height(50).rounded.make(),
            20.heightBox
          ],
        )
            .box
            .white
            .rounded
            .padding(const EdgeInsets.only(left: 15, right: 15))
            .shadowSm
            .make(),
      ),
    );
  }
}
