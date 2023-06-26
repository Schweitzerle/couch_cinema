import 'package:cached_network_image/cached_network_image.dart';
import 'package:couch_cinema/bottom_nav_bar.dart';
import 'package:couch_cinema/screens/all_reviews.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/text.dart';

class RatingsDisplayWidget extends StatelessWidget {
  final int id;
  final bool isMovie;
  final List<dynamic> reviews;
  final int movieID;

  RatingsDisplayWidget({
    required this.id,
    required this.isMovie,
    required this.reviews, required this.movieID,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              mod_Text(text: 'Reviews', color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) =>
                      AllReviewsScreen(movieID: id, isMovie: isMovie, appBarColor: Color(0xff540126),)
                  ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff690257), // Set custom background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Set custom corner radius
                  ),
                ),
                child: Text('All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: reviews.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final backgroundColor = index % 2 == 0 ? Color(0xff690257) : Color(0xff540126);

                return InkWell(
                  onTap: () {},
                  child: Container(
                    width: 240,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: CachedNetworkImage(
                                imageUrl: review['author_details']['avatar_path'] != null
                                    ? 'https://image.tmdb.org/t/p/w500${review['author_details']['avatar_path']}'
                                    : 'Failed Path',
                                imageBuilder: (context, imageProvider) => Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  mod_Text(
                                    text: review['author_details']['username'] ?? 'Loading',
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(CupertinoIcons.film_fill, color: Color(0xffd6069b), size: 16),
                                      SizedBox(width: 4),
                                      mod_Text(
                                        text: review['author_details']['rating'] != null
                                            ? review['author_details']['rating'].toString()
                                            : 'Loading',
                                        color: Colors.black,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Flexible(
                          flex: 4,
                          child: SingleChildScrollView(
                            child: mod_Text(
                              text: review['content'],
                              color: Colors.black,
                              size: 14,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            mod_Text(
                              text: review['created_at'],
                              color: Colors.grey,
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
