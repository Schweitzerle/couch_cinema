import 'package:couch_cinema/seriesDetail.dart';
import 'package:couch_cinema/screens/all_rated_series.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/screens/all_series.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../Database/userAccountState.dart';
import '../api/tmdb_api.dart';
import '../movieDetail.dart';
import '../utils/SessionManager.dart';

class SeriesScreen extends StatefulWidget {
  final List series;
  final List allSeries;
  final String title;
  final Color buttonColor;
  final int? serieID;
  final int typeOfApiCall;
  final int? accountID;
  final String? sessionID;
  final int? peopleID;

  const SeriesScreen({
    Key? key,
    required this.series,
    required this.allSeries,
    required this.title,
    required this.buttonColor, this.serieID, required this.typeOfApiCall, this.accountID, this.sessionID, this.peopleID,
  }) : super(key: key);

  @override
  _SeriesScreenState createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {


  Future<UserAccountState> getUserRating(int seriesId) async {
  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken =
  'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
  String? sessionId = await SessionManager.getSessionId();

  TMDB tmdbWithCustLogs = TMDB(
  ApiKeys(apiKey, readAccToken),
  logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
  );

  Map<dynamic, dynamic> ratedSeriesResult =
  await tmdbWithCustLogs.v3.tv.getAccountStatus(seriesId, sessionId: sessionId);

  // Extract the data from the ratedSeriesResult
  int seriesID = ratedSeriesResult['id'];
  bool favorite = ratedSeriesResult['favorite'];
  double ratedValue = 0.0; // Default value is 0.0

  if (ratedSeriesResult['rated'] is Map<String, dynamic>) {
  Map<String, dynamic> ratedData = ratedSeriesResult['rated'];
  ratedValue = ratedData['value']?.toDouble() ?? 0.0;
  }

  bool watchlist = ratedSeriesResult['watchlist'];

  UserAccountState userRatingData = UserAccountState(id: seriesID, favorite: favorite, watchlist: watchlist, ratedValue: ratedValue);

  return userRatingData;
  }


  @override
  void initState() {
    super.initState();
  }

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
              mod_Text(text: widget.title, color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllSeriesScreen(
                        series: widget.allSeries,
                        title: widget.title,
                        appBarColor: widget.buttonColor, seriesID: widget.serieID, typeOfApiCall: widget.typeOfApiCall, sessionID: widget.sessionID, accountID: widget.accountID, peopleID: widget.peopleID,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: widget.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: widget.series.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                Map<String, dynamic> series = widget.series[index];
                double voteAverage = double.parse(series['vote_average'].toString());


                return FutureBuilder<UserAccountState>(
                  future: getUserRating(series['id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerPlaceholder();
                    } else if (snapshot.hasError) {
                      return _buildErrorContainer();
                    } else {
                      UserAccountState? userRating = snapshot.data;

                      return InkWell(
                        onLongPress: () {
                          showRatingDialog(context, userRating!);
                        },
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DescriptionSeries(
                                seriesID: series['id'],
                                isMovie: false,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          width: 250,
                          child: Column(
                            children: [
                              Flexible(
                                child: Container(
                                  width: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://image.tmdb.org/t/p/w500${series['backdrop_path']}',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: PopularSeries.getCircleColor(
                                          PopularSeries.parseDouble(voteAverage),
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              voteAverage.toDouble().toStringAsFixed(1),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            userRating?.ratedValue != 0.0 ?
                                            SizedBox(height: 2):SizedBox(height: 0),
                                            userRating != 0.0 ?
                                            Text(
                                              userRating!.ratedValue.toStringAsFixed(1),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ):Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              mod_Text(
                                text: series['original_name'] ?? 'Loading',
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showRatingDialog(BuildContext context, UserAccountState userAccountState) {
    double rating = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: Color(0xff690257),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Rate This Movie',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          backgroundColor: Color(0xFF1f1f1f),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rating bar
                  FittedBox(
                      fit: BoxFit.fitWidth,
                      child: RatingBar.builder(
                        itemSize: 22,
                        initialRating: userAccountState.ratedValue,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        glowColor: Colors.pink,
                        glow: true,
                        unratedColor: Color(0xff690257),
                        itemCount: 10,
                        itemPadding: EdgeInsets.symmetric(horizontal: 1.5),
                        itemBuilder: (context, _) => Icon(
                          CupertinoIcons.film,
                          color: Color(0xffd6069b),
                        ),
                        onRatingUpdate: (updatedRating) {
                          rating = updatedRating;
                        },
                      )
                  )
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Logic to submit the rating
                deleteRating(context, rating, userAccountState.id);
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                // Logic to submit the rating
                submitRating(context, rating, userAccountState.id);
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
              },
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void submitRating(BuildContext context, double rating, int id) async {
    // Get the movie ID and rating from the state
    String? sessionId = await SessionManager.getSessionId();

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    int movieId = id;

    // Submit the rating
    try {
      await tmdbWithCustLogs.v3.tv
          .rateTvShow(movieId, rating, sessionId: sessionId);

      // Show a success message or perform any other action after successful rating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating submitted successfully'),
        ),
      );
    } catch (e) {
      // Show an error message or perform any other action on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit rating'),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  void deleteRating(BuildContext context, double rating, int id) async {
    // Get the session ID and account ID
    String? sessionId = await SessionManager.getSessionId();
    int? accountId = await SessionManager.getAccountId();

    // Create an instance of TMDB with the required API key and session ID
    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    // Get the movie ID and rating from the state
    int movieId = id;

    // Submit the rating
    try {
      await tmdbWithCustLogs.v3.tv.deleteRating(movieId, sessionId: sessionId);

      // Show a success message or perform any other action after successful rating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating deleted successfully'),
        ),
      );
    } catch (e) {
      // Show an error message or perform any other action on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete rating'),
        ),
      );
    }

    Navigator.of(context).pop();
  }


  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: widget.buttonColor,
      highlightColor: Colors.grey[600]!,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 250,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.error,
          color: Colors.white,
        ),
      ),
    );
  }
}
