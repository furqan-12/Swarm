import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController? _instance;

  static HomeController get instance {
    if (_instance == null) {
      _instance = HomeController._();
    }
    return _instance!;
  }

  HomeController._(); // Private constructor

  var currentNavIndex = 2.obs;
  var unReadCount = 0.obs;
  var newOrders = 0.obs;
  var newCompletedOrders = 0.obs;

  // Other methods and variables as needed
}
