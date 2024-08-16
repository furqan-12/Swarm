import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:swarm/utils/toast_utils.dart';

Future<bool> checkInternetConnection(BuildContext context) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    // No internet connection
    ToastHelper.showErrorToast(context, "No internet connection!");
    return false;
  }
  return true;
}
