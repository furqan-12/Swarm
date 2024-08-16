import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/common/chip.dart';
import 'package:swarm/views/order/date_time_screen/date_time_screen.dart';

import '../../../storage/models/order.dart';
import '../../../storage/order_storage.dart';
import '../../common/our_button.dart';

class ShootLocationScreen extends StatefulWidget {
  final OrderModel order;
  ShootLocationScreen({super.key, required this.order});

  @override
  State<ShootLocationScreen> createState() => _ShootLocationScreenState();
}

class _ShootLocationScreenState extends State<ShootLocationScreen> {
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
    super.initState();
    Future.delayed(Duration.zero, () {
      _checkLocationServiceAndPermission();
      _getOrder();
    });
  }

  Future<void> _showLocationSettingsDialog() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: universalWhitePrimary,
          title: Text("Enable Location Services"),
          content: Text("Location services are required to use this feature."),
          actions: <Widget>[
            TextButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("OPEN SETTINGS"),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAppSettingsDialog() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: universalWhitePrimary,
          title: Text("Location Permission Denied"),
          content: Text("Location permission is required to use this feature."),
          actions: <Widget>[
            TextButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("OPEN SETTINGS"),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getOrder() async {
    if (widget.order.latitude != null) {
      _currentLocation =
          LatLng(widget.order.latitude!, widget.order.longitude!);
    }
  }

  Future<void> _checkLocationServiceAndPermission() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      await _showLocationSettingsDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await _showAppSettingsDialog();
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        await _showAppSettingsDialog();
        return;
      }
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      await _getAddress(
          _currentLocation!.latitude, _currentLocation!.longitude);
      final GoogleMapController controller =
          await _mapControllerCompleter.future;
      controller.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
      controller.dispose();
    } catch (e) {
      ToastHelper.showErrorToast(context, unknownError);
    }
  }

  Future<void> _selectLocation() async {
    if (_selectedLocation != null) {
      final _order = await OrderStorage.getOrderModel;
      if (_order != null) {
        _order.address = location;
        _order.shortAddress = shortLocation;
        _order.latitude = _selectedLocation!.latitude;
        _order.longitude = _selectedLocation!.longitude;
        final jsonMap = _order.toJson();
        await OrderStorage.setValue(jsonEncode(jsonMap));
        Get.to(() => DateTimeScreen(order: _order));
      }
    }
  }

  List<Prediction>? _autocompleteResults;

  void _getAutocompleteResults(String input) async {
    if (input.isNotEmpty) {
      final response = await _places.autocomplete(input,
          components: [Component(Component.country, "us")]);
      if (response.isOkay) {
        setState(() {
          _autocompleteResults = response.predictions;
        });
      }
    } else {
      setState(() {
        _autocompleteResults = null;
      });
    }
  }

  void _selectLocationFromAutocomplete(Prediction prediction) async {
    final placeDetails = await _places.getDetailsByPlaceId(prediction.placeId!);
    if (placeDetails.isOkay) {
      final location = placeDetails.result.geometry!.location;
      final target = LatLng(location.lat, location.lng);

      final GoogleMapController controller =
          await _mapControllerCompleter.future;
      controller.animateCamera(CameraUpdate.newLatLng(target));
      controller.dispose();

      setState(() {
        _selectedLocation = target;
        showSearchBar = false;
        _autocompleteResults = null;
      });
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
            "${currentPlace.street} ${currentPlace.name != currentPlace.street ? currentPlace.name : ""}, ${currentPlace.administrativeArea.isEmptyOrNull ? currentPlace.locality : currentPlace.administrativeArea}";
        showSearchBar = false;
      }
    });
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
          toolbarHeight: 100,
          title: Align(
            alignment: Alignment.topLeft,
            child: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight + 20),
                child: Wrap(spacing: 4.0, children: [
                  chip(widget.order.shootTypeName),
                  chip(widget.order.shootSceneName!),
                ])),
          )),
      backgroundColor: universalWhitePrimary,
      body: Stack(
        children: [
          Column(
            children: [
              15.heightBox,
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
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _mapControllerCompleter.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? LatLng(40.730610, -73.935242),
                    zoom: 17.0,
                  ),
                  onCameraMove: (CameraPosition cameraPositiona) {
                    setState(() {
                      cameraPosition = cameraPositiona; //when map is dragging
                    });
                  },
                  onCameraIdle: () async {
                    if (cameraPosition != null) {
                      await _getAddress(cameraPosition!.target.latitude,
                          cameraPosition!.target.longitude);
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            // Place the marker at the center of the map
            bottom: 0,
            left: 0,
            right: 0,
            top: 120,
            child: Center(
              child: Image.asset(
                "assets/icons/marker.png",
                width: 120,
              ),
            ),
          ),
          if (_selectedLocation != null)
            Positioned(
              bottom: 100,
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
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                showSearchBar = !showSearchBar;
                                _autocompleteResults = null;
                              });
                            },
                          ),
                          SizedBox(width: 0),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: showSearchBar
                                  ? Column(
                                      children: [
                                        TextField(
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search for a location...',
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (value) {
                                            _getAutocompleteResults(value);
                                          },
                                        ),
                                      ],
                                    )
                                  : Text(location),
                            ),
                          ),
                        ],
                      ),
                      if (_autocompleteResults != null &&
                          _autocompleteResults!.length > 0)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: _autocompleteResults!.length,
                          itemBuilder: (context, index) {
                            final prediction = _autocompleteResults![index];
                            String description = prediction.description!;

                            if (description.length > 50) {
                              description =
                                  description.substring(0, 50) + '...';
                            }
                            return ListTile(
                              title: Text(description),
                              onTap: () {
                                _selectLocationFromAutocomplete(prediction);
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ourButton(
              color: universalColorPrimaryDefault,
              title: "Select and continue",
              textColor: universalBlackPrimary,
              onPress: () async {
                await _selectLocation();
              },
            ).box.width(context.screenWidth - 50).height(50).rounded.make(),
          ),
        ],
      ),
    );
  }
}
