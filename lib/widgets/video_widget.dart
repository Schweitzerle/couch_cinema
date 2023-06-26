import 'package:cached_network_image/cached_network_image.dart';
import 'package:couch_cinema/peopleDetail.dart';
import 'package:couch_cinema/screens/all_images.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/screens/all_people.dart';
import 'package:couch_cinema/screens/images_overview.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../movieDetail.dart';

class VideoWidget extends StatelessWidget {
  final List videoItems;
  final String title;
  final Color buttonColor;

  VideoWidget({
    Key? key,
    required this.videoItems,
    required this.title,
    required this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mod_Text(text: 'Videos', color: Colors.white, size: 22),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: videoItems.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final videoItem = videoItems[index];

                  YoutubePlayerController _controller = YoutubePlayerController(
                    initialVideoId: videoItem['key'],
                    flags: YoutubePlayerFlags(
                      autoPlay: false,
                      mute: true,
                      enableCaption: true,
                      loop: false,
                      controlsVisibleAtStart: true,
                    ),
                  );

                  return InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: YoutubePlayer(
                                    controller: _controller,
                                    showVideoProgressIndicator: true,
                                    progressIndicatorColor: buttonColor,
                                    progressColors: ProgressBarColors(
                                      playedColor: buttonColor,
                                      handleColor: buttonColor,
                                    ),
                                    onReady: () {},
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              videoItem['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Type: ${videoItem['type']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Official: ${videoItem['official'] ? 'Yes' : 'No'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Site: ${videoItem['site']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
