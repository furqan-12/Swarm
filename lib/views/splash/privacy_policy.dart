import 'package:swarm/consts/consts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
              fontFamily: milligramRegular,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: universalBlackPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: universalWhitePrimary,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for SWARM Mobile App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '1. Introduction\nWelcome to SWARM! This Privacy Policy outlines how we collect, use, disclose, and protect your personal information when you use our mobile application ("App") and related services ("Services"). By accessing or using the App and Services, you agree to the practices described in this Privacy Policy.',
            ),
            SizedBox(height: 16),
            Text(
              '2. Information We Collect\nWe may collect various types of information from you, including but not limited to:\n• Personal Information: Your name, email address, contact information, and other identifiable data provided during account creation and while using the App.\n• Usage Data: Information related to your interactions with the App, such as the pages viewed, features accessed, and actions taken.\n• Device Information: Details about your device, including the operating system, unique device identifier, and IP address.',
            ),
            SizedBox(height: 16),
            Text(
              '3. How We Use Your Information\nWe use the collected information for the following purposes:\n• To provide and improve our Services.\n• To communicate with you, respond to inquiries, and send important notices.\n• To personalize your experience on the App and tailor content to your interests.\n• To monitor and analyze usage patterns to enhance App functionality and user experience.\n• To comply with legal obligations and protect our rights.',
            ),
            SizedBox(height: 16),
            Text(
              '4. Data Sharing and Disclosure\nWe may share your information in the following situations:\n• With Service Providers: We may engage third-party service providers to perform functions on our behalf, such as payment processing or data analytics.\n• With Other Users: Certain features of the App may allow you to share information with other users as per your interactions.\n• For Legal Reasons: We may share information if required by law, regulation, legal process, or government request.',
            ),
            SizedBox(height: 16),
            Text(
              '5. Cookies and Tracking Technologies\nSWARM may use cookies and similar tracking technologies to enhance user experience and collect usage data. By using the App, you consent to the use of cookies as outlined in our Cookie Policy.',
            ),
            SizedBox(height: 16),
            Text(
              '6. Data Security\nWe take reasonable measures to protect your information from unauthorized access, disclosure, alteration, or destruction. However, no method of transmission over the internet or electronic storage is entirely secure, and we cannot guarantee absolute security.',
            ),
            SizedBox(height: 16),
            Text(
              '7. Your Choices and Rights\nYou have the right to access, update, correct, or delete your personal information. You can exercise these rights through your App settings or by contacting us at [Insert Contact Information]. You can also opt-out of marketing communications by following the unsubscribe instructions provided.',
            ),
            SizedBox(height: 16),
            Text(
              '8. Children\'s Privacy\nSWARM does not knowingly collect personal information from children under the age of 13. If you believe a child has provided personal information, please contact us, and we will promptly delete it.',
            ),
            SizedBox(height: 16),
            Text(
              '9. Changes to this Privacy Policy\nWe may update this Privacy Policy from time to time to reflect changes in our practices or for other operational, legal, or regulatory reasons. Any such changes will be posted on the App, and the revised version will become effective on the date indicated.',
            ),
            SizedBox(height: 16),
            Text(
              '10. Contact Us\nIf you have any questions, concerns, or requests related to this Privacy Policy or our privacy practices, please contact us at info@get-swarm.com.',
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                'Thank you for trusting SWARM!',
                style: TextStyle(
                    fontFamily: milligramRegular,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
