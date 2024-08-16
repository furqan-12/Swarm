import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/controller/home_controller.dart';
import 'package:swarm/services/order_service.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/storage/key_value_storage.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/utils/image_helper.dart';
import 'package:swarm/utils/loader.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/common/video_player_screen.dart';
import 'package:swarm/views/user/bottom_tab_screen_users/collection_screen/full_image_screen.dart';
import 'package:dio/dio.dart';

import '../home_user.dart';

class CollectionItemDetail extends StatefulWidget {
  final PhotographerOrder order;

  const CollectionItemDetail({super.key, required this.order});

  @override
  State<CollectionItemDetail> createState() => _CollectionItemDetailState();
}

class _CollectionItemDetailState extends State<CollectionItemDetail> {
  List<OrderPhoto> photos = [];
  List<OrderPhoto> videos = [];
  bool showDeleteButton = false;
  bool inSelectionMode =
      false; // Flag to indicate if items are in selection mode
  bool longPressed = false;
  Dio dio = Dio();
  var controller = HomeController.instance;

  @override
  void dispose(){
    LoaderHelper.hide();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadOrderPhotos();
  }

  Future<void> _loadOrderPhotos() async {
    var id = await KeyValueStorage.getValue("user-collections-viewed");
    var orderIds = id.split(',');
    if (!orderIds.any((id) => id == widget.order.id)) {
      await KeyValueStorage.setValue(
          "user-collections-viewed", "${id},${widget.order.id}");
      controller.newCompletedOrders.value =
          controller.newCompletedOrders.value - 1;
    }
    setState(() {
      photos = widget.order.orderPhotos
          .where((element) =>
              (element.isLocked == false || element.isSharedToCustomer) &&
              element.isVideo == false)
          .toList();
      videos = widget.order.orderPhotos
          .where((element) =>
              (element.isLocked == false || element.isSharedToCustomer) &&
              element.isVideo == true)
          .toList();
    });
  }

  List<String> selectedImages = [];
  List<String> selectedVideos = [];

  void deleteAllImages() {
    var deactivated = OrderService().deactiveOrder(context, widget.order.id);
    if (deactivated == true) {
      setState(() {
        Get.offAll(() => HomeUserScreen());
      });
    }
  }

  Future<void> deleteSelectedImages() async {
    LoaderHelper.show(context);
    setState(() {});
    for (var id in selectedImages) {
      var deleted =
          await OrderService().deleteOrderPhoto(context, widget.order.id, id);
      if (deleted == true) {
        setState(() {
          photos.removeWhere((photo) => photo.id == id);
          videos.removeWhere((video) => video.id == id);
        });
      }
    }
    LoaderHelper.hide();
    setState(() {
      selectedImages = [];
      showDeleteButton = false;
    });
  }

  // Enter selection mode
  void enterSelectionMode() {
    setState(() {
      inSelectionMode = true;
    });
  }

