import 'package:couch_cinema/seriesDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../Database/userAccountState.dart';
import '../api/tmdb_api.dart';
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
      case 9:
        watchlistResults = await tmdbWithCustLogs.v3.account.getFavoriteTvShows(
          widget.sessionID!,
          widget.accountID!,
          page: page,
        );
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

              return FutureBuilder<UserAccountState>(
                future: getUserRating(seriesId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerPlaceholder();
                  } else if (snapshot.hasError) {
    return _buildErrorContainer(); } else {
                    UserAccountState? userRating = snapshot.data;

                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onLongPress: (){
                              showRatingDialog(context, userRating!);
                              HapticFeedback.lightImpact();
                            },
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
                                                    if (userRating!.ratedValue !=
                                                        0.0) SizedBox(
                                                        height: 2),
                                                    if (userRating!.ratedValue != 0.0)
                                                      Text(
                                                        userRating!.ratedValue
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

  void showRatingDialog(BuildContext context, UserAccountState userAccountState) {
    double rating = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: Color(0xff690257),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Rate This Series',
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

