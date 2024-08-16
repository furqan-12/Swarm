import 'dart:io';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swarm/utils/image_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:swarm/consts/consts.dart'; // Make sure these imports are correct
import 'package:swarm/services/order_service.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/date_time_helper.dart';
import 'package:swarm/utils/loader.dart';
import 'package:swarm/utils/toast_utils.dart';

class VideoPlayerScreen extends StatefulWidget {
  final PhotographerOrder order;
  final List<OrderPhoto> orderPhotos;
  final int selectedIndex;

  VideoPlayerScreen({
    Key? key,
    required this.orderPhotos,
    required this.selectedIndex,
    required this.order,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;

  late List<VideoPlayerController> _controllers = [];
  late Future<void> _initializeVideoPlayerFutures;
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selectedIndex);

    _controllers = widget.orderPhotos.map((OrderPhoto orderPhoto) {
      VideoPlayerController controller =
          VideoPlayerController.networkUrl(Uri.parse(orderPhoto.imagePath!));
      return controller;
    }).toList();

    _initializeVideoPlayerFutures =
        Future.wait(_controllers.map((controller) => controller.initialize()));
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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
          200.heightBox,
          SizedBox(
            height: 220,
            child: FutureBuilder(
              future: _initializeVideoPlayerFutures,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: _controllers.length,
                    itemBuilder: (context, index) {
                      return _videoPlayerWidget(_controllers[index]);
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: Row(
          children: [
            FloatingActionButton(
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
            30.widthBox,
            FloatingActionButton(
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
            140.widthBox,
            FloatingActionButton(
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
          ],
        ),
      ),
    );
  }

  Widget _videoPlayerWidget(VideoPlayerController controller) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller)),
        _PlayPauseOverlay(controller: controller),
        Positioned(
          bottom: 10,
          right: 2,
          left: 2,
          child: VideoProgressIndicator(controller, allowScrubbing: true),
        )
      ],
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key? key, required this.controller})
      : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return Stack(
          children: <Widget>[
            AnimatedSwitcher(
              duration: Duration(milliseconds: 50),
              reverseDuration: Duration(milliseconds: 200),
              child: controller.value.isPlaying
                  ? SizedBox.shrink()
                  : Container(
                      color: Color.fromARGB(91, 0, 0, 0),
                      child: Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: universalWhitePrimary,
                          size: 100.0,
                          semanticLabel: 'Play',
                        ),
                      ),
                    ),
            ),
            GestureDetector(
              onTap: () {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
              },
            ),
          ],
        );
      },
    );
  }
}
