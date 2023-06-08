import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../widgets/popular_series.dart';
import '../widgets/rated_movies.dart';
import '../widgets/rated_series.dart';
import '../widgets/top_rated_movies.dart';
import '../widgets/trending.dart';
import '../widgets/watchlist_movies.dart';
import '../widgets/watchlist_series.dart';

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

  @override
  void initState() {
    loadMovies();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  loadMovies() async {
    int? accountId = await accountID;
    String? sessionId = await sessionID;

    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    // Fetch all watchlist movies from all pages
    late List<dynamic> allWatchlistSeries = [];
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

    // Fetch all watchlist movies from all pages
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

    // Fetch all rated movies from all pages
    List<dynamic> allRatedMovies = [];
    int ratedMoviesPage = 1;
    bool hasMoreRatedMoviesPages = true;

    while (hasMoreRatedMoviesPages) {
      Map<dynamic, dynamic> ratedMoviesResults = await tmdbWithCustLogs.v3.account.getRatedMovies(
        sessionId!,
        accountId!,
        page: ratedMoviesPage,
      );
      List<dynamic> ratedMovies = ratedMoviesResults['results'];

      allRatedMovies.addAll(ratedMovies);

      if (ratedMoviesPage == ratedMoviesResults['total_pages'] || ratedMovies.isEmpty) {
        hasMoreRatedMoviesPages = false;
      } else {
        ratedMoviesPage++;
      }
    }



    // Fetch all rated TV shows from all pages
    List<dynamic> allRatedSeries = [];
    int ratedSeriesPage = 1;
    bool hasMoreRatedSeriesPages = true;

    while (hasMoreRatedSeriesPages) {
      Map<dynamic, dynamic> ratedSeriesResults = await tmdbWithCustLogs.v3.account.getRatedTvShows(
        sessionId!,
        accountId!,
        page: ratedSeriesPage,
      );
      List<dynamic> ratedSeries = ratedSeriesResults['results'];

      allRatedSeries.addAll(ratedSeries);

      if (ratedSeriesPage == ratedSeriesResults['total_pages'] || ratedSeries.isEmpty) {
        hasMoreRatedSeriesPages = false;
      } else {
        ratedSeriesPage++;
      }
    }

    setState(() {
      watchlistMovies = allWatchlistMovies;
      watchlistSeries = allWatchlistSeries;
      ratedMovies = allRatedMovies;
      ratedSeries = allRatedSeries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(bottom: 40, top: 40),
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
                      WatchlistMovies(watchlistMovies: watchlistMovies.length < 10 ? watchlistMovies: watchlistMovies.sublist(0, 10), allWatchlistMovies: watchlistMovies,),
                      WatchlistSeries(watchlistSeries: watchlistSeries.length < 10 ? watchlistSeries: watchlistSeries.sublist(0, 10), allWachlistSeries: watchlistSeries,),
                    ],
                  ),
                  ListView(
                    children: [
                      RatedMovies(ratedMovies: ratedMovies.length < 10 ? ratedMovies: ratedMovies.sublist(0, 10), allRatedMovies: ratedMovies,),
                      RatedSeries(ratedSeries: ratedSeries.length < 10 ? ratedSeries: ratedSeries.sublist(0, 10), allRatedSeries: ratedSeries,),
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
