import 'package:swarm/consts/consts.dart';

class CustomDialogImgWidget extends StatelessWidget {
  final Widget image;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onPressed;

  const CustomDialogImgWidget({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: universalWhitePrimary,
      surfaceTintColor: universalWhitePrimary,
      // Adjust the horizontal padding as needed
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.all(13),
      child: Container(
        width: double.infinity,
        height: 290,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            image,
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 27, right: 27),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: milligramBold,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(description,
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 15, fontFamily: milligramSemiBold)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: universalColorPrimaryDefault,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27))),
                    onPressed: onPressed ??
                        () {
                          Navigator.of(context).pop(); // Close the dialogx
                        },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 9, right: 9, bottom: 12, top: 12),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontFamily: milligramBold,
                          fontSize: 17,
                          color: universalBlackPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
