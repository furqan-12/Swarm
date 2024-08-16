import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swarm/consts/consts.dart';

class AllMapScreen extends StatefulWidget {
  const AllMapScreen({super.key});

  @override
  State<AllMapScreen> createState() => _AllMapScreenState();
}

class _AllMapScreenState extends State<AllMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(children: [
      GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.black.withOpacity(
              0.0), // Set the button's background color with transparency
          height: 60,

          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
              child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: universalWhitePrimary,
                elevation: 0,
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 15, bottom: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () {},
            child: "View on list"
                .text
                .color(universalBlackPrimary)
                .fontFamily(milligramBold)
                .size(15)
                .make(),
          )),
        ),
      ),
    ]));
  }
}
