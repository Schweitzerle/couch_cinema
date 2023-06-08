import 'dart:convert';

import 'package:couch_cinema/api/tmdb_api.dart';
import 'package:couch_cinema/screens/watchlist_and_rated.dart';
import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:http/http.dart' as http;

class DescriptionSeries extends StatefulWidget {
  final int seriesID;
  late bool isMovie;

  DescriptionSeries({Key? key, required this.seriesID, required this.isMovie})
      : super(key: key);

  @override
  _DescriptionSeriesState createState() => _DescriptionSeriesState();
}

class _DescriptionSeriesState extends State<DescriptionSeries> {
  Map<String, dynamic> dataColl = {};
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

  @override
  void initState() {
    super.initState();
    sessionID = SessionManager.getSessionId();
    apiKey = TMDBApiService.getApiKey();
    fetchData();
  }

  fetchData() async {
    int ID = widget.seriesID;
    final url = Uri.parse(
        'https://api.themoviedb.org/3/tv/$ID?api_key=$apiKey&session_id=$sessionID');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dataColl = data;
        voteAverage = dataColl['vote_average'] ?? 0.0;
        title = dataColl['original_name'] ?? '';
        bannerUrl = 'https://image.tmdb.org/t/p/w500' + (dataColl['backdrop_path'] ?? '');
        launchOn = dataColl['first_air_date'] ?? '';
        description = dataColl['overview'] ?? '';
        id = dataColl['id'] ?? 0;
        inProduction = dataColl['in_production'] ?? '';
        numberOfEpisodes = dataColl['number_of_episodes'] ?? 0;
        numberOfSeasons = dataColl['number_of_seasons'] ?? 0;
        type = dataColl['type'] ?? '';
        status = dataColl['status'] ?? '';
        tagline = dataColl['tagline'] ?? '';
      });
    } else {
      throw Exception('Failed to fetch data');
    }
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
                    'https://image.tmdb.org/t/p/w500' + (dataColl['backdrop_path'] ?? ''),
                    fit: BoxFit.cover,
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 10,
            right: 10,
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
                                'https://image.tmdb.org/t/p/w500' + (dataColl['poster_path'] ?? ''),
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
                                color: PopularSeries.getCircleColor(
                                    voteAverage),
                              ),
                              child: Center(
                                child: Text(
                                  voteAverage.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
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
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    description ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FoldableOptions(id: id, isMovie: false,),
          ),
        ],
      ),
    );
  }
}

  class FoldableOptions extends StatefulWidget {
  final int id;
  final bool isMovie;

  const FoldableOptions({super.key, required this.id, required this.isMovie});
  @override
  _FoldableOptionsState createState() => _FoldableOptionsState();
}

class _FoldableOptionsState extends State<FoldableOptions> with SingleTickerProviderStateMixin {
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

  bool isAddedToWatchlist = false;

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
    final size = 55.0;
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

    verticalPadding = Tween<double>(begin: 0, end: 26).animate(anim);

      fetchWatchlist();
  }




  Future<void> fetchWatchlist() async {
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken()),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    // Fetch watchlist TV shows
    List<dynamic> allWatchlistSeries = [];
    int watchlistSeriesPage = 1;
    bool hasMoreSeriesWatchlistPages = true;

    while (hasMoreSeriesWatchlistPages) {
      Map<dynamic, dynamic> watchlistResults = await tmdbWithCustLogs.v3.account.getTvShowWatchList(
        sessionId!,
        accountId!,
        page: watchlistSeriesPage,
      );
      List<dynamic> watchlistSeries = watchlistResults['results'];

      allWatchlistSeries.addAll(watchlistSeries);

      if (watchlistSeriesPage == watchlistResults['total_pages'] || watchlistSeries.isEmpty) {
        hasMoreSeriesWatchlistPages = false;
      } else {
        watchlistSeriesPage++;
      }
    }

    // Fetch watchlist movies
    List<dynamic> allWatchlistMovies = [];
    int watchlistPage = 1;
    bool hasMoreWatchlistPages = true;

    while (hasMoreWatchlistPages) {
      Map<dynamic, dynamic> watchlistResults = await tmdbWithCustLogs.v3.account.getMovieWatchList(
        sessionId!,
        accountId!,
        page: watchlistPage,
      );
      List<dynamic> watchlistMovies = watchlistResults['results'];

      allWatchlistMovies.addAll(watchlistMovies);

      if (watchlistPage == watchlistResults['total_pages'] || watchlistMovies.isEmpty) {
        hasMoreWatchlistPages = false;
      } else {
        watchlistPage++;
      }
    }

    // Check if the current item is in the watchlist
    for (var series in allWatchlistSeries) {
      if (series['id'] == widget.id) {
        isAddedToWatchlist = true;
        break;
      }
    }
    if (!isAddedToWatchlist) {
      for (var movie in allWatchlistMovies) {
        if (movie['id'] == widget.id) {
          isAddedToWatchlist = true;
          break;
        }
      }
    }

    setState(() {
      isAddedToWatchlist = isAddedToWatchlist;
    });
  }


  void toggleWatchlist() {
    setState(() {
      isAddedToWatchlist = !isAddedToWatchlist;
    });
    if (isAddedToWatchlist) {
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
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken() ),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    tmdbWithCustLogs.v3.account.addToWatchList(sessionId!, accountId!, widget.id, widget.isMovie ? MediaType.movie: MediaType.tv);
  }

  Future<void> removeFromWatchlist() async {
    // Implement the logic to remove the movie/TV show from the user's watchlist
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(TMDBApiService.getApiKey(), TMDBApiService.getReadAccToken() ),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    tmdbWithCustLogs.v3.account.addToWatchList(sessionId!, accountId!, widget.id, widget.isMovie ? MediaType.movie: MediaType.tv, shouldAdd: false);
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
                child: getItem(
                  options.elementAt(0),
                      () {
                    // Handle first button tap
                  },
                ),
              ),
              Align(
                alignment: secondAnim.value,
                child: Container(
                  padding: EdgeInsets.only(left: 37, top: verticalPadding.value),
                  child: getItem(
                    isAddedToWatchlist ? Icons.bookmark : Icons.bookmark_border,
                    toggleWatchlist,
                  ),
                ),
              ),
              Align(
                alignment: thirdAnim.value,
                child: getItem(
                  options.elementAt(2),
                      () {
                    // Handle third button tap
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    controller.isCompleted ? controller.reverse() : controller.forward();
                  },
                  child: buildPrimaryItem(
                    controller.isCompleted || controller.isAnimating ? Icons.close : Icons.add,
                        () {
                      // Handle primary button tap
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
