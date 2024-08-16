import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swarm/consts/api.dart';
import 'package:swarm/consts/consts.dart';
import 'package:swarm/storage/user_profile_storage.dart';
import 'package:swarm/views/common/full_image_screen.dart';
import 'package:swarm/views/common/our_button.dart';
import 'package:swarm/views/common/video_player_common_screen.dart';
import 'package:swarm/views/order/date_time_screen/date_time_screen.dart';
import 'package:swarm/views/user_profile/contact_us.dart';

import '../../../../services/response/photographer.dart';
import '../../../../storage/models/order.dart';
import '../photographers_portfolio.dart';

class AllScreen extends StatefulWidget {
  final List<Photographer> items;
  final OrderModel order;

  const AllScreen({Key? key, required this.items, required this.order})
      : super(key: key);

  @override
  State<AllScreen> createState() => _AllScreenState();
}

class _AllScreenState extends State<AllScreen> {
  int visibleItems = 2; // Initial number of visible items
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalWhitePrimary,
      body: widget.items.isEmpty
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.center,
                    child:
                        "There are no photographers available on that\nday, at that time. Please search again."
                            .text
                            .align(TextAlign.center)
                            .color(universalBlackSecondary)
                            .size(16)
                            .fontFamily(milligramBold)
                            .make()),
                20.heightBox,
                Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ourButton(
                            color: universalColorPrimaryDefault,
                            title: "Contact Us",
                            textColor: universalBlackPrimary,
                            onPress: () async {
                              final userProfile =
                                  await UserProfileStorage.getUserProfileModel;
                              Get.to(() => ContactUsScreen(user: userProfile!));
                            },
                            font: helvetica),
                      ],
                    )),
                20.heightBox,
                Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.arrowLeftLong,
                          size: 20,
                          color: universalGary,
                        ),
                        5.widthBox,
                        Text(
                          "Book a new shoot",
                          style: TextStyle(
                              fontSize: 16,
                              color: universalGary,
                              fontFamily: milligramBold),
                        ),
                      ],
                    )).onTap(() {
                  Get.to(() => DateTimeScreen(order: widget.order));
                })
              ],
            ))
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: Stack(children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          Photographer item = widget.items[index];
                          if (index < visibleItems) {
                            return InkWell(
                              onTap: () {
                                Get.to(() => PhotographerPortfolioScreen(
                                      photographer: item,
                                    ));
                              },
                              child: Container(
                                      child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                item.imagePath!,
                                                scale: 1.0),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional.topStart,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: item.portfolios
                                                            .isNotEmpty
                                                        ? 48
                                                        : 64,
                                                    child:
                                                        "${item.name?.split(' ')[0] ?? ''}"
                                                            .text
                                                            .size(17)
                                                            .fontFamily(
                                                                milligramBold)
                                                            .make(),
                                                  ),
                                                  17.widthBox,
                                                  VxRating(
                                                    isSelectable: false,
                                                    value: item.rating,
                                                    onRatingUpdate: (value) {},
                                                    normalColor:
                                                        universalBlackTertiary,
                                                    selectionColor:
                                                        universalColorPrimaryDefault,
                                                    size: 16,
                                                    maxRating: 5,
                                                    count: 5,
                                                  ),
                                                  10.widthBox,
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 0.1),
                                                    child: RichText(
                                                      textAlign: TextAlign.end,
                                                      text: TextSpan(
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text:
                                                                '  \$${item.perHourRate.numCurrency}/hr\n',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  milligramBold,
                                                              fontSize: 20,
                                                              color:
                                                                  universalBlackPrimary,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            // Add the rest of your text here
                                                            text:
                                                                'You get ${widget.order.shootTypeId != ShootingTypes["Video"] ? "9" : VideoExperiences[item.id]} ${item.id == Experiences["Starter"] ? "raw" : "edited"} ${widget.order.shootTypeId != ShootingTypes["Video"] ? "pics" : "video"}',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontFamily:
                                                                  milligramSemiBold,
                                                              color:
                                                                  universalBlackPrimary,
                                                              // Add styles for the remaining text
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.experienceName
                                                                .length >=
                                                            3
                                                        ? item.experienceName
                                                            .substring(0, 3)
                                                            .toUpperCase()
                                                        : item.experienceName,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            milligramBold,
                                                        fontSize: 12,
                                                        color:
                                                            universalWhitePrimary),
                                                  )
                                                      .box
                                                      .color(
                                                          universalColorPrimaryDefault)
                                                      .customRounded(
                                                          BorderRadius.circular(
                                                              5))
                                                      .padding(EdgeInsets.only(
                                                          left: 7,
                                                          right: 7,
                                                          top: 3.5,
                                                          bottom: 3.5))
                                                      .make(),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  if (item.isPhotographer)
                                                    Text(
                                                      ("PICS"),
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              milligramBold,
                                                          fontSize: 12,
                                                          color:
                                                              universalWhitePrimary),
                                                    )
                                                        .box
                                                        .color(
                                                            universalColorPrimaryDefault)
                                                        .customRounded(
                                                            BorderRadius
                                                                .circular(5))
                                                        .padding(
                                                            EdgeInsets.only(
                                                                left: 7,
                                                                right: 7,
                                                                top: 3.5,
                                                                bottom: 3.5))
                                                        .make(),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  if (item.isVideographer)
                                                    Text(
                                                      ("VIDEO"),
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              milligramBold,
                                                          fontSize: 12,
                                                          color:
                                                              universalWhitePrimary),
                                                    )
                                                        .box
                                                        .color(
                                                            universalColorPrimaryDefault)
                                                        .customRounded(
                                                            BorderRadius
                                                                .circular(5))
                                                        .padding(
                                                            EdgeInsets.only(
                                                                left: 7,
                                                                right: 7,
                                                                bottom: 3.5,
                                                                top: 3.5))
                                                        .make()
                                                ],
                                              ),
                                              5.heightBox,
                                              SizedBox(
                                                  width: 265,
                                                  child: Text(
                                                    item.bio!,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            universalBlackSecondary),
                                                    maxLines:
                                                        3, // Set the maximum number of lines to display
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textScaleFactor: 0.9,
                                                  )),
                                              10.heightBox
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 70,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: item.portfolios.length,
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis
                                          .horizontal, // Set the scroll direction to horizontal
                                      itemBuilder: (context, index) {
                                        PhotographerPortfolio photo =
                                            item.portfolios[index];
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
                                                      ImageScreen(
                                                          photo.imagePath!),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            // Adjust the spacing between items
                                            // Set the width of each item
                                            child: Column(
                                              children: [
                                                Stack(
                                                  children: [
                                                    CachedNetworkImage(
                                                      fadeInDuration:
                                                          const Duration(
                                                              seconds: 1),
                                                      imageUrl: url,
                                                      fit: BoxFit.cover,
                                                      height: 70,
                                                      width: 70,
                                                      placeholder:
                                                          (context, url) =>
                                                              Center(
                                                        child:
                                                            const CircularProgressIndicator(
                                                          color:
                                                              universalColorPrimaryDefault,
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(
                                                        Icons.error,
                                                        color: specialError,
                                                      ),
                                                    ),
                                                    if (photo.isVideo == true)
                                                      Positioned(
                                                        bottom: 20,
                                                        left: 25,
                                                        child: Icon(
                                                          Icons.play_arrow,
                                                          color: Colors
                                                              .white, // Change the color as needed
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ).paddingOnly(right: 5);
                                      },
                                    ),
                                  ),
                                  10.heightBox,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4, right: 0),
                                        child: Text(
                                          "See Profile ",
                                          style: TextStyle(
                                              color: universalBlackTertiary,
                                              fontFamily: milligramSemiBold),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 4, right: 0),
                                          child: Icon(
                                            FontAwesomeIcons.arrowRightLong,
                                            size: 18,
                                            color: universalBlackTertiary,
                                          )),
                                    ],
                                  )
                                ],
                              ))
                                  .box
                                  .color(universalWhitePrimary)
                                  .roundedSM
                                  .margin(EdgeInsets.only(bottom: 10))
                                  .padding(EdgeInsets.all(8))
                                  .border(
                                      color: universalBlackTertiary, width: 1.0)
                                  .make(),
                            );
                          }
                          return SizedBox
                              .shrink(); // Hide additional items initially
                        },
                      ),
                    ]),
                  ),
                ),
                Divider(),
                if (widget.items.length > visibleItems)
                  Text(
                    "Show more",
                    style: TextStyle(
                        fontSize: 18,
                        color: universalColorPrimaryDefault,
                        fontFamily: milligramBold),
                  ).onTap(() {
                    setState(() {
                      visibleItems = visibleItems + 2;
                    });
                  }),
                if (widget.items.length > visibleItems) Divider()
              ],
            ),
    );
  }
}
