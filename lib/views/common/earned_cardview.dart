import 'package:swarm/consts/consts.dart';

class EarnedCardView extends StatelessWidget {
  final String title;
  final String subtitle;
  final Colors;

  EarnedCardView(this.title, this.subtitle, this.Colors);

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: universalWhitePrimary,
      color: universalColorSecondaryDefault,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(1)),
      elevation: 1,
      child: Container(
        padding: EdgeInsets.all(16),
        width: context.screenWidth * 0.477,
        height: 110,
        child: Center(
          child: Column(
            children: [
              12.heightBox,
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: universalWhitePrimary),
              ),
              5.heightBox,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30, fontFamily: milligramBold, color: Colors),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
