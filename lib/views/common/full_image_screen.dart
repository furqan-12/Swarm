import 'package:cached_network_image/cached_network_image.dart';
import 'package:swarm/consts/consts.dart';
import 'package:dio/dio.dart';

class ImageScreen extends StatefulWidget {
  final String imageUrl;
  ImageScreen(this.imageUrl);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Stack(
        children: [
          CachedNetworkImage(
            fadeInDuration: const Duration(seconds: 1),
            imageUrl: widget.imageUrl,
            fit:
                BoxFit.contain, // This makes the image adjust to fit the screen
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Center(
              child: const CircularProgressIndicator(
                color: universalColorPrimaryDefault,
              ),
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.error,
              color: specialError,
            ),
          )
        ],
      ),
    );
  }
}
