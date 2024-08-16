import 'package:get/get.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/payment_service.dart';
import 'package:swarm/storage/registration_storage.dart';
import 'package:swarm/storage/token_storage.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/utils/loader.dart';
import 'package:swarm/utils/toast_utils.dart';
import 'package:swarm/views/registration/thanks_you_screen/thanks_you_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectStripe extends StatefulWidget {
  const ConnectStripe({super.key});

  @override
  State<ConnectStripe> createState() => _ConnectStripeState();
}

class _ConnectStripeState extends State<ConnectStripe> {

  @override
  void dispose(){
    LoaderHelper.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: universalWhitePrimary,
        backgroundColor: universalWhitePrimary,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          child: Image.asset("assets/icons/arrow.png").onTap(() {
            Navigator.pop(context);
          }),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(26.0), // Set your preferred height
          child: Column(
            children: [
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 300,
                      padding: EdgeInsets.all(3.0),
                      color: universalColorPrimaryDefault,
                    ),
                  ],
                ),
              )
                  .box
                  .color(universalGary)
                  .margin(EdgeInsets.only(right: 15, left: 15))
                  .make(),
              5.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Profile",
                    style: TextStyle(
                        fontSize: 14,
                        color: universalColorPrimaryDefault,
                        fontFamily: milligramSemiBold),
                  ),
                  Text(
                    "Location",
                    style: TextStyle(
                        fontSize: 14,
                        color: universalColorPrimaryDefault,
                        fontFamily: milligramSemiBold),
                  ),
                  Text(
                    "Schedule",
                    style: TextStyle(
                        fontSize: 14, color: universalColorPrimaryDefault),
                  ),
                  Text(
                    "Portfolio",
                    style: TextStyle(
                        fontSize: 14, color: universalColorPrimaryDefault),
                  ),
                  Text(
                    "Get paid",
                    style: TextStyle(
                        fontSize: 14, color: universalColorPrimaryDefault),
                  ),
                  Text(
                    "Submit",
                    style: TextStyle(fontSize: 14, color: universalGary),
                  )
                ],
              ).box.margin(EdgeInsets.only(left: 15, right: 15)).make()
            ],
          ),
        ),
      ),
      backgroundColor: universalWhitePrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            10.heightBox,
            Align(
                alignment: Alignment.centerLeft,
                child: "Payment"
                    .text
                    .fontFamily(milligramBold)
                    .black
                    .size(40)
                    .make()),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 140,
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/swarmlogoblack.png",
                          width: 100,
                          height: 100,
                        ),
                        Image.asset(
                          "assets/icons/swarm.png",
                          width: 100,
                          height: 20,
                        ),
                      ],
                    )).box.color(universalBlackPrimary).roundedLg.make(),
                10.widthBox,
                Text(
                  "+",
                  style: TextStyle(fontSize: 40, fontFamily: milligramBold),
                ),
                10.widthBox,
                SizedBox(
                    width: 140,
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/stripelogo.png",
                        ),
                      ],
                    )).box.color(stripebgColor).roundedLg.make(),
              ],
            )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: universalColorPrimaryDefault,
                  maximumSize: Size.fromWidth(350),
                  padding: const EdgeInsets.all(12),
                  shadowColor: null,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                try {
                  LoaderHelper.show(context);
                  PaymentService paymentService = PaymentService();
                  var accountLink = await paymentService.createAccount();
                  if (accountLink != null) {
                    print(accountLink);
                    await canLaunchUrl(Uri.parse(accountLink))
                        ? await launchUrl(Uri.parse(accountLink),
                            mode: LaunchMode.externalApplication)
                        : throw 'Could not launch URL';
                  }
                } catch (e) {
                  ToastHelper.showErrorToast(
                      context, "Try again or contact us.");
                } finally {
                  LoaderHelper.hide();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  'Register with '
                      .text
                      .color(universalBlackPrimary)
                      .fontFamily(milligramSemiBold)
                      .fontWeight(FontWeight.w700)
                      .size(17)
                      .letterSpacing(1)
                      .make(),
                  Image.asset(
                    "assets/icons/Stripe.png",
                    width: 60,
                    height: 25,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final registration =
                    await RegistrationStorage.getRegistrationModel;
                if (registration != null) {
                  await TokenStorage.removeJwtToken();
                  await RegistrationStorage.removeValue();
                  await UserProfileStorage.removeValue();
                  Get.offAll(() => ThankYouScreen(
                      imageUrl: registration.profileImageUrl!,
                      name: registration.userName!));
                }
              },
              child: 'Skip'
                  .text
                  .color(universalColorPrimaryDefault)
                  .fontFamily(milligramSemiBold)
                  .fontWeight(FontWeight.w700)
                  .size(17)
                  .letterSpacing(1)
                  .make(),
            ),
          ],
        ),
      )
          .box
          .white
          .rounded
          .padding(const EdgeInsets.only(left: 15, right: 15, bottom: 30))
          .shadowSm
          .make(),
    );
  }
}
