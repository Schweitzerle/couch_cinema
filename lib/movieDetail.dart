import 'dart:convert';

import 'package:couch_cinema/api/tmdb_api.dart';
import 'package:couch_cinema/widgets/images_screen.dart';
import 'package:couch_cinema/widgets/lists.dart';
import 'package:couch_cinema/widgets/movies.dart';
import 'package:couch_cinema/screens/watchlist_and_rated.dart';
import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:couch_cinema/widgets/genreWidget.dart';
import 'package:couch_cinema/widgets/people.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:couch_cinema/widgets/reviews.dart';
import 'package:couch_cinema/widgets/video_widget.dart';
import 'package:couch_cinema/widgets/watchProviders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:http/http.dart' as http;

import 'Database/WatchProvider.dart';
import 'seriesDetail.dart';

class DescriptionMovies extends StatefulWidget {
  final int movieID;
  late bool isMovie;

  DescriptionMovies({super.key, required this.movieID, required this.isMovie});

  @override
  _DescriptionState createState() => _DescriptionState();
}

class _DescriptionState extends State<DescriptionMovies> {
  Map<String, dynamic> dataColl = {};
  List creditData = [];
  List<WatchProvider> watchProvidersList = [];
  late Future<String?> sessionID = SessionManager.getSessionId();
  String sessionId = '';
  late String apiKey;
  double voteAverage = 0;
  String title = '';
  String posterUrl = '';
  String bannerUrl = '';
  String launchOn = '';
  String description = '';
  int id = 0;
  int revenue = 0;
  int runtime = 0;
  String status = '';
  String tagline = '';
  int budget = 0;
  double initialRating = 0.0;
  bool isRated = false;
  List recommendedMovies = [];
  List listsIn = [];
  List similarMovies = [];
  List genres = [];
  List imagePaths = [];
  List reviews = [];
  List keywords = [];
  List videoItems = [];

  bool watchlistState = false;
  bool reccState = false;

  @override
  void initState() {
    super.initState();
    apiKey = TMDBApiService.getApiKey();
    fetchData();
    getUserRating();
    getRecommendedMovies();
    getSimilarMovies();
    getListsIn();
    getImages();
    getReviews();
    getKeywords();
    getVideoItems();
  }

  Future<void> setIDs () async {
    sessionId = (await sessionID)!;
  }

  Future<void> getUserRating() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map<dynamic, dynamic> ratedMovieResult = await tmdbWithCustLogs.v3.movies
        .getAccountStatus(widget.movieID, sessionId: sessionId);

// Extract the data from the ratedMovieResult
    int? movieId = ratedMovieResult['id'];
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

  Future<void> getListsIn() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.movies.getLists(
      widget.movieID,
    );

