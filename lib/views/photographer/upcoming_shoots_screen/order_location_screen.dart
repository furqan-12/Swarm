import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/photographer_order.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderLocationScreen extends StatefulWidget {
  final PhotographerOrder order;
  OrderLocationScreen({super.key, required this.order});

  @override
  State<OrderLocationScreen> createState() => _OrderLocationScreenState();
}

class _OrderLocationScreenState extends State<OrderLocationScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  CameraPosition? cameraPosition;
  String location = "";
  String shortLocation = "";
  bool showSearchBar = false; // Add this variable
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDgDmokwROJK2UwL5liPOhlpFrtVjPjx94');

  @override
  void dispose() {
    _mapControllerCompleter.future.then((controller) => controller.dispose());
    _places.dispose();
    super.dispose();
  }

  @override
  void initState() {
    addCustomIcon();
    super.initState();
    Future.delayed(Duration.zero, () {
      _getOrder();
    });
  }

  Future<void> _getOrder() async {
    setState(() {
      _currentLocation = LatLng(widget.order.latitude, widget.order.longitude);
    });
    _getAddress(widget.order.latitude, widget.order.longitude);
  }

  void openGoogleMapsApp(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    Uri googleUri = Uri.parse(googleUrl);

    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri);
    } else {
      ToastHelper.showErrorToast(context, 'Could not launch Google Maps app');
    }
  }

  Future<void> _getAddress(double latitude, double longitude) async {
    //when map drag stops
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    Placemark currentPlace = placemarks[0];

    setState(() {
      _selectedLocation = LatLng(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        String address =
            '${currentPlace.street} ${currentPlace.name != currentPlace.street ? currentPlace.name : ""}, ${currentPlace.subLocality.isEmptyOrNull ? currentPlace.subAdministrativeArea : currentPlace.subLocality},  ${currentPlace.locality.isEmptyOrNull ? currentPlace.administrativeArea : currentPlace.locality} ${currentPlace.postalCode}, ${currentPlace.isoCountryCode}';
        location = address;
        shortLocation =
            "${currentPlace.street} ${currentPlace.name != currentPlace.street ? currentPlace.name : ""}";
        showSearchBar = false;
      }
    });
  }

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/icons/marker-big.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            child: Image.asset("assets/icons/arrow.png").onTap(() {
              Navigator.pop(context);
            }),
          ),
          surfaceTintColor: universalWhitePrimary,
          backgroundColor: universalWhitePrimary,
          toolbarHeight: 80,
          title: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight + 20),
              child: Wrap(spacing: 4.0, children: []))),
      backgroundColor: universalWhitePrimary,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 50, bottom: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: "Shoot location"
                      .text
                      .fontFamily(milligramBold)
                      .black
                      .size(40)
                      .make(),
                ),
              ),
              Expanded(
                child: GoogleMap(
                  zoomGesturesEnabled: true,
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _mapControllerCompleter.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 17.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("marker1"),
                      position: _currentLocation!,
                      icon: markerIcon,
                    ),
                    Marker(
                      markerId: const MarkerId("marker1"),
                      position: _currentLocation!,
                      icon: markerIcon,
                    ),
                  },
                  // onCameraMove: (CameraPosition cameraPositiona) {
                  //   setState(() {
                  //     cameraPosition = cameraPositiona; //when map is dragging
                  //   });
                  // },
                  // onCameraIdle: () async {
                  //   // if (cameraPosition != null) {
                  //   //   await _getAddress(cameraPosition!.target.latitude,
                  //   //       cameraPosition!.target.longitude);
                  //   // }
                  // },
                ),
              ),
            ],
          ),
          // Positioned(
          //   // Place the marker at the center of the map
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   top: 120,
          //   child: Center(
          //     child: Image.asset(
          //       "assets/icons/marker.png",
          //       width: 120,
          //     ),
          //   ),
          // ),
          if (_selectedLocation != null)
            Positioned(
              bottom: 110,
              left: 30,
              right: 30,
              child: Card(
                surfaceTintColor: universalWhitePrimary,
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(width: 0),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: Text(location),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
              bottom: 50,
              left: 30,
              right: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: universalColorPrimaryDefault,
                    fixedSize: Size.fromWidth(context.screenWidth * 0.9),
                    maximumSize: Size.fromHeight(context.screenWidth * 0.12),
                    padding: const EdgeInsets.all(12),
                    shadowColor: null,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: () {
                  openGoogleMapsApp(
                      widget.order.latitude, widget.order.longitude);
                },
                child: "Open maps"
                    .text
                    .color(universalBlackPrimary)
                    .fontFamily(milligramSemiBold)
                    .fontWeight(FontWeight.w700)
                    .size(17)
                    .letterSpacing(1)
                    .make(),
              ).box.roundedSM.make()),
        ],
      ),
    );
  }
}
