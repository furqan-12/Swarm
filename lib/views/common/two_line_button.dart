import 'package:swarm/consts/consts.dart';

class twoLineButton extends StatelessWidget {
  final VoidCallback? onPress;
  final Color color;
  final Color textColor;
  final String? title;
  final String? font;
  final String? childText;
  final bool isDisabled;

  const twoLineButton({
    super.key,
    required this.onPress,
    required this.color,
    required this.textColor,
    this.title,
    this.font,
    this.childText,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonText = title!.text
        .color(textColor)
        .softWrap(true)
        .fontFamily(font ?? milligramSemiBold)
        .fontWeight(FontWeight.w700)
        .size(30)
        .letterSpacing(1)
        .make();

    final secondText = childText!.text
        .color(universalGrayCell)
        .fontFamily(font ?? milligramSemiBold)
        .fontWeight(FontWeight.w400)
        .size(17)
        .make();

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(),
            shadowColor: null,
            elevation: 0),
        onPressed: isDisabled ? null : onPress,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensure the Column takes minimum space
            children: [
              buttonText,
              if (childText != "") secondText,
            ],
          ),
        ));
  }
}
