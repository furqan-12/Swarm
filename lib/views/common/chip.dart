import "package:flutter/widgets.dart";
import 'package:flutter/material.dart';
import 'package:swarm/consts/colors.dart';
import 'package:swarm/consts/styles.dart';
import 'package:velocity_x/velocity_x.dart';

Widget chip(String text) {
  return Text(
    text,
    style: const TextStyle(
        fontFamily: milligramBold, fontSize: 15, color: universalWhitePrimary),
  )
      .box
      .color(universalColorPrimaryDefault)
      .customRounded(BorderRadius.circular(20))
      .padding(EdgeInsets.only(left: 10, right: 10, top: 3.5, bottom: 3.5))
      .margin(EdgeInsets.only(bottom: 5))
      .make();
}
