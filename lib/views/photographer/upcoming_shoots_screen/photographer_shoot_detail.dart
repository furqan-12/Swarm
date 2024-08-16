import 'package:cached_network_image/cached_network_image.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/response/user.dart';

class PhotographerShootDetails extends StatefulWidget {
  final Widget selecter;
  final String name;
  final UserProfile? user;
  const PhotographerShootDetails({
    super.key,
    required this.selecter,
    required this.name,
    required UserProfile? this.user,
  });

  @override
  State<PhotographerShootDetails> createState() =>
      _PhotographerShootDetailsState();
}

class _PhotographerShootDetailsState extends State<PhotographerShootDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: universalWhitePrimary,
        surfaceTintColor: universalWhitePrimary,
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
                backgroundImage: widget.user == null
                    ? null
                    : CachedNetworkImageProvider(widget.user!.imageUrl),
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
