import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/api.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/services/photographer_service.dart';
import 'package:swarm/services/response/photographerstat.dart';
import 'package:swarm/views/common/full_image_screen.dart';
import 'package:swarm/views/common/video_player_common_screen.dart';
import 'package:swarm/views/order/find_photographers/book_screen.dart';
import 'package:swarm/views/photographer/stats_screen/recent_reviews_listview.dart';

import '../../../services/response/photographer.dart';
import '../../../storage/models/order.dart';
import '../../../storage/order_storage.dart';

class PhotographerPortfolioScreen extends StatefulWidget {
  const PhotographerPortfolioScreen({super.key, required this.photographer});
  final Photographer photographer;

  @override
  State<PhotographerPortfolioScreen> createState() =>
      _PhotographerPortfolioScreenState();
}

class _PhotographerPortfolioScreenState
    extends State<PhotographerPortfolioScreen> {
  bool isExpanded = false;
  final int maxLines = 3;
  int initReview = 5;
  OrderModel? order;
  List<PhotographerReview> reviews = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    order = (await OrderStorage.getOrderModel)!;
    final photographerService = PhotographerService();
    var user =
        await photographerService.getStats(context, widget.photographer.id);
    setState(() {
      if (user != null) {
        reviews = user.reviews;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            child: Image.asset("assets/icons/arrow.png").onTap(() {
              Navigator.pop(context);
            }),
          ),
          surfaceTintColor: universalWhitePrimary,
          backgroundColor: universalWhitePrimary,
          toolbarHeight: 100,
          title: Align(
            alignment: Alignment.centerLeft,
            child: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight + 20),
                child: Wrap(spacing: 4.0, children: [])),
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                              widget.photographer.imagePath!),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 17, bottom: 12),
                          child: widget.photographer.name!.text
                              .size(28)
                              .fontFamily(bold)
                              .make(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.photographer.experienceName
                                    .substring(0, 3)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontFamily: milligramBold,
                                    fontSize: 12,
                                    color: universalWhitePrimary),
                              )
                                  .box
                                  .color(universalColorPrimaryDefault)
                                  .customRounded(BorderRadius.circular(5))
                                  .padding(EdgeInsets.only(
                                      left: 7, right: 7, top: 3.5, bottom: 3.5))
                                  .make(),
                              SizedBox(
                                width: 5,
                              ),
                              if (widget.photographer.isPhotographer)
                                Text(
                                  ("PICS"),
                                  style: const TextStyle(
                                      fontFamily: milligramBold,
                                      fontSize: 12,
                                      color: universalWhitePrimary),
                                )
                                    .box
                                    .color(universalColorPrimaryDefault)
                                    .customRounded(BorderRadius.circular(5))
                                    .padding(EdgeInsets.only(
                                        left: 7,
                                        right: 7,
                                        top: 3.5,
                                        bottom: 3.5))
                                    .make(),
                              SizedBox(
                                width: 5,
                              ),
                              if (widget.photographer.isVideographer)
                                Text(
                                  ("VIDEO"),
                                  style: const TextStyle(
                                      fontFamily: milligramBold,
                                      fontSize: 12,
                                      color: universalWhitePrimary),
                                )
                                    .box
                                    .color(universalColorPrimaryDefault)
                                    .customRounded(BorderRadius.circular(5))
                                    .padding(EdgeInsets.only(
                                        left: 7,
                                        right: 7,
                                        top: 3.5,
                                        bottom: 3.5))
                                    .make()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.photographer.bio!,
                      maxLines: isExpanded ? null : maxLines,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 0.98,
                      style: TextStyle(
                          color: universalBlackSecondary, fontSize: 16.4),
                    ),
                    if (!isExpanded &&
                        widget.photographer.bio!.length >
                            maxLines * 50) // Adjust threshold as needed
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = true;
                          });
                        },
                        child: Text('read less'),
                      ),
                    if (isExpanded)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = false;
                          });
                        },
                        child: Text('read more'),
                      ),
                  ],
                )),
          ),
          10.heightBox,
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 10, bottom: 10),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: "Portfolio"
                            .text
                            .size(20)
                            .color(universalBlackPrimary)
                            .fontFamily(bold)
                            .make()),
                  ),
                  Stack(children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: widget.photographer.portfolios.length,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 0.001,
                                  crossAxisSpacing: 0.001),
                          itemBuilder: (context, index) {
                            PhotographerPortfolio photo =
                                widget.photographer.portfolios[index];
                            var url = photo.isVideo == true
                                ? photo.thumbnailPath!
                                : photo.imagePath!;
                            return InkWell(
                                onTap: () {
                                  if (photo.isVideo == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VideoPlayerCommonScreen(
                                                photo.imagePath!),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ImageScreen(photo.imagePath!),
                                      ),
                                    );
                                  }
                                },
                                child: Column(
                                  children: [
                                    Stack(children: [
                                      CachedNetworkImage(
                                        fadeInDuration:
                                            const Duration(seconds: 1),
                                        imageUrl: url,
                                        fit: BoxFit.cover,
                                        height: 115,
                                        width: 115,
                                        placeholder: (context, url) => Center(
                                          child:
                                              const CircularProgressIndicator(
                                            color: universalColorPrimaryDefault,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.error,
                                          color: specialError,
                                        ),
                                      ),
                                      if (photo.isVideo == true)
                                        const Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Icon(
                                              Icons.videocam_outlined,
                                              color: universalWhitePrimary,
                                            )),
                                    ]),
                                  ],
                                )).paddingAll(2);
                          }),
                    ),
                  ]),
                  if (reviews.length > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          " Reviews",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: milligramBold,
                            color: universalBlackPrimary,
                          ),
                        ),
                      ),
                    ),
                  if (reviews.length > 0) 10.heightBox,
                  if (reviews.length > 0)
                    SizedBox(
                        height: context.screenHeight * 0.55,
                        child: RecentReviewsList(reviews.length > initReview
                            ? reviews.sublist(0, initReview)
                            : reviews)),
                  if (reviews.length > initReview) Divider(),
                  if (reviews.length > initReview)
                    Text(
                      "Show more",
                      style: TextStyle(
                          color: universalColorPrimaryDefault,
                          fontFamily: milligramBold),
                    ).onTap(() {
                      setState(() {
                        initReview = initReview + 5;
                      });
                    }),
                  if (reviews.length > initReview) Divider()
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              // decoration: BoxDecoration(
              //   border: Border(
              //     top: BorderSide(
              //       color: universalBlackTertiary,
              //       width: 1.0, // Adjust width as needed
              //       style: BorderStyle.solid, // Adjust style as needed
              //     ),
              //   ),
              // ),
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "\$${widget.photographer.perHourRate.numCurrency}"
                          .text
                          .size(18)
                          .fontFamily(semibold)
                          .make(),
                      "You get ${order == null ? "" : (order!.shootTypeId != ShootingTypes["Video"] ? "10" : VideoExperiences[widget.photographer.experienceId])} ${widget.photographer.experienceId == Experiences["Starter"] ? "raw" : "edited"} ${order == null ? "" : (order!.shootTypeId != ShootingTypes["Video"] ? "pics" : "video")}."
                          .text
                          .size(15)
                          .make(),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: universalColorPrimaryDefault,
                            elevation: 0,
                            padding: const EdgeInsets.only(
                                left: 35, right: 35, top: 12, bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        onPressed: () {
                          Get.to(() => BookScreen(
                                photographer: widget.photographer,
                              ));
                        },
                        child: "Book now"
                            .text
                            .color(universalBlackPrimary)
                            .fontFamily(bold)
                            .size(20)
                            .make(),
                      ),
                    ],
                  )
                ],
              )
                  .box
                  .rounded
                  .margin(const EdgeInsets.only(
                      left: 20, right: 20, bottom: 20, top: 20))
                  .padding(const EdgeInsets.only(left: 10, right: 10))
                  .color(universalWhitePrimary)
                  .make(),
            ),
          ).box.border(color: universalBlackTertiary, width: 1).make()
        ],
      ),
    );
  }
}
