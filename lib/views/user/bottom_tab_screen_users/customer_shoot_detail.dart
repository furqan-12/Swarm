import 'package:cached_network_image/cached_network_image.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/user.dart';

class CustomerShootDetails extends StatefulWidget {
  final Widget selecter;
  final String name;
  const CustomerShootDetails(
      {super.key, required this.selecter, required this.name});

  @override
  State<CustomerShootDetails> createState() => _CustomerShootDetailsState();
}

class _CustomerShootDetailsState extends State<CustomerShootDetails> {
  UserProfile? user = null;

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
      ),
      backgroundColor: universalWhitePrimary,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: user == null
                    ? null
                    : CachedNetworkImageProvider(user!.imageUrl),
              ),
            ),
          ),
          20.heightBox,
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: widget.name.text
                  .fontFamily(milligramBold)
                  .color(universalBlackPrimary)
                  .size(36)
                  .make(),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: widget.selecter)
        ],
      ),
    );
  }
}
