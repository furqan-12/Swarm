import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:swarm/services/response/photographerstat.dart';
import 'package:swarm/utils/date_time_helper.dart';

import '../../../consts/consts.dart';

class RecentReviewsList extends StatelessWidget {
  // Example stream that emits new reviews over time
  final StreamController<List<PhotographerReview>> _reviewsStreamController =
      StreamController<List<PhotographerReview>>();

  RecentReviewsList(List<PhotographerReview> reviews) {
    // Simulate streaming of reviews (replace this with your actual stream)
    _reviewsStreamController.add(reviews);
    // You can add more reviews over time using _reviewsStreamController.add(newReviews);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PhotographerReview>>(
      stream: _reviewsStreamController.stream,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final reviews = snapshot.data!;
          return ListView.builder(
            itemCount: reviews.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ListTile(
                leading: review.imagePath != null
                    ? CircleAvatar(
                        radius: 40,
                        backgroundColor: universalWhitePrimary,
                        backgroundImage: CachedNetworkImageProvider(
                            review.imagePath!,
                            scale: 1.0),
                      )
                    : CircleAvatar(
                        radius: 45,
                        backgroundColor: universalWhitePrimary,
                        backgroundImage: AssetImage(swarmLogoColor),
                      ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${formatDateOnly(review.reviewDate!)}',
                      style: TextStyle(fontSize: 12, color: universalBlackLine),
                    ),
                    VxRating(
                      maxRating: 5,
                      value: review.rating.toDouble(),
                      size: 14,
                      selectionColor: universalColorPrimaryDefault,
                      onRatingUpdate: (String value) {},
                    ),
                  ],
                ),
                subtitle: Text(
                  review.review == null ? "N/A" : review.review!,
                  style: TextStyle(fontSize: 15),
                ),
              )
                  .box
                  .border(color: universalBlackTertiary, width: 1)
                  .padding(
                      EdgeInsets.only(left: 2, right: 2, top: 8, bottom: 8))
                  .margin(EdgeInsets.only(left: 9, right: 9, bottom: 5))
                  .make();
            },
          );
        } else {
          // If snapshot doesn't have data yet, you can show a loading indicator or placeholder.
          return CircularProgressIndicator();
        }
      },
    );
  }

  // Don't forget to dispose the stream controller when it's no longer need
}
