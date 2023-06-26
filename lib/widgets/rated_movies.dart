import 'package:couch_cinema/screens/all_rated_movies.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/SessionManager.dart';

class RatedMovies extends StatefulWidget {
  final List ratedMovies;
  final List allRatedMovies;
  final Color buttonColor;
  final int? accountID;
  final String? sessionID;

  const RatedMovies(
      {Key? key,
      required this.ratedMovies,
      required this.allRatedMovies,
      required this.buttonColor,
      this.accountID,
      this.sessionID})
      : super(key: key);

  @override
  _RatedMoviesState createState() => _RatedMoviesState();
}

class _RatedMoviesState extends State<RatedMovies> {
  Future<double> getUserRating(int movieId) async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map<dynamic, dynamic> ratedMovieResult = await tmdbWithCustLogs.v3.movies
        .getAccountStatus(movieId, sessionId: sessionId);

    double ratedValue = 0.0; // Default value is 0.0

    if (ratedMovieResult['rated'] is Map<String, dynamic>) {
      Map<String, dynamic> ratedData = ratedMovieResult['rated'];
      ratedValue = ratedData['value']?.toDouble() ?? 0.0;
    }

    return ratedValue;
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
              const mod_Text(
                  text: 'Rated Movies', color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllRatedMovieScreen(
                        ratedMovies: widget.allRatedMovies,
                        appBarColor: widget.buttonColor,
                        accountID: widget.accountID,
                        sessionID: widget.sessionID,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: widget.buttonColor, // Set custom background color
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
          SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: widget.ratedMovies.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return FutureBuilder<double>(
                  future: getUserRating(widget.ratedMovies[index]['id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerPlaceholder();
                    } else if (snapshot.hasError) {
                      return _buildErrorContainer();
                    } else {
                      double userRating = snapshot.data ?? 0.0;

                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DescriptionMovies(
                                movieID: widget.ratedMovies[index]['id'],
                                isMovie: true,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 140,
                          child: Column(
                            children: [
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500' +
                                          widget.ratedMovies[index]
                                              ['poster_path'],
                                    ),
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
                                          PopularSeries.parseDouble(widget
                                              .ratedMovies[index]['rating'])),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.ratedMovies[index]['rating']
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              mod_Text(
                                text: widget.ratedMovies[index]
                                            ['original_title'] !=
                                        null
                                    ? widget.ratedMovies[index]
                                        ['original_title']
                                    : 'Loading',
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

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: widget.buttonColor,
      highlightColor: Colors.grey[600]!,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: 140,
        height: 270,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
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
