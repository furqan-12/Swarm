import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/order_service.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/utils/toast_utils.dart';
import '../../../../utils/loader.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:swarm/utils/image_helper.dart';

class FullImageScreen extends StatefulWidget {
  final PhotographerOrder order;
  final List<OrderPhoto> orderPhotos;
  final int selectedIndex;
  FullImageScreen({
    super.key,
    required this.orderPhotos,
    required this.selectedIndex,
    required this.order,
  });

  @override
  State<FullImageScreen> createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> {
  Dio dio = Dio();
  late PageController _pageController;
  int currentPage = 0;

  @override
  void dispose(){
    LoaderHelper.hide();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currentPage = widget.selectedIndex;
    _pageController = PageController(initialPage: currentPage);
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

  Future<bool> shareFile(String url, String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        await _requestPermission(Permission.storage);
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        await dio.download(
          url,
          saveFile.path,
        );
        // if (Platform.isIOS) {
        //   await ImageGallerySaver.saveFile(saveFile.path,
        //       isReturnPathOfIOS: true);
        // }
        await Share.shareXFiles([XFile(saveFile.path)]);
        return true;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }

  Future<void> _shareFile(String imageUrl) async {
    try {
      LoaderHelper.show(context);
      await shareFile(imageUrl, getImageNameString(imageUrl));
    } catch (e) {
      ToastHelper.showErrorToast(context, e.toString());
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<bool> downloadImage(String url, String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        await _requestPermission(Permission.storage);
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        await dio.download(
          url,
          saveFile.path,
        );
        await ImageGallerySaver.saveFile(saveFile.path,
            isReturnPathOfIOS: true);
        // await Share.shareXFiles([XFile(saveFile.path)]);
        return true;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      LoaderHelper.show(context);
      var downloaded =
          await downloadImage(imageUrl, getImageNameString(imageUrl));
      if (downloaded) {
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
            "Downloaded to your phone.",
            "Back", () {
          Get.back();
        });
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, e.toString());
    } finally {
      LoaderHelper.hide();
    }
  }

  Future<void> deleteImage(String id) async {
    var deleted =
        await OrderService().deleteOrderPhoto(context, widget.order.id, id);
    if (deleted == true) {
      Get.back<String>(result: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 45),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${formatDateOnlyLong(widget.order.orderDateTime)}",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: milligramBold,
                    color: universalBlackSecondary,
                  ),
                ),
                Text(
                  "${widget.order.shootLengthName}, ${widget.order.shootTypeName}, ${widget.order.shootSceneName}",
                  style: TextStyle(
                    fontSize: 17,
                    color: universalBlackSecondary,
                  ),
                ),
              ],
            ),
          ),
          15.heightBox,
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.orderPhotos.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return CachedNetworkImage(
                      fadeInDuration: const Duration(seconds: 1),
                      imageUrl: widget.orderPhotos[index].imagePath!,
                      fit: BoxFit.contain,
                      fadeInCurve: Curves.bounceInOut,
                      width: double.infinity,
                      height: 600,
                      placeholder: (context, url) => Center(
                        child: const CircularProgressIndicator(
                          color: universalColorPrimaryDefault,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: specialError,
                      ),
                      // Placeholder and error widgets can be added as needed
                    );
                  },
                ),
                Positioned(
                  bottom: 10.0,
                  left: 20.0,
                  child: FloatingActionButton(
                    backgroundColor: universalWhitePrimary,
                    elevation: 0,
                    onPressed: () async {
                      await _downloadImage(
                          widget.orderPhotos[widget.selectedIndex].imagePath!);
                    },
                    child: Image.asset(
                      "assets/icons/downloadIcn.png",
                      width: 35,
                      height: 35,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10.0,
                  left: 95.0,
                  child: FloatingActionButton(
                    backgroundColor: universalWhitePrimary,
                    elevation: 0,
                    onPressed: () async {
                      await _shareFile(
                          widget.orderPhotos[widget.selectedIndex].imagePath!);
                    },
                    child: Image.asset(
                      "assets/icons/shareIcn.png",
                      width: 35,
                      height: 35,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10.0,
                  right: 20.0,
                  child: FloatingActionButton(
                    backgroundColor: universalWhitePrimary,
                    elevation: 0,
                    onPressed: () async {
                      await deleteImage(
                        widget.orderPhotos[widget.selectedIndex].id,
                      );
                    },
                    child: Image.asset(
                      "assets/icons/deleteIcn.png",
                      width: 35,
                      height: 35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
