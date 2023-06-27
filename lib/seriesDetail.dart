import 'dart:convert';

import 'package:couch_cinema/api/tmdb_api.dart';
import 'package:couch_cinema/screens/watchlist_and_rated.dart';
import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:couch_cinema/widgets/genreWidget.dart';
import 'package:couch_cinema/widgets/images_screen.dart';
import 'package:couch_cinema/widgets/people.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:couch_cinema/widgets/reviews.dart';
import 'package:couch_cinema/widgets/series.dart';
import 'package:couch_cinema/widgets/video_widget.dart';
import 'package:couch_cinema/widgets/watchProviders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:http/http.dart' as http;

import 'Database/WatchProvider.dart';

class DescriptionSeries extends StatefulWidget {
  final int seriesID;
  late bool isMovie;

  DescriptionSeries({Key? key, required this.seriesID, required this.isMovie})
      : super(key: key);

  @override
  _DescriptionSeriesState createState() => _DescriptionSeriesState();
}

class _DescriptionSeriesState extends State<DescriptionSeries> {
  Map<String, dynamic> movieData = {};
  List creditData = [];
  List<WatchProvider> watchProvidersList = [];
  late Future<String?> sessionID;
  String? apiKey;
  double voteAverage = 0;
  String title = '';
  String posterUrl = '';
  String bannerUrl = '';
  String launchOn = '';
  String description = '';
  int id = 0;
  bool inProduction = false;
  int revenue = 0;
  int numberOfEpisodes = 0;
  int numberOfSeasons = 0;
  String status = '';
  String tagline = '';
  String type = '';
  double initialRating = 0.0;
  bool isRated = false;
  List recommendedSeries = [];
  List similarSeries = [];
  List images = [];
  List genres = [];
  List keywords = [];
  List reviews = [];
  List videoItems = [];

  bool watchlistState = false;
  bool reccState = false;

  @override
  void initState() {
    super.initState();
    sessionID = SessionManager.getSessionId();
    apiKey = TMDBApiService.getApiKey();
    fetchData();
    getUserRating();
    getRecommendedSeries();
    getSimilarMovies();
    getImages();
    getKeywords();
    getReviews();
    getVideoItems();
  }

  Future<void> getRecommendedSeries() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();
    int? accountId = await SessionManager.getAccountId();

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    late List<dynamic> allRecommendedSeries = [];
    int recomMoviesPage = 1;
    bool hasMoreRecomMoviePages = true;

    while (hasMoreRecomMoviePages) {
      Map<dynamic, dynamic> watchlistResults =
          await tmdbWithCustLogs.v3.tv.getRecommendations(
        widget.seriesID,
        page: recomMoviesPage,
      );
      List<dynamic> watchlistSeries = watchlistResults['results'];

      allRecommendedSeries.addAll(watchlistSeries);

      if (recomMoviesPage == watchlistResults['total_pages'] ||
          watchlistSeries.isEmpty) {
        hasMoreRecomMoviePages = false;
      } else {
        recomMoviesPage++;
      }
    }
    setState(() {
      recommendedSeries = allRecommendedSeries;
    });
  }

  Future<void> getReviews() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.tv.getReviews(
      widget.seriesID,
    );
    setState(() {
      reviews = watchlistResults['results'];
    });
  }

  Future<void> getSimilarMovies() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.tv.getSimilar(
      widget.seriesID,
    );
    setState(() {
      similarSeries = watchlistResults['results'];
    });
  }

  Future<void> getUserRating() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map<dynamic, dynamic> ratedMovieResult = await tmdbWithCustLogs.v3.tv
        .getAccountStatus(widget.seriesID, sessionId: sessionId);

