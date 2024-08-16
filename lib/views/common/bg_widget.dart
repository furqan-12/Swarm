import 'package:flutter/material.dart';

import '../../consts/images.dart';

Widget bgWidget({Widget? child}) {
  return Container(
    decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage(splashImg), fit: BoxFit.fill)),
    child: child,
  );
}
