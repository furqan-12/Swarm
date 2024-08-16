import 'package:flutter/material.dart';
import 'package:swarm/views/common/customdailog_icon_widget.dart';
import 'package:swarm/views/common/customdailog_img_widget.dart';
import 'package:swarm/views/common/customdailog_text_widget.dart';

import '../consts/consts.dart';

class ToastHelper {
  static void showSuccessToast(BuildContext context, dynamic icon, String title,
      String description, String buttonText, dynamic onPressed) {
    if (icon is Icon) {
      showIconSuccessToast(
          context, icon, title, description, buttonText, onPressed);
    } else {
      showImageSuccessToast(
          context, icon, title, description, buttonText, onPressed);
    }
  }

  static void showIconSuccessToast(BuildContext context, Icon icon,
      String title, String description, String buttonText, dynamic onPressed) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomDialogIconWidget(
              icon: icon,
              title: title,
              description: description,
              buttonText: buttonText,
              onPressed: () {
                onPressed();
              }),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }

  static void showImageSuccessToast(BuildContext context, dynamic image,
      String title, String description, String buttonText, dynamic onPressed) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomDialogImgWidget(
              image: image,
              title: title,
              description: description,
              buttonText: buttonText,
              onPressed: () {
                onPressed();
              }),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }

  static void showErrorToast(
    BuildContext context,
    String message,
    //{double height = 80}
  ) {
    // showAnimatedDialog(context);
    showCustomDialogTextWidget(
        context, "That didn't work", message, "Try again",
        showDuration: null);
  }
}
