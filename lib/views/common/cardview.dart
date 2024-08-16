import 'package:swarm/consts/consts.dart';

class CardView extends StatelessWidget {
  final String title;
  final String subtitle;
  final double subtitlesize;
  final double subtitleheight;

  CardView(this.title, this.subtitle, this.subtitlesize, this.subtitleheight);

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: universalWhitePrimary,
      color: universalBlackCell,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(1)),
      elevation: 1,
      child: Container(
        padding: EdgeInsets.all(16),
        width: context.screenWidth * 0.3,
        height: 110,
        child: Center(
          child: Column(
            children: [
              12.heightBox,
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              subtitleheight.heightBox,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: subtitlesize, fontFamily: milligramBold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
