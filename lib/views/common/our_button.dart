import 'package:swarm/consts/consts.dart';

class ourButton extends StatelessWidget {
  final VoidCallback? onPress;
  final Color color;
  final Color textColor;
  final String? title;
  final String? font;
  final Widget? childText;
  final bool isLoading;
  final bool isDisabled;

  const ourButton({
    super.key,
    required this.onPress,
    required this.color,
    required this.textColor,
    this.title,
    this.font,
    this.childText,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonText = title!.text
        .color(textColor)
        .fontFamily(font ?? milligramSemiBold)
        .fontWeight(FontWeight.w700)
        .size(17)
        .letterSpacing(1)
        .make();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.all(12),
          shadowColor: null,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      onPressed: isLoading || isDisabled ? null : onPress,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(universalWhitePrimary),
              ),
            )
          : childText ?? buttonText,
    );
  }
}
