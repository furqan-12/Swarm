import 'package:swarm/consts/consts.dart';

class VxRatingCardView extends StatelessWidget {
  final String title;
  final double value;

  VxRatingCardView(this.title, this.value);

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
              15.heightBox,
              VxRating(
                maxRating: 5,
                value: value, // Replace with the actual rating value
                count: 5,
                size: 17,
                selectionColor: universalColorPrimaryDefault,
                onRatingUpdate: (value) {
                  // Handle rating update if needed
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
