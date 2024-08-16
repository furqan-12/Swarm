import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/order.dart';

class OrderStorage {
  static const _order = 'order';

  static Future<String?> get getValue async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_order);
  }

  static Future<void> setValue(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_order, value ?? '');
  }

  static Future<OrderModel?> get getOrderModel async {
    final jsonStr = await OrderStorage.getValue;
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final json = jsonDecode(jsonStr);

      return OrderModel.fromJson(json);
    } else {
      return null;
    }
  }
}
