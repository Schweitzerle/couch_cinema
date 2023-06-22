import 'package:couch_cinema/seriesDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../movieDetail.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/SessionManager.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';



class AllSeriesScreen extends StatefulWidget {
  final List series;
  final String title;
  final Color appBarColor;
  final int? seriesID;
  final int? accountID;
  final String? sessionID;
  final int typeOfApiCall;
  final int? peopleID;

  AllSeriesScreen({
    Key? key,
    required this.series,
    required this.title,
    required this.appBarColor,
    this.seriesID,
    this.accountID,
    this.sessionID,
    this.peopleID,
    required this.typeOfApiCall,
  }) : super(key: key);

  /*
  0:Similar
  1:Recommended
  2:Trending
  3:Popular
  4:TopRated
  5:OnTheAir
  6:AiringToday
  7:Watchlist
  8:PeopleContribution
   */

  @override
  _AllSeriesState createState() => _AllSeriesState();
}

class _AllSeriesState extends State<AllSeriesScreen> {
  int currentPage = 1;
  bool isLoadingMore = false;
  List<dynamic> allSeries = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMovies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!isLoadingMore && _scrollController.position.atEdge) {
      final isBottom = _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      if (isBottom) {
        _loadMoreMovies();
      }
    }
  }

  void _loadMovies() async {
    final List<dynamic> initialMovies = await _fetchMoviesPage(currentPage);
    setState(() {
      allSeries.addAll(initialMovies);
    });
  }

  void _loadMoreMovies() async {
    if (!isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final nextPage = currentPage + 1;
      final List<dynamic> nextMovies = await _fetchMoviesPage(nextPage);

      setState(() {
        allSeries.addAll(nextMovies);
        currentPage = nextPage;
        isLoadingMore = false;
      });
    }
  }

  Future<double> getUserRating(int seriesID) async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map<dynamic, dynamic> ratedMovieResult = await tmdbWithCustLogs.v3.tv
        .getAccountStatus(seriesID, sessionId: sessionId);

    double ratedValue = 0.0; // Default value is 0.0

    if (ratedMovieResult['rated'] is Map<String, dynamic>) {
      Map<String, dynamic> ratedData = ratedMovieResult['rated'];
      ratedValue = ratedData['value']?.toDouble() ?? 0.0;
    }

    return ratedValue;
  }

  Future<List<dynamic>> _fetchMoviesPage(int page) async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    Map<dynamic, dynamic> watchlistResults = {};

    switch (widget.typeOfApiCall) {
      case 0:
        watchlistResults = await tmdbWithCustLogs.v3.tv.getSimilar(
          widget.seriesID!,
          page: page,
        );
        break;
      case 1:
        watchlistResults = await tmdbWithCustLogs.v3.tv.getRecommendations(
          widget.seriesID!,
          page: page,
        );
        break;
      case 2:
        watchlistResults = await tmdbWithCustLogs.v3.trending
            .getTrending(mediaType: MediaType.tv, page: page);
        break;
      case 3:
        watchlistResults =
        await tmdbWithCustLogs.v3.tv.getPopular(page: page);
        break;
      case 4:
        watchlistResults =
        await tmdbWithCustLogs.v3.tv.getTopRated(page: page);
        break;
      case 5:
        watchlistResults =
        await tmdbWithCustLogs.v3.tv.getOnTheAir(page: page);
        break;
      case 6:
        watchlistResults =
        await tmdbWithCustLogs.v3.tv.getAiringToday(page: page);
        break;
      case 7:
        watchlistResults = await tmdbWithCustLogs.v3.account.getTvShowWatchList(
          widget.sessionID!,
          widget.accountID!,
          page: page,
        );
        break;
      case 8:
        if (page == 1) {
          watchlistResults = await tmdbWithCustLogs.v3.people.getTvCredits(
            widget.peopleID!,
          );
        } else {
          return []; // Return an empty list for subsequent pages
        }
        break;
    }

    List<dynamic> watchlistSeries = widget.typeOfApiCall == 8
        ? watchlistResults['cast']
        : watchlistResults['results'];

    return watchlistSeries;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          GridView.builder(
            controller: _scrollController,
            itemCount: allSeries.length + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (BuildContext context, int index) {
              if (index == allSeries.length) {
                if (isLoadingMore) {
                  return Container();
                } else {
                  return SizedBox();
                }
              }

              final series = allSeries[index];
              double voteAverage = double.parse(series['vote_average'].toString());
              int seriesId = series['id'];

              return FutureBuilder<double>(
                future: getUserRating(seriesId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerPlaceholder();
                  } else if (snapshot.hasError) {
    return _buildErrorContainer(); } else {
                    double userRating = snapshot.data ?? 0.0;

                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DescriptionSeries(
                                        seriesID: seriesId,
                                        isMovie: false,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            'https://image.tmdb.org/t/p/w500${series['poster_path']}',
                                            fit: BoxFit.cover,
                                          ),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: PopularSeries
                                                    .getCircleColor(
                                                  PopularSeries.parseDouble(
                                                      voteAverage),
                                                ),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    Text(
                                                      voteAverage
                                                          .toStringAsFixed(1),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                    if (userRating !=
                                                        0.0) SizedBox(
                                                        height: 2),
                                                    if (userRating != 0.0)
                                                      Text(
                                                        userRating
                                                            .toStringAsFixed(1),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    series['original_name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          if (isLoadingMore)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: widget.appBarColor,
      highlightColor: Colors.grey[600]!,
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 10,
              color: widget.appBarColor,
            ),
          ],
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

