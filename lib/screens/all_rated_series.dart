import 'package:couch_cinema/seriesDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../Database/userAccountState.dart';
import '../api/tmdb_api.dart';
import '../movieDetail.dart';
import '../utils/SessionManager.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class AllRatedSeriesScreen extends StatefulWidget {
  final List ratedSeries;
  final Color appBarColor;
  final int? accountID;
  final String? sessionID;


  const AllRatedSeriesScreen(
      {Key? key, required this.ratedSeries, required this.appBarColor, this.accountID, this.sessionID});

  @override
  _AllRatedSeriesState createState() => _AllRatedSeriesState();
}

class _AllRatedSeriesState extends State<AllRatedSeriesScreen> {
  int currentPage = 1;
  int itemsPerPage = 10;
  bool isLoadingMore = false;
  List<dynamic> allMovies = [];

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
    final totalPages = await _fetchTotalPages();
    final lastPage =  totalPages;

    final List<dynamic> initialMovies = await _fetchMoviesPage(lastPage);
    setState(() {
      allMovies.addAll(initialMovies.reversed);
      currentPage = lastPage;
    });
  }

  void _loadMoreMovies() async {
    if (!isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final nextPage =  currentPage - 1;
      final List<dynamic> nextMovies = await _fetchMoviesPage(nextPage);

      setState(() {
        allMovies.addAll(nextMovies.reversed);
        currentPage = nextPage;
        isLoadingMore = false;
      });
    }
  }


  Future<int> _fetchTotalPages() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    int totalPages = 1;


    final result = await tmdbWithCustLogs.v3.account.getRatedTvShows(
      widget.sessionID!,
      widget.accountID!,
    );
    totalPages = result['total_pages'];


    return totalPages;
  }

  Future<List<dynamic>> _fetchMoviesPage(int page) async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    Map<dynamic, dynamic> watchlistResults =
    await tmdbWithCustLogs.v3.account.getRatedTvShows(
      widget.sessionID!,
      widget.accountID!,
      page: page,
    );

    List<dynamic> watchlistSeries = watchlistResults['results'];

    return watchlistSeries;
  }


  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    int columnCount = 2;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Rated Series",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GridView.builder(
        controller: _scrollController,
        physics: ScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(_w / 60),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          childAspectRatio: 2 / 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: allMovies.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          return FutureBuilder<UserAccountState>(
            future: getUserRating(allMovies[index]['id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerPlaceholder();
              } else if (snapshot.hasError) {
                return _buildErrorContainer();
              } else {
                UserAccountState? userRating = snapshot.data;
                if (index == allMovies.length) {
                  // Show a loading indicator at the end
                  return Visibility(
                    visible: isLoadingMore,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 140,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                } else {
                  final movie = allMovies[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: Duration(milliseconds: 500),
                    columnCount: columnCount,
                    child: ScaleAnimation(
                      duration: Duration(milliseconds: 900),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: FadeInAnimation(
                        child: InkWell(
                          onLongPress: (){
                            showRatingDialog(context, userRating!);
                            HapticFeedback.lightImpact();
                          },                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DescriptionSeries(
                                  seriesID: allMovies[index]['id'],
                                  // Modify this line
                                  isMovie: true,
                                ),
                              ),
                            );
                          },
                          child: allMovies[index]['poster_path'] != null
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500' +
                                          allMovies[index][
                                          'poster_path'], // Modify this line
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    margin: EdgeInsets.all(1),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PopularSeries.getCircleColor(
                                          PopularSeries.parseDouble(
                                              allMovies[index]
                                              ['rating'])),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            allMovies[index]['rating']
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (userRating!.ratedValue != 0.0)
                                            SizedBox(height: 2),
                                          if (userRating!.ratedValue != 0.0)
                                            Text(
                                              userRating!.ratedValue.toStringAsFixed(1),
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
                              ),
                              SizedBox(height: 8),
                              Container(
                                margin:
                                EdgeInsets.symmetric(horizontal: 16),
                                child: Expanded(
                                  child: mod_Text(
                                    text: allMovies[index]
                                    ['original_name'] !=
                                        null
                                        ? allMovies[index][
                                    'original_name'] // Modify this line
                                        : 'Loading',
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          )
                              : Container(),
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          );
        },
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
    print('dialog: ' + movieId.toString() + ' ' + rating.toString() + ' ' + sessionId!);

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
