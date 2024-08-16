import 'package:swarm/consts/consts.dart';

Future<void> showCustomDialogTextWidget(
  BuildContext context,
  String title,
  String description,
  String buttonText, {
  Duration? showDuration,
  Duration? animationDuration,
}) async {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
      backgroundColor: universalWhitePrimary,
      surfaceTintColor: universalWhitePrimary,
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: milligramBold,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text(
                    description.replaceFirst("Please try again.", ""),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 16, fontFamily: milligramSemiBold),
                  )),
              SizedBox(height: 8),
            ],
          ),
          SizedBox(width: 350, child: Divider()),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              buttonText,
              style: TextStyle(
                fontFamily: milligramBold,
                fontSize: 22,
                color: universalColorPrimaryDefault,
              ),
            ),
          ),
        ],
      ),
    ),
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
    transitionDuration: animationDuration ?? Duration(milliseconds: 300),
  );

  if (showDuration != null) {
    await Future.delayed(showDuration);
    Navigator.of(context).pop(); // Close the dialog after delay
  }
}
