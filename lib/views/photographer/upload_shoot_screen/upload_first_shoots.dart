import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swarm/consts/api.dart';
import 'package:swarm/services/order_service.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/services/response/user.dart';
import 'package:swarm/utils/loader.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/common/our_button.dart';
import 'package:swarm/views/photographer/upload_shoot_screen/upload_second_shoots.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../consts/consts.dart';

class UploadFirstShoot extends StatefulWidget {
  final PhotographerOrder order;
  final UserProfile? user;
  const UploadFirstShoot(
      {super.key,
      required PhotographerOrder this.order,
      UserProfile? this.user});

  @override
  State<UploadFirstShoot> createState() => _UploadFirstShootState();
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

class _UploadFirstShootState extends State<UploadFirstShoot> {
  List<SwarmFile?> _imageFiles = List.generate(9, (_) => null);
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
    if (widget.order.shootTypeName != "Video") {
      setState(() {
        _imageFiles = List.generate(widget.order.shootLength * 9, (_) => null);
      });
    }

    if (widget.order.shootTypeName == "Video") {
      setState(() {
        _imageFiles = List.generate(1, (_) => null);
      });
    }
    _loadOrderPhotos();
  }

  Future<void> _loadOrderPhotos() async {
    var photos = widget.order.orderPhotos
        .where((element) => element.isLocked == false)
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
    if (widget.order.shootTypeName != "Video" &&
        _imageFiles.length < widget.order.shootLength * 9) {
      do {
        _imageFiles.add(null);
      } while (_imageFiles.length < widget.order.shootLength * 9);
    }

    if (widget.order.shootTypeName == "Video" && _imageFiles.length < 1) {
      _imageFiles.add(null);
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
            if (i >= widget.order.shootLength * 9) {
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
        if (_imageFiles[index]?.id != null &&
            !deleteUploadedPhoto.contains(_imageFiles[index]?.id)) {
          deleteUploadedPhoto.add(_imageFiles[index]!.id!);
        }
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
        await OrderService().uploadOrderPhoto(context, widget.order.id, false,
            imageFile!.file!, imageFile.thumbNail);
      }
      for (var orderPhotoId in deleteUploadedPhoto) {
        await OrderService()
            .deleteUploadedOrderPhoto(context, widget.order.id, orderPhotoId);
      }
      Get.to(() => UploadSecondShoot(order: widget.order, user: widget.user))!
          .then((value) => {_loadData()});
    } catch (e) {
    } finally {
      LoaderHelper.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // dialogShown =
      //     KeyValueStorage.getValue(widget.order.id + "UploadFirstShoot") != "";
      if (widget.order.shootTypeName != "Video" && dialogShown == false)
        ToastHelper.showSuccessToast(
            context,
            Image.asset("assets/icons/cameraicon.png", width: 70, height: 70),
            "First, upload ${widget.order.shootLength * 9} ${widget.order.experienceId == Experiences["Starter"] ? "unedited" : "edited"} shots.",
            "Your customer paid for ${widget.order.shootLength * 9} ${widget.order.experienceId == Experiences["Starter"] ? "unedited" : "edited"} images.",
            "Upload now", () {
          Navigator.of(context).pop();
          if (widget.order.shootTypeName != "Video") {
            _openImagePicker(context, ImageSource.gallery, 0);
          }
          if (widget.order.shootTypeName == "Video") {
            _openVideoPicker(context, ImageSource.gallery, 0);
          }
        });

      if (widget.order.shootTypeName == "Video" && dialogShown == false)
        ToastHelper.showSuccessToast(
            context,
            Image.asset("assets/icons/cameraicon.png", width: 70, height: 70),
            "First, upload a ${widget.order.shootLength * 3}-${widget.order.shootLength * 5} mins ${widget.order.experienceId == Experiences["Starter"] ? "raw" : "edited"} video.",
            "Your customer paid for ${widget.order.shootLength * 3}-${widget.order.shootLength * 5} mins of ${widget.order.experienceId == Experiences["Starter"] ? "raw" : "edited"} video.",
            "Upload now", () {
          Navigator.of(context).pop();
          if (widget.order.shootTypeName != "Video") {
            _openImagePicker(context, ImageSource.gallery, 0);
          }
          if (widget.order.shootTypeName == "Video") {
            _openVideoPicker(context, ImageSource.gallery, 0);
          }
        });
      dialogShown = true;
      // KeyValueStorage.setValue(widget.order.id + "UploadFirstShoot", "true");
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
                          if (widget.order.shootTypeName != "Video") {
                            _openImagePicker(
                                context, ImageSource.gallery, index);
                          }
                          if (widget.order.shootTypeName == "Video") {
                            _openVideoPicker(
                                context, ImageSource.gallery, index);
                          }
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
                                                        width: 200,
                                                        height: 200,
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
            if (!_imageFiles.any((e) => e == null)) 20.heightBox,
            if (!_imageFiles.any((e) => e == null))
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
