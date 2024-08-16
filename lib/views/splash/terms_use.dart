import 'package:swarm/consts/consts.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      appBar: AppBar(
        title: Text(
          'Terms of Use',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions for SWARM Mobile App',
              style: TextStyle(
                  fontFamily: milligramRegular,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '1. Acceptance of Terms\nWelcome to SWARM! These Terms and Conditions ("Terms") govern your access and use of the SWARM mobile application ("App") and related services ("Services"). By accessing or using the App and Services, you agree to be bound by these Terms. If you do not agree with any part of these Terms, please do not use the App or Services.',
            ),
            SizedBox(height: 16),
            Text(
              '2. Use of the App\na. Eligibility: You must be at least 18 years old to use the App and Services. By using the App, you represent and warrant that you are of legal age to form a binding contract with SWARM.\nb. Account Registration: To access certain features of the App, you may be required to create an account. You are responsible for maintaining the confidentiality of your account credentials and are solely responsible for all activities that occur under your account.\nc. User Conduct: You agree not to use the App and Services for any unlawful or unauthorized purpose and to comply with all applicable laws and regulations. You will not engage in any activity that could harm, interfere with, or disrupt the App or Services or any user\'s experience.',
            ),
            SizedBox(height: 16),
            Text(
              '3. Intellectual Property\na. Ownership: SWARM retains all rights, title, and interest in and to the App, Services, and all related intellectual property. You may not use, copy, reproduce, or distribute any content from the App without our prior written consent.\nb. User Content: By using the App, you may submit or post content ("User Content"). You retain ownership of your User Content, but you grant SWARM a worldwide, royalty-free, non-exclusive, perpetual, and transferable license to use, reproduce, modify, and distribute your User Content for the purpose of providing the Services.',
            ),
            SizedBox(height: 16),
            Text(
              '4. Third-Party Links and Content\nThe App may contain links to third-party websites or services that are not owned or controlled by SWARM. We do not endorse or assume any responsibility for the content, privacy policies, or practices of third-party sites or services. Your interactions with such third parties are solely between you and them.',
            ),
            SizedBox(height: 16),
            Text(
              '5. Limitation of Liability\na. Disclaimer: The App and Services are provided on an "as-is" and "as-available" basis without any warranties, express or implied. SWARM does not warrant that the App will be error-free, secure, or uninterrupted.\nb. Limitation of Liability: In no event shall SWARM, its officers, directors, employees, or agents be liable to you or any third party for any indirect, incidental, special, or consequential damages arising out of or in connection with the App or Services.',
            ),
            SizedBox(height: 16),
            Text(
              '6. Indemnification\nYou agree to indemnify and hold SWARM harmless from and against any claims, damages, losses, liabilities, and expenses arising out of or related to your use of the App or Services or any violation of these Terms.',
            ),
            SizedBox(height: 16),
            Text(
              '7. Modification and Termination\nSWARM reserves the right to modify, suspend, or terminate the App and Services or these Terms at any time without prior notice. If you disagree with any changes, your sole remedy is to discontinue using the App and Services.',
            ),
            SizedBox(height: 16),
            Text(
              '8. Governing Law and Dispute Resolution\nThese Terms shall be governed by and construed in accordance with the laws of Delaware and New York. Any dispute arising out of or in connection with these Terms shall be resolved through arbitration.',
            ),
            SizedBox(height: 16),
            Text(
              '9. Contact Us\nIf you have any questions, concerns, or inquiries regarding these Terms, please contact us at info@get-swarm.com.',
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                'Thank you for using SWARM!',
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