  // Exit selection mode
  void exitSelectionMode() {
    setState(() {
      selectedImages.clear();
      selectedVideos.clear();
      inSelectionMode = false;
    });
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        ToastHelper.showErrorToast(context, "Access permanently denied");
      }
    }
    return false;
  }

  Future<bool> shareFiles() async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        await _requestPermission(Permission.storage);
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }
      if (await directory.exists()) {
        List<XFile> selectedFiles = [];
        for (var i = 0; i < selectedImages.length; i++) {
          var imageUrl =
              photos.firstWhere((e) => e.id == selectedImages[i]).imagePath!;

          var fileName = getImageNameString(imageUrl);

          File saveFile = File(directory.path + "/$fileName");

          await dio.download(imageUrl, saveFile.path);

          selectedFiles.add(XFile(saveFile.path));
          // if (Platform.isIOS) {
          //   await ImageGallerySaver.saveFile(saveFile.path,
          //       isReturnPathOfIOS: true);
          // }
        }
        await Share.shareXFiles(selectedFiles);
        return true;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }

  Future<bool> downloadImage() async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        await _requestPermission(Permission.storage);
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }
      if (await directory.exists()) {
        for (var i = 0; i < selectedImages.length; i++) {
          var imageUrl =
              photos.firstWhere((e) => e.id == selectedImages[i]).imagePath!;

          var fileName = getImageNameString(imageUrl);

          File saveFile = File(directory.path + "/$fileName");

          await dio.download(imageUrl, saveFile.path);

          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }

  Future<void> shareSelectedImages(bool isShare) async {
    try {
      LoaderHelper.show(context);
      setState(() {});
      var saved = false;
      if (isShare) {
        saved = await shareFiles();
      } else {
        saved = await downloadImage();
      }
      if (saved) {
        setState(() {
          selectedImages = [];
          showDeleteButton = false;
        });
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, e.toString());
      print(e);
    } finally {
      LoaderHelper.hide();
      if (isShare == false) {
        ToastHelper.showSuccessToast(
            context,
            CircleAvatar(
            backgroundColor: Colors.white,
                radius: 40,
               backgroundImage: AssetImage(
                          "assets/icons/universal-done-small.png",
                        ),
              ),
            "Downloaded!",
            "Your selections have been downloaded to your phone.",
            "Back to collection", () {
          Get.offAll(HomeUserScreen(index: 1));
        });
      }
    }
  }

  void toggleImageSelection(String id, bool isVideo) {
    setState(() {
      if (isVideo) {
        if (selectedVideos.contains(id)) {
          selectedVideos.remove(id);
        } else {
          selectedVideos.add(id);
        }
      } else {
        if (selectedImages.contains(id)) {
          selectedImages.remove(id);
        } else {
          selectedImages.add(id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5),
          child: Image.asset("assets/icons/arrow.png").onTap(() {
            Navigator.pop(context);
          }),
        ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "${formatDateOnlyLong(widget.order.orderDateTime)}"
                        .text
                        .size(17)
                        .fontFamily(milligramBold)
                        .color(universalBlackSecondary)
                        .center
                        .make(),
                    "${widget.order.shootLengthName}, ${widget.order.shootTypeName}, ${widget.order.shootSceneName} "
                        .text
                        .size(17)
                        .color(universalBlackSecondary)
                        .center
                        .make(),
                  ],
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (inSelectionMode) {
                        exitSelectionMode();
                      } else {
                        enterSelectionMode();
                      }
                    });
                  },
                  child: Text(
                    "Select",
                    style: TextStyle(
                        fontSize: 17,
                        color: universalWhitePrimary,
                        fontFamily: milligramSemiBold),
                  )
                      .box
                      .color(inSelectionMode
                          ? universalColorPrimaryDefault
                          : universalTransblackSecondary)
                      .padding(EdgeInsets.only(
                          left: 12, right: 12, top: 7, bottom: 7))
                      .roundedLg
                      .make(),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          if (photos.length > 0)
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Pics",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: milligramSemiBold),
                                )),
                          if (photos.length > 0) 10.heightBox,
                          if (photos.length > 0)
                            GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: photos.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 2,
                                        crossAxisSpacing: 2),
                                itemBuilder: (context, index) {
                                  OrderPhoto item = photos[index];
                                  bool isSelected =
                                      selectedImages.contains(item.id);
                                  var url = item.imagePath!;
                                  return GestureDetector(
                                    onTap: () {
                                      if (inSelectionMode) {
                                        toggleImageSelection(item.id, false);
                                      } else {
                                        Get.to(() => FullImageScreen(
                                                orderPhotos: photos,
                                                selectedIndex: index,
                                                order: widget.order))!
                                            .then((orderPhotoId) => {
                                                  if (orderPhotoId != null)
                                                    {
                                                      setState(() {
                                                        photos = photos
                                                            .where((e) =>
                                                                e.id !=
                                                                orderPhotoId)
                                                            .toList();
                                                      })
                                                    }
                                                });
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(seconds: 1),
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                          width: context.screenWidth,
                                          height: 174,
                                          placeholder: (context, url) => Center(
                                            child:
                                                const CircularProgressIndicator(
                                              color:
                                                  universalColorPrimaryDefault,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            color: specialError,
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            bottom: 5,
                                            right: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    universalColorPrimaryDefault,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: universalWhitePrimary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                          if (photos.length > 0 && videos.length > 0)
                            5.heightBox,
                          if (photos.length > 0 && videos.length > 0) Divider(),
                          if (photos.length > 0 && videos.length > 0)
                            5.heightBox,
                          if (videos.length > 0)
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Video",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: milligramSemiBold),
                                )),
                          if (videos.length > 0) 10.heightBox,
                          if (videos.length > 0)
                            GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: videos.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 2,
                                        crossAxisSpacing: 2),
                                itemBuilder: (context, index) {
                                  OrderPhoto item = videos[index];
                                  bool isSelected =
                                      selectedVideos.contains(item.id);
                                  var url = item.thumbnailPath!;
                                  return GestureDetector(
                                    onTap: () {
                                      if (inSelectionMode) {
                                        toggleImageSelection(item.id, true);
                                      } else {
                                        Get.to(() => VideoPlayerScreen(
                                                orderPhotos: videos,
                                                selectedIndex: index,
                                                order: widget.order))!
                                            .then((orderPhotoId) => {
                                                  if (orderPhotoId != null)
                                                    {
                                                      setState(() {
                                                        videos = videos
                                                            .where((e) =>
                                                                e.id !=
                                                                orderPhotoId)
                                                            .toList();
                                                      })
                                                    }
                                                });
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(seconds: 1),
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                          width: context.screenWidth,
                                          height: 174,
                                          placeholder: (context, url) => Center(
                                            child:
                                                const CircularProgressIndicator(
                                              color:
                                                  universalColorPrimaryDefault,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            color: specialError,
                                          ),
                                        ),
                                        const Positioned(
                                            bottom: 10,
                                            left: 15,
                                            child: Icon(
                                              Icons.play_arrow,
                                              color: universalBlackCell,
                                            )),
                                        if (isSelected)
                                          Positioned(
                                            bottom: 5,
                                            right: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    universalColorPrimaryDefault,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: universalWhitePrimary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(),
        Positioned(
          left: 0,
          right: 0,
          bottom: 40,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: universalWhitePrimary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (inSelectionMode) SizedBox(width: 10),
                if (inSelectionMode)
                  GestureDetector(
                    onTap: () async {
                      await shareSelectedImages(false);
                    },
                    child: Image.asset(
                      "assets/icons/downloadIcn.png",
                      width: 35,
                      height: 35,
                    ),
                  ),
                if (inSelectionMode) SizedBox(width: 30),
                if (inSelectionMode)
                  GestureDetector(
                    onTap: () async {
                      await shareSelectedImages(true);
                    },
                    child: Image.asset(
                      "assets/icons/shareIcn.png",
                      width: 35,
                      height: 35,
                    ),
                  ),
                Spacer(),
                if (inSelectionMode)
                  GestureDetector(
                    onTap: () async {
                      await deleteSelectedImages();
                    },
                    child: Image.asset(
                      "assets/icons/deleteIcn.png",
                      width: 35,
                      height: 35,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
