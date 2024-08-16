import '../../../consts/consts.dart';

Widget NewRequestsResult(
    {required String title, icon, required String subtitle, color ,textColor}) {
  // Customize this method based on the content for each item
  return Center(
    child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          icon,
          26.heightBox,
          Text(
            title,
            style: TextStyle(
                color: textColor,
                fontFamily: milligramBold,
                fontSize: 20),
          ),
          26.heightBox,
          Text(subtitle,
              style: TextStyle(
                color: textColor,
                fontFamily: milligramRegular,
                fontSize: 18,
              ),
              textAlign: TextAlign.center),
          28.heightBox,
        ])
        .box
        .margin(const EdgeInsets.only(left: 10, right: 10, top: 10))
        .alignCenter
        .roundedSM
        
        .padding(const EdgeInsets.only(left: 20, right: 20, top: 20))
        .color(color)
        .make(),
  );
}
