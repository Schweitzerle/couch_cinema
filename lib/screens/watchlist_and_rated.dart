import 'package:couch_cinema/widgets/movies.dart';
import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../widgets/popular_series.dart';
import '../widgets/rated_movies.dart';
import '../widgets/rated_series.dart';
import '../widgets/series.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with SingleTickerProviderStateMixin {
  List watchlistMovies = [];
  List watchlistSeries = [];
  List ratedMovies = [];
  List ratedSeries = [];
  final Future<String?> sessionID = SessionManager.getSessionId();
  final Future<int?> accountID = SessionManager.getAccountId();
  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
  late TabController _tabController;
  int? accountId = 0;
  String? sessionId = '';

  @override
  void initState() {
    loadMovies();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  loadMovies() async {
    accountId = await accountID;
    sessionId = await sessionID;

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

      Map<dynamic, dynamic> watchlistSeriesResults = await tmdbWithCustLogs.v3.account.getTvShowWatchList(
        sessionId!,
        accountId!,
      );

      Map<dynamic, dynamic> watchlistMoviesResults = await tmdbWithCustLogs.v3.account.getMovieWatchList(
        sessionId!,
        accountId!,
      );

      Map<dynamic, dynamic> ratedMoviesResults = await tmdbWithCustLogs.v3.account.getRatedMovies(
        sessionId!,
        accountId!,
      );

      Map<dynamic, dynamic> ratedSeriesResults = await tmdbWithCustLogs.v3.account.getRatedTvShows(
        sessionId!,
        accountId!,
      );

    setState(() {
      watchlistMovies =  watchlistMoviesResults['results'].reversed.toList();
      watchlistSeries = watchlistSeriesResults['results'].reversed.toList();
      ratedMovies = ratedMoviesResults['results'].reversed.toList();
      ratedSeries = ratedSeriesResults['results'].reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cinema'),
        backgroundColor: Color(0xffd6069b),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Watchlist'),
                Tab(text: 'Rated'),
              ],
              indicatorColor: Color(0xffd6069b),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView(
                    children: [
                      MoviesScreen(movies: watchlistMovies, allMovies: watchlistMovies, title: 'Watchlist Movies', buttonColor: Color(0xffd6069b), typeOfApiCall: 7, accountID: accountId, sessionID:  sessionId,),
                      SeriesScreen(series: watchlistSeries.length < 10 ? watchlistSeries: watchlistSeries.sublist(0, 10), allSeries: watchlistSeries, title: 'Watchlist Series', buttonColor: Color(0xffd6069b), typeOfApiCall: 7, accountID: accountId, sessionID: sessionId,),
                    ],
                  ),
                  ListView(
                    children: [
                      RatedMovies(ratedMovies: ratedMovies, allRatedMovies: ratedMovies, buttonColor: Color(0xffd6069b), accountID: accountId, sessionID: sessionId,),
                      RatedSeries(ratedSeries: ratedSeries, allRatedSeries: ratedSeries, buttonColor: Color(0xffd6069b), accountID: accountId, sessionID: sessionId,),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
