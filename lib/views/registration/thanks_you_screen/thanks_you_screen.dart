import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/views/splash/splash_screen_login.dart';

import '../../common/our_button.dart';

class ThankYouScreen extends StatefulWidget {
  final String imageUrl;
  final String name;

  const ThankYouScreen({Key? key, required this.imageUrl, required this.name})
      : super(key: key);

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset("assets/icons/arrow.png"),
          ),
        ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Column(
        children: [
          SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      "Thanks for\napplying, ${widget.name}",
                      style: TextStyle(
                        fontFamily: milligramBold,
                        color: Colors.black,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          CachedNetworkImageProvider(widget.imageUrl),
                    ),
                  ),
                  SizedBox(height: 30),
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      "Thanks for applying to Swarm. Once you\nsubmit your profile, we’ll review your\navailability, portfolio, and experience to\ndetermine your eligibility. We’ll reach out to\nyou as soon as possible.",
                      style: TextStyle(
                        height: 1.1,
                        fontFamily: milligramRegular,
                        color: universalBlackSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              // Centers only the button horizontally
              child: SizedBox(
                width: context.screenWidth - 50,
                height: 50,
                child: ourButton(
                  color: universalColorPrimaryDefault,
                  title: "Submit",
                  textColor: universalBlackPrimary,
                  onPress: () async {
                    Get.offAll(() => const SplashScreenLogin());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
