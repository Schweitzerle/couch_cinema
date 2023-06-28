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

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    int watchlistSeriesTotalPages = 1;
    int watchlistMoviesTotalPages = 1;
    int ratedMoviesTotalPages = 1;
    int ratedSeriesTotalPages = 1;

    // Fetch the total number of pages for each API call
    Map<dynamic, dynamic> watchlistSeriesInfo = await tmdbWithCustLogs.v3.account.getTvShowWatchList(
      sessionId!,
      accountId!,
      page: 1,
    );
    watchlistSeriesTotalPages = watchlistSeriesInfo['total_pages'];

    Map<dynamic, dynamic> watchlistMoviesInfo = await tmdbWithCustLogs.v3.account.getMovieWatchList(
      sessionId!,
      accountId!,
      page: 1,
    );
    watchlistMoviesTotalPages = watchlistMoviesInfo['total_pages'];

    Map<dynamic, dynamic> ratedMoviesInfo = await tmdbWithCustLogs.v3.account.getRatedMovies(
      sessionId!,
      accountId!,
      page: 1,
    );
    ratedMoviesTotalPages = ratedMoviesInfo['total_pages'];

    Map<dynamic, dynamic> ratedSeriesInfo = await tmdbWithCustLogs.v3.account.getRatedTvShows(
      sessionId!,
      accountId!,
      page: 1,
    );
    ratedSeriesTotalPages = ratedSeriesInfo['total_pages'];

    // Fetch the last two pages for each API call
    List<Map<dynamic, dynamic>> watchlistSeriesPages = [];
    List<Map<dynamic, dynamic>> watchlistMoviesPages = [];
    List<Map<dynamic, dynamic>> ratedMoviesPages = [];
    List<Map<dynamic, dynamic>> ratedSeriesPages = [];


    if (watchlistSeriesTotalPages >= 1) {
      int lastPage = watchlistSeriesTotalPages;
      if (lastPage > 0 && lastPage <= 1000) {
        Map<dynamic, dynamic> watchlistSeriesResultsLast = await tmdbWithCustLogs.v3.account.getTvShowWatchList(
          sessionId!,
          accountId!,
          page: lastPage,
        );
        watchlistSeriesPages.add(watchlistSeriesResultsLast);
      }
      int secondLastPage = watchlistSeriesTotalPages - 1;
      if (secondLastPage > 0 && secondLastPage <= 1000) {
        Map<dynamic, dynamic> watchlistSeriesResultsSecondLast = await tmdbWithCustLogs.v3.account.getTvShowWatchList(
          sessionId!,
          accountId!,
          page: secondLastPage,
        );
        watchlistSeriesPages.add(watchlistSeriesResultsSecondLast);
      }
    }


    if (watchlistMoviesTotalPages >= 1) {
      int lastPage = watchlistMoviesTotalPages;
      if (lastPage > 0 && lastPage <= 1000) {
        Map<dynamic, dynamic> watchlistMoviesResultsLast = await tmdbWithCustLogs.v3.account.getMovieWatchList(
          sessionId!,
          accountId!,
          page: lastPage,
        );
        watchlistMoviesPages.add(watchlistMoviesResultsLast);
      }
      int secondLastPage = watchlistMoviesTotalPages - 1;
      if (secondLastPage > 0 && secondLastPage <= 1000) {
        Map<dynamic, dynamic> watchlistMoviesResultsSecondLast = await tmdbWithCustLogs.v3.account.getMovieWatchList(
          sessionId!,
          accountId!,
          page: secondLastPage,
        );
        watchlistMoviesPages.add(watchlistMoviesResultsSecondLast);
      }
    }

    if (ratedSeriesTotalPages >= 1) {
      int lastPage = ratedSeriesTotalPages;
      if (lastPage > 0 && lastPage <= 1000) {
        Map<dynamic, dynamic> ratedSeriesResultsLast = await tmdbWithCustLogs.v3.account.getRatedTvShows(
          sessionId!,
          accountId!,
          page: lastPage,
        );
        ratedSeriesPages.add(ratedSeriesResultsLast);
      }
      int secondLastPage = ratedSeriesTotalPages - 1;
      if (secondLastPage > 0 && secondLastPage <= 1000) {
        Map<dynamic, dynamic> ratedSeriesResultsSecondLast = await tmdbWithCustLogs.v3.account.getRatedTvShows(
          sessionId!,
          accountId!,
          page: secondLastPage,
        );
        ratedSeriesPages.add(ratedSeriesResultsSecondLast);
      }
    }


    if (ratedMoviesTotalPages >= 1) {
      int lastPage = ratedMoviesTotalPages;
      if (lastPage > 0 && lastPage <= 1000) {
        Map<dynamic, dynamic> ratedMoviesResultsLast = await tmdbWithCustLogs.v3.account.getRatedMovies(
          sessionId!,
          accountId!,
          page: lastPage,
        );
        ratedMoviesPages.add(ratedMoviesResultsLast);
      }
      int secondLastPage = ratedMoviesTotalPages - 1;
      if (secondLastPage > 0 && secondLastPage <= 1000) {
        Map<dynamic, dynamic> ratedMoviesResultsSecondLast = await tmdbWithCustLogs.v3.account.getRatedMovies(
          sessionId!,
          accountId!,
          page: secondLastPage,
        );
        ratedMoviesPages.add(ratedMoviesResultsSecondLast);
      }
    }



    // Combine the results and reverse the items of each page
    List<dynamic> reversedWatchlistMovies = [];
    for (var i = 0; i < watchlistMoviesPages.length; i++) {
      reversedWatchlistMovies.addAll(watchlistMoviesPages[i]['results'].reversed);
    }

    List<dynamic> reversedWatchlistSeries = [];
    for (var i = 0; i < watchlistSeriesPages.length; i++) {
      reversedWatchlistSeries.addAll(watchlistSeriesPages[i]['results'].reversed);
    }

    List<dynamic> reversedRatedMovies = [];
    for (var i = 0; i < ratedMoviesPages.length; i++) {
      reversedRatedMovies.addAll(ratedMoviesPages[i]['results'].reversed);
    }

    List<dynamic> reversedRatedSeries = [];
    for (var i = 0; i < ratedSeriesPages.length; i++) {
      reversedRatedSeries.addAll(ratedSeriesPages[i]['results'].reversed);
    }


    setState(() {
      watchlistMovies = reversedWatchlistMovies;
      watchlistSeries = reversedWatchlistSeries;
      ratedMovies = reversedRatedMovies;
      ratedSeries = reversedRatedSeries;
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
                      watchlistMovies.isNotEmpty ?
                      MoviesScreen(movies: watchlistMovies.length < 10 ? watchlistMovies: watchlistMovies.sublist(0, 10), allMovies: watchlistMovies, title: 'Watchlist Movies', buttonColor: Color(0xffd6069b), typeOfApiCall: 7, accountID: accountId, sessionID:  sessionId,) : Container(),
                      watchlistSeries.isNotEmpty ? SeriesScreen(series: watchlistSeries.length < 10 ? watchlistSeries: watchlistSeries.sublist(0, 10), allSeries: watchlistSeries, title: 'Watchlist Series', buttonColor: Color(0xffd6069b), typeOfApiCall: 7, accountID: accountId, sessionID: sessionId,) : Container(),
                    ],
                  ),
                  ListView(
                    children: [
                      ratedMovies.isNotEmpty ? RatedMovies(ratedMovies: ratedMovies.length < 10 ? ratedMovies : ratedMovies.sublist(0, 10), allRatedMovies: ratedMovies, buttonColor: Color(0xffd6069b), accountID: accountId, sessionID: sessionId,) : Container(),
                      ratedSeries.isNotEmpty ? RatedSeries(ratedSeries: ratedSeries.length < 10 ? ratedSeries : ratedSeries.sublist(0, 10), allRatedSeries: ratedSeries, buttonColor: Color(0xffd6069b), accountID: accountId, sessionID: sessionId,) : Container(),
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
