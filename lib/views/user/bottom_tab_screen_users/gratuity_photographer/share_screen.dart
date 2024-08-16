import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/our_button.dart';
import '../home_user.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      body: Column(
        children: [
          (context.screenHeight * 0.1).heightBox,
          Center(
            child: "Tell all your friends\n about Swarm."
                .text
                .color(universalBlackPrimary)
                .fontFamily(bold)
                .center
                .size(32)
                .make(),
          ),
          10.heightBox,
          Align(
              alignment: Alignment.center,
              child: "And your next shoot is on us!"
                  .text
                  .color(universalBlackTertiary)
                  .size(17)
                  .make()),
          25.heightBox,
          Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                "Your friends and family will get 10% off their first shoot. And, for every 5 people who book a shoot, you’ll get a 1-hr shoot for free. "
                    .text
                    .color(universalBlackTertiary)
                    .size(15)
                    .center
                    .make(),
          ),
          20.heightBox,
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 10, bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildShareButton(
                      "assets/icons/facebookshare.png",
                      "Facebook",
                      "https://www.facebook.com/sharer/sharer.php?u=https://www.instagram.com/get.swarm/",
                    ),
                    _buildShareButton(
                      "assets/icons/emailshare.png",
                      "Email",
                      "mailto:?subject=Check out this app&body=I think you will love it: https://get-swarm.com/",
                    ),
                    _buildShareButton(
                      "assets/icons/instagramshare.png",
                      "Instagram",
                      "https://www.instagram.com/get.swarm",
                    ),
                    _buildShareButton(
                      "assets/icons/twittershare.png",
                      "Twitter",
                      "https://twitter.com/intent/tweet?url=https://twitter.com/get_swarm&text=SwarmApp",
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: "Obsessed with the app? Become a Swarm brand ambassador."
                .text
                .color(universalBlackPrimary)
                .fontFamily(bold)
                .center
                .size(20)
                .make(),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                "If you are an influencer, or looking to become one, and want to help spread the word, please reach out."
                    .text
                    .color(universalBlackTertiary)
                    .size(15)
                    .center
                    .make(),
          ),
          (context.screenHeight * 0.15).heightBox,
          ourButton(
              color: universalColorPrimaryDefault,
              title: "Continue",
              textColor: universalBlackPrimary,
              onPress: () {
                Get.offAll(() => HomeUserScreen());
              }).box.width(context.screenWidth - 50).height(50).rounded.make(),
        ],
      ),
    );
  }
}

Widget _buildShareButton(String iconPath, String appName, String shareUrl) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 14),
        child: GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(shareUrl))) {
              await launchUrl(Uri.parse(shareUrl));
            } else {
              // Handle the case where the URL cannot be launched.
              print('Could not launch $appName');
            }
          },
          child: Image.asset(
            iconPath,
          ),
        ),
      ),
      ("Share on \n" + appName)
          .text
          .color(universalBlackTertiary)
          .size(14)
          .center
          .make(),
    ],
  );
}
