import 'package:cached_network_image/cached_network_image.dart';
import 'package:couch_cinema/peopleDetail.dart';
import 'package:couch_cinema/screens/all_images.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/screens/all_people.dart';
import 'package:couch_cinema/screens/images.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';

class ImageScreen extends StatelessWidget {
  final int movieID;
  final List images;
  final String title;
  final Color buttonColor;
  final bool backdrop;
  final bool overview;
  int? imageType;
  final bool isMovie;

  ImageScreen(
      {Key? key,
      required this.images,
      required this.title,
      required this.buttonColor, required this.movieID, required this.backdrop, required this.overview, this.imageType, required this.isMovie})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(images.toString());
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              mod_Text(text: title, color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => overview ? ImagesOverview(movieID: movieID, isMovie: isMovie,) : AllImagesScreen(title: 'Images', appBarColor: buttonColor, movieID: movieID, imageType: imageType!, isMovie: isMovie,)
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: buttonColor, // Set custom background color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Set custom corner radius
                  ),
                ),
                child: Text('All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          backdrop ?
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: images.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                  },
                  child: SizedBox(
                    width: 250,
                    child: Column(
                      children: [
                        Flexible(
                          child: Container(
                            width: 250,
                            child: CachedNetworkImage(
                              imageUrl: images[index]['file_path'] != null ? 'https://image.tmdb.org/t/p/w500' +
                                  images[index]['file_path'] : 'Failed Path',
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: imageProvider,
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ):
          SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: images.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                  },
                  child: SizedBox(
                    width: 140,
                    child: Column(
                      children: [
                        Flexible(
                          child: Container(
                            height: 200,
                            child: CachedNetworkImage(
                              imageUrl: images[index]['file_path'] != null ? 'https://image.tmdb.org/t/p/w500' +
                                  images[index]['file_path'] : 'Failed Path',
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: imageProvider,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
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