// Extract the data from the ratedMovieResult
    int? seriesId = ratedMovieResult['id'];
    bool favorite = ratedMovieResult['favorite'];
    double ratedValue = 0.0; // Default value is 0.0

    if (ratedMovieResult['rated'] is Map<String, dynamic>) {
      Map<String, dynamic> ratedData = ratedMovieResult['rated'];
      ratedValue = ratedData['value']?.toDouble() ?? 0.0;
    }

    bool watchlist = ratedMovieResult['watchlist'];

    setState(() {
      initialRating = ratedValue;
      isRated = ratedValue == 0.0 ? false : true;
      watchlistState = watchlist;
      reccState = favorite;
    });
  }

  Future<void> getImages() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();

    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/tv/${widget.seriesID}/images?api_key=$apiKey&session_id=$sessionId'));

    if (response.statusCode == 200) {
      Map data = json.decode(response.body);

      // Access the avatar path from the response data

      setState(() {
        images = data['posters'];
      });
    }
  }

  Future<void> getKeywords() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.tv.getKeywords(
      widget.seriesID,
    );

    setState(() {
      keywords = watchlistResults['results'];
    });
  }

  Future<void> getVideoItems() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.tv.getVideos(
      widget.seriesID.toString(),
    );
    setState(() {
      videoItems = watchlistResults['results'];
    });
  }

  Future<void> fetchData() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );
    int ID = widget.seriesID;
    final url = Uri.parse(
        'https://api.themoviedb.org/3/tv/$ID?api_key=$apiKey&session_id=$sessionID');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        movieData = data;
        voteAverage =
            PopularSeries.parseDouble(movieData['vote_average']) ?? 0.0;
        title = movieData['original_name'] ?? '';
        bannerUrl = 'https://image.tmdb.org/t/p/w500' +
            (movieData['backdrop_path'] ?? '');
        launchOn = movieData['first_air_date'] ?? '';
        description = movieData['overview'] ?? '';
        id = movieData['id'] ?? 0;
        inProduction = movieData['in_production'] ?? '';
        numberOfEpisodes = movieData['number_of_episodes'] ?? 0;
        numberOfSeasons = movieData['number_of_seasons'] ?? 0;
        type = movieData['type'] ?? '';
        status = movieData['status'] ?? '';
        tagline = movieData['tagline'] ?? '';
        genres = movieData['genres'];
      });
    } else {
      throw Exception('Failed to fetch data');
    }
    Map credits = await tmdbWithCustLogs.v3.tv.getCredits(ID);
    setState(() {
      creditData = credits['cast'];
    });

    Map<dynamic, dynamic> watchProviderData =
        await tmdbWithCustLogs.v3.tv.getWatchProviders(ID.toString());

    watchProviderData['results'].forEach((country, data) {
      String link = data['link'];
      List<Map<String, dynamic>> flatrate =
          data['flatrate'] != null ? List.from(data['flatrate']) : [];
      List<Map<String, dynamic>> rent =
          data['rent'] != null ? List.from(data['rent']) : [];
      List<Map<String, dynamic>> buy =
          data['buy'] != null ? List.from(data['buy']) : [];

      WatchProvider watchProvider = WatchProvider(
        country: country,
        link: link,
        flatrate: flatrate,
        rent: rent,
        buy: buy,
      );

      watchProvidersList.add(watchProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.network(
                    'https://image.tmdb.org/t/p/w500' +
                        (movieData['backdrop_path'] ?? ''),
                    fit: BoxFit.cover,
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 100),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Not Loaded',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w500' +
                                      (movieData['poster_path'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              left: 1,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      PopularSeries.getCircleColor(voteAverage),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        voteAverage.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      initialRating != 0.0
                                          ? SizedBox(height: 2)
                                          : SizedBox(height: 0),
                                      initialRating != 0.0
                                          ? Text(
                                              initialRating.toStringAsFixed(1),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                tagline,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Type: $type',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Status: $status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'In production: ' + inProduction.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Release: ' + launchOn ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Seasons: $numberOfSeasons ($numberOfEpisodes Episodes)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          FittedBox(
                            child: GenreList(
                              genres: genres,
                              color: Color(0xff540126), isMovieKeyword: false,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GenreList(
                            genres: keywords,
                            color: Color(0xff690257), isMovieKeyword: false,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Description:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          WatchProvidersScreen(
                              watchProviders: watchProvidersList),
                          PeopleScreen(
                              people: creditData.length < 10
                                  ? creditData
                                  : creditData.sublist(0, 10),
                              allPeople: creditData,
                              title: 'Cast and Crew',
                              buttonColor: Color(0xff540126)),
                          SeriesScreen(
                            series: recommendedSeries,
                            allSeries: recommendedSeries,
                            buttonColor: Color(0xff540126),
                            title: 'Recommended Series',
                            typeOfApiCall: 1,
                          ),
                          SeriesScreen(
                              series: similarSeries,
                              allSeries: similarSeries,
                              title: 'Similar Series',
                              buttonColor: Color(0xff540126),
                              typeOfApiCall: 0),
                          RatingsDisplayWidget(
                            id: widget.seriesID,
                            isMovie: false,
                            reviews: reviews,
                            movieID: widget.seriesID,
                          ),
                          VideoWidget(
                              videoItems: videoItems,
                              title: 'Videos',
                              buttonColor: Color(0xff540126)),
                          ImageScreen(
                            images: images.length < 10
                                ? images
                                : images.sublist(0, 10),
                            movieID: widget.seriesID,
                            title: 'Images',
                            buttonColor: Color(0xff540126),
                            backdrop: false,
                            overview: true,
                            isMovie: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: FoldableOptions(
              id: id,
              isMovie: false,
              isRated: isRated,
              initRating: initialRating,
              watchlistState: watchlistState,
              reccState: reccState,
            ),
          ),
        ],
      ),
    );
  }
}

class FoldableOptions extends StatefulWidget {
  final int id;
  final bool isMovie;
  final double initRating;
  final bool isRated;
  bool watchlistState;
  bool reccState;

  FoldableOptions(
      {super.key,
      required this.id,
      required this.isMovie,
      required this.initRating,
      required this.isRated,
      required this.watchlistState,
      required this.reccState});

  @override
  _FoldableOptionsState createState() => _FoldableOptionsState();
}

class _FoldableOptionsState extends State<FoldableOptions>
    with SingleTickerProviderStateMixin {
  final List<IconData> options = [
    Icons.list_alt,
    Icons.bookmark_border,
    Icons.star_border,
  ];

  final Future<String?> sessionID = SessionManager.getSessionId();
  final Future<int?> accountID = SessionManager.getAccountId();

  late Animation<Alignment> firstAnim;
  late Animation<Alignment> secondAnim;
  late Animation<Alignment> thirdAnim;

  late Animation<double> verticalPadding;
  late AnimationController controller;
  final duration = Duration(milliseconds: 190);

  double rating = 0.0;

  int? seriesListId;
  int? accountId;
  String? sessionId;
  TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

  Widget getItem(IconData source, VoidCallback onTap) {
    final size = 45.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(0xffd6069b),
          borderRadius: BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: Icon(
          source,
          color: Colors.black.withOpacity(1.0),
          size: 20,
        ),
      ),
    );
  }

  Widget buildPrimaryItem(IconData source, VoidCallback onTap) {
    final size = 45.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0xff690257),
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0XFFE95A8B).withOpacity(0.8),
            blurRadius: verticalPadding.value,
          ),
        ],
      ),
      child: Icon(
        source,
        color: Colors.black.withOpacity(1),
        size: 20,
      ),
    );
  }

  void submitRating(BuildContext context, double rating) async {
    // Get the movie ID and rating from the state
    int movieId = widget.id;

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

  void deleteRating(BuildContext context, double rating) async {
    // Get the session ID and account ID
    String? sessionId = await SessionManager.getSessionId();
    int? accountId = await SessionManager.getAccountId();

    // Create an instance of TMDB with the required API key and session ID
    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    // Get the movie ID and rating from the state
    int movieId = widget.id;

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

  @override
  void initState() {
    super.initState();
    setIDs();
    controller = AnimationController(vsync: this, duration: duration);

    final anim =
        CurvedAnimation(parent: controller, curve: Curves.linearToEaseOut);
    firstAnim =
        Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.topRight)
            .animate(anim);
    secondAnim =
        Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.topLeft)
            .animate(anim);
    thirdAnim = Tween<Alignment>(
            begin: Alignment.centerRight, end: Alignment.centerLeft)
        .animate(anim);

    verticalPadding = Tween<double>(begin: 0, end: 37).animate(anim);
  }

  Future<void> setIDs() async {
    accountId = await accountID;
    sessionId = await sessionID;

    late List<dynamic> allLists = [];
    int listPage = 1;
    bool hasMoreListPages = true;

    while (hasMoreListPages) {
      Map<dynamic, dynamic> listResults =
          await tmdbWithCustLogs.v3.account.getCreatedLists(
        sessionId!,
        accountId!,
        page: listPage,
      );
      List<dynamic> lists = listResults['results'];

      allLists.addAll(lists);

      if (listPage == listResults['total_pages'] || lists.isEmpty) {
        hasMoreListPages = false;
      } else {
        listPage++;
      }

      for (final list in lists) {
        if (list['name'] == 'CouchCinema Recommended Series') {
          seriesListId = list['id'];
          break; // Exit the loop once the matching series list is found
        }
      }
    }
  }

  void toggleWatchlist() {
    setState(() {
      widget.watchlistState = !widget.watchlistState;
    });
    if (widget.watchlistState) {
      // Add to watchlist logic
      addToWatchlist();
    } else {
      // Remove from watchlist logic
      removeFromWatchlist();
    }
  }

  Future<void> addToWatchlist() async {
    // Implement the logic to add the movie/TV show to the user's watchlist
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(
        ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    tmdbWithCustLogs.v3.account.addToWatchList(sessionId!, accountId!,
        widget.id, widget.isMovie ? MediaType.movie : MediaType.tv);
  }

  Future<void> removeFromWatchlist() async {
    // Implement the logic to remove the movie/TV show from the user's watchlist
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(
        ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    tmdbWithCustLogs.v3.account.addToWatchList(sessionId!, accountId!,
        widget.id, widget.isMovie ? MediaType.movie : MediaType.tv,
        shouldAdd: false);
  }

  void toggleRecommended() {
    setState(() {
      widget.reccState = !widget.reccState;
    });
    if (widget.reccState) {
      // Add to watchlist logic
      addToRecommendations();
    } else {
      // Remove from watchlist logic
      removeFromRecommendations();
    }
  }

  Future<void> addToRecommendations() async {
    // Implement the logic to add the movie/TV show to the user's watchlist
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(
        ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    tmdbWithCustLogs.v3.account.markAsFavorite(sessionId!, accountId!,
        widget.id, widget.isMovie ? MediaType.movie : MediaType.tv);
  }

  Future<void> removeFromRecommendations() async {
    // Implement the logic to remove the movie/TV show from the user's watchlist
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(
        ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    tmdbWithCustLogs.v3.account.markAsFavorite(sessionId!, accountId!,
        widget.id, widget.isMovie ? MediaType.movie : MediaType.tv,
        isFavorite: false);
  }

  void showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: Color(0xff690257),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        initialRating: widget.initRating,
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
                      ))
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Logic to submit the rating
                deleteRating(context, rating);
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
                submitRating(context, rating);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 210,
      margin: EdgeInsets.only(right: 15),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              Align(
                alignment: firstAnim.value,
                child: Container(
                  padding: EdgeInsets.only(left: 37),
                  child: getItem(
                      widget.reccState
                          ? Icons.recommend
                          : Icons.recommend_outlined, () {
                    toggleRecommended();
                    HapticFeedback.lightImpact;
                  }),
                ),
              ),
              Align(
                alignment: secondAnim.value,
                child: Container(
                  padding:
                      EdgeInsets.only(left: 37, top: verticalPadding.value),
                  child: getItem(
                      widget.watchlistState
                          ? Icons.bookmark
                          : Icons.bookmark_border, () {
                    toggleWatchlist();
                    HapticFeedback.lightImpact;
                  }),
                ),
              ),
              Align(
                alignment: thirdAnim.value,
                child: Container(
                  padding:
                      EdgeInsets.only(left: 37, top: verticalPadding.value),
                  child: getItem(
                    widget.isRated
                        ? CupertinoIcons.star_fill
                        : CupertinoIcons.star,
                    () {
                      //Handle third button tap
                      showRatingDialog(context);
                      HapticFeedback.lightImpact();
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    controller.isCompleted
                        ? controller.reverse()
                        : controller.forward();
                  },
                  child: buildPrimaryItem(
                    controller.isCompleted || controller.isAnimating
                        ? Icons.close
                        : Icons.add,
                    () {
                      // Handle primary button tap
                      HapticFeedback.lightImpact();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
