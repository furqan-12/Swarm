import 'package:flutter/material.dart';
import 'package:swarm/consts/colors.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerCommonScreen extends StatefulWidget {
  final String videoFilePath;

  VideoPlayerCommonScreen(this.videoFilePath);

  @override
  _VideoPlayerCommonScreenState createState() =>
      _VideoPlayerCommonScreenState();
}

class _VideoPlayerCommonScreenState extends State<VideoPlayerCommonScreen> {
  late VideoPlayerController _controller;
  late Future<void> video;

  @override
  void initState() {
    super.initState();
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoFilePath));
      video = _controller.initialize();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: FutureBuilder(
          future: video,
          builder: (content, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: universalColorPrimaryDefault,
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