    setState(() {
      listsIn = watchlistResults['results'];
    });
  }

  Future<void> getKeywords() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.movies.getKeywords(
      widget.movieID,
    );

    setState(() {
      keywords = watchlistResults['keywords'];
    });
  }

  Future<void> getImages() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.movies.getImages(
      widget.movieID,
    );

    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/${widget.movieID}/images?api_key=$apiKey&session_id=$sessionId'));

    if (response.statusCode == 200) {
      Map data = json.decode(response.body);

      // Access the avatar path from the response data

      setState(() {
        imagePaths = data['posters'];
      });
    }
  }

  Future<void> getRecommendedMovies() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.movies.getRecommended(
      widget.movieID,
    );

    setState(() {
      recommendedMovies = watchlistResults['results'];
    });
  }

  Future<void> getReviews() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.movies.getReviews(
      widget.movieID,
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

    Map watchlistResults = await tmdbWithCustLogs.v3.movies.getSimilar(
      widget.movieID,
    );
    setState(() {
      similarMovies = watchlistResults['results'];
    });
  }

  Future<void> getVideoItems() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    Map watchlistResults = await tmdbWithCustLogs.v3.movies.getVideos(
      widget.movieID,
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
    String? sessionId = await sessionID;
    int ID = widget.movieID;
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/$ID.?api_key=$apiKey&session_id=$sessionId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dataColl = data;
        voteAverage = PopularSeries.parseDouble(dataColl['vote_average']);
        title = dataColl['original_title'];

        posterUrl = 'https://image.tmdb.org/t/p/w500' + dataColl['poster_path'];
        bannerUrl =
            'https://image.tmdb.org/t/p/w500' + dataColl['backdrop_path'];
        launchOn = dataColl['release_date'];
        description = dataColl['overview'];
        id = dataColl['id'];
        revenue = dataColl['revenue'];
        runtime = dataColl['runtime'];
        status = dataColl['status'];
        tagline = dataColl['tagline'];
        budget = dataColl['budget'];
        genres = dataColl['genres'];
      });
    } else {
      throw Exception('Failed to fetch data');
    }

    Map credits = await tmdbWithCustLogs.v3.movies.getCredits(ID);
    setState(() {
      creditData = credits['cast'];
    });

    Map<String, dynamic> watchProviderData =
        await tmdbWithCustLogs.v3.movies.getWatchProviders(ID);

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
    // Extract the vote_average

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
                    bannerUrl,
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
              child: Flexible(
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title != '' ? title : 'Not Loaded',
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
                              dataColl['poster_path'] != null
                                  ? Container(
                                      height: 200,
                                      width: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          posterUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Positioned(
                                bottom: 1,
                                left: 1,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: PopularSeries.getCircleColor(
                                        voteAverage),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        initialRating != 0.0
                                            ? Text(
                                                initialRating
                                                    .toStringAsFixed(1),
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
                                Container(
                                  child: Text(
                                    tagline,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Status: $status',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Release: $launchOn',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Runtime: $runtime m',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Budget: ${budget.toString()}\$',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Revenue: ${revenue.toString()}\$',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
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
                            color: Color(0xff690257), isMovieKeyword: true, sessionID: sessionId,
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
                          SingleChildScrollView(
                            child: Text(
                              description,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
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
                          MoviesScreen(
                            movies: recommendedMovies,
                            allMovies: recommendedMovies,
                            title: 'Recommended Movies',
                            buttonColor: Color(0xff540126),
                            movieID: widget.movieID,
                            typeOfApiCall: 1,
                          ),
                          MoviesScreen(
                            movies: similarMovies,
                            allMovies: similarMovies,
                            title: 'Similar Movies',
                            buttonColor: Color(0xff540126),
                            movieID: widget.movieID,
                            typeOfApiCall: 0,
                          ),
                          RatingsDisplayWidget(
                            id: widget.movieID,
                            isMovie: true,
                            reviews: reviews,
                            movieID: widget.movieID,
                          ),
                          VideoWidget(
                              videoItems: videoItems,
                              title: 'Videos',
                              buttonColor: Color(0xff540126)),
                          ImageScreen(
                            images: imagePaths.length < 10
                                ? imagePaths
                                : imagePaths.sublist(0, 10),
                            movieID: widget.movieID,
                            title: 'Images',
                            buttonColor: Color(0xff540126),
                            backdrop: false,
                            overview: true,
                            isMovie: true,
                          ),
                          ListsScreen(
                            lists: listsIn,
                            allMovies: listsIn,
                            title: 'Featured Lists',
                            buttonColor: Color(0xff540126),
                            listID: widget.movieID,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: FoldableOptions(
              id: id,
              isMovie: true,
              isRated: isRated,
              initRating: initialRating,
              watchlistState: watchlistState, reccState: reccState,
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
  final bool isRated;
  final double initRating;
  bool watchlistState;
  bool reccState;

  FoldableOptions(
      {super.key,
      required this.id,
      required this.isMovie,
      required this.isRated,
      required this.initRating,
      required this.watchlistState, required this.reccState});

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

  double rating = 0.0;

  late Animation<double> verticalPadding;
  late AnimationController controller;
  final duration = const Duration(milliseconds: 190);

  int? moviesListId;
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

  @override
  void initState() {
    super.initState();
    setIDs();
    controller = AnimationController(vsync: this, duration: duration);

    final anim = CurvedAnimation(parent: controller, curve: Curves.linear);
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

      for (final movies in lists) {
        if (movies['name'] == 'CouchCinema Recommended Movies') {
          moviesListId = movies['id'];
          break; // Exit the loop once the matching series is found
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
    tmdbWithCustLogs.v3.account.addToWatchList(sessionId!, accountId!,
        widget.id, widget.isMovie ? MediaType.movie : MediaType.tv);
  }

  Future<void> removeFromWatchlist() async {
    // Implement the logic to remove the movie/TV show from the user's watchlist

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
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken() ),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    tmdbWithCustLogs.v3.account.markAsFavorite(sessionId!, accountId!, widget.id, widget.isMovie ? MediaType.movie: MediaType.tv);
  }

  Future<void> removeFromRecommendations() async {
    // Implement the logic to remove the movie/TV show from the user's watchlist
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken() ),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    tmdbWithCustLogs.v3.account.markAsFavorite(sessionId!, accountId!, widget.id, widget.isMovie ? MediaType.movie: MediaType.tv, isFavorite: false);
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
                        : Icons.recommend_outlined,
                    () {
                      toggleRecommended();
                      HapticFeedback.lightImpact;
                    },
                  ),
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
                    HapticFeedback.lightImpact();
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
                      HapticFeedback.lightImpact();
                      MovieDialogHelper.showMovieRatingDialog(
                          context, widget.initRating, rating, widget.id);
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

class MovieDialogHelper {
  static void showMovieRatingDialog(
      BuildContext context, double initRating, double updRating, int id) {
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
                        initialRating: initRating,
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
                          updRating = updatedRating;
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
                deleteMovieRating(context, updRating, id);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
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
                submitMovieRating(context, updRating, id);
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

  static void submitMovieRating(
      BuildContext context, double rating, int id) async {
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
      await tmdbWithCustLogs.v3.movies
          .rateMovie(movieId, rating, sessionId: sessionId);

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

  static void deleteMovieRating(
      BuildContext context, double rating, int id) async {
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
      await tmdbWithCustLogs.v3.movies
          .deleteRating(movieId, sessionId: sessionId);

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
}
