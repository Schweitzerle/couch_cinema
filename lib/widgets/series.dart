import 'package:couch_cinema/seriesDetail.dart';
import 'package:couch_cinema/screens/all_rated_series.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/screens/all_series.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/SessionManager.dart';

class SeriesScreen extends StatefulWidget {
  final List series;
  final List allSeries;
  final String title;
  final Color buttonColor;

  const SeriesScreen({
    Key? key,
    required this.series,
    required this.allSeries,
    required this.title,
    required this.buttonColor,
  }) : super(key: key);

  @override
  _SeriesScreenState createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  Future<double> getUserRating(int seriesId) async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map<dynamic, dynamic> ratedSeriesResult =
    await tmdbWithCustLogs.v3.tv.getAccountStatus(seriesId, sessionId: sessionId);

    // Extract the data from the ratedSeriesResult
    int? seriesID = ratedSeriesResult['id'];
    bool favorite = ratedSeriesResult['favorite'];
    double ratedValue = 0.0; // Default value is 0.0

    if (ratedSeriesResult['rated'] is Map<String, dynamic>) {
      Map<String, dynamic> ratedData = ratedSeriesResult['rated'];
      ratedValue = ratedData['value']?.toDouble() ?? 0.0;
    }

    bool watchlist = ratedSeriesResult['watchlist'];

    return ratedValue;
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
                        appBarColor: widget.buttonColor,
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


                return FutureBuilder<double>(
                  future: getUserRating(series['id']),
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
                                            userRating != 0.0 ?
                                            SizedBox(height: 2):SizedBox(height: 0),
                                            userRating != 0.0 ?
                                            Text(
                                              userRating.toStringAsFixed(1),
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

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: widget.buttonColor,
      highlightColor: Colors.grey[100]!,
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
