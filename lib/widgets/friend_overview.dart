import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../Database/user.dart';
import '../widgets/popular_series.dart';
import '../widgets/rated_movies.dart';
import '../widgets/rated_series.dart';
import '../widgets/series.dart';
import 'package:firebase_database/firebase_database.dart';

import '../widgets/movies.dart';

class FriendScreen extends StatefulWidget {
  final int accountID;
  final String sessionID;
  final Color appBarColor;
  final String title;
  final User user;

  FriendScreen({
    Key? key, required this.accountID, required this.sessionID, required this.appBarColor, required this.title, required this.user,
  }) : super(key: key);

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> recommendedMovies = [];
  List<dynamic> recommendedSeries = [];
  List<dynamic> ratedMovies = [];
  List<dynamic> ratedSeries = [];


  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
  late TabController _tabController;


  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    loadMovies();
    super.initState();
  }

  loadMovies() async {
    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    int reccMovieTotalPages = 1;
    int reccSeriesTotalPages = 1;
    int ratedMoviesTotalPages = 1;
    int ratedSeriesTotalPages = 1;

    // Fetch the total number of pages for each API call
    Map<dynamic, dynamic> reccMovieInfo = await tmdbWithCustLogs.v3.account.getFavoriteMovies(
      widget.sessionID,
      widget.accountID,
      page: 1,
    );
    if (reccMovieInfo.containsKey('total_pages')) {
      reccMovieTotalPages = reccMovieInfo['total_pages'];
    }

    Map<dynamic, dynamic> reccSeriesInfo = await tmdbWithCustLogs.v3.account.getFavoriteTvShows(
      widget.sessionID,
      widget.accountID,
      page: 1,
    );
    if (reccSeriesInfo.containsKey('total_pages')) {
      reccSeriesTotalPages = reccSeriesInfo['total_pages'];
    }

    Map<dynamic, dynamic> ratedMoviesInfo = await tmdbWithCustLogs.v3.account.getRatedMovies(
      widget.sessionID,
      widget.accountID,
      page: 1,
    );
    if (ratedMoviesInfo.containsKey('total_pages')) {
      ratedMoviesTotalPages = ratedMoviesInfo['total_pages'];
    }

    Map<dynamic, dynamic> ratedSeriesInfo = await tmdbWithCustLogs.v3.account.getRatedTvShows(
      widget.sessionID,
      widget.accountID,
      page: 1,
    );
    if (ratedSeriesInfo.containsKey('total_pages')) {
      ratedSeriesTotalPages = ratedSeriesInfo['total_pages'];
    }

    // Fetch the last two pages for each API call
    List<Map<dynamic, dynamic>> reccMoviePages = [];
    List<Map<dynamic, dynamic>> reccSeriesPages = [];
    List<Map<dynamic, dynamic>> ratedMoviesPages = [];
    List<Map<dynamic, dynamic>> ratedSeriesPages = [];



    if (reccMovieTotalPages >= 1) {
      int lastPage = reccMovieTotalPages;
      if (lastPage > 0 && lastPage <= 1000) {
        Map<dynamic, dynamic> reccMovieResultsLast = await tmdbWithCustLogs.v3.account.getFavoriteMovies(
          widget.sessionID,
          widget.accountID,
          page: lastPage,
        );
        reccMoviePages.add(reccMovieResultsLast);

      }
      int secondLastPage = reccMovieTotalPages - 1;
      if (secondLastPage > 0 && secondLastPage <= 1000) {
        Map<dynamic, dynamic> reccMovieResultsSecondLast = await tmdbWithCustLogs.v3.account.getFavoriteMovies(
          widget.sessionID,
          widget.accountID,
          page: secondLastPage,
        );
        reccMoviePages.add(reccMovieResultsSecondLast);
      }
    }

    if (reccSeriesTotalPages >= 1) {
      int lastPage = reccSeriesTotalPages;
      if (lastPage > 0 && lastPage <= 1000) {
        Map<dynamic, dynamic> reccSeriesResultsLast = await tmdbWithCustLogs.v3.account.getFavoriteTvShows(
          widget.sessionID,
          widget.accountID,
          page: lastPage,
        );
        reccSeriesPages.add(reccSeriesResultsLast);
      }
      int secondLastPage = reccSeriesTotalPages - 1;
      if (secondLastPage > 0 && secondLastPage <= 1000) {
        Map<dynamic, dynamic> reccSeriesResultsSecondLast = await tmdbWithCustLogs.v3.account.getFavoriteTvShows(
          widget.sessionID,
          widget.accountID,
          page: secondLastPage,
        );
        reccSeriesPages.add(reccSeriesResultsSecondLast);
      }
    }

    if (ratedMoviesTotalPages >= 1) {
      int lastPage = ratedMoviesTotalPages;
      if (lastPage > 0 && lastPage <= 1000) {
        Map<dynamic, dynamic> ratedMoviesResultsLast = await tmdbWithCustLogs.v3.account.getRatedMovies(
          widget.sessionID,
          widget.accountID,
          page: lastPage,
        );
        ratedMoviesPages.add(ratedMoviesResultsLast);
      }
      int secondLastPage = ratedMoviesTotalPages - 1;
      if (secondLastPage > 0 && secondLastPage <= 1000) {
        Map<dynamic, dynamic> ratedMoviesResultsSecondLast = await tmdbWithCustLogs.v3.account.getRatedMovies(
          widget.sessionID,
          widget.accountID,
          page: secondLastPage,
        );
        ratedMoviesPages.add(ratedMoviesResultsSecondLast);
      }
    }

    if (ratedSeriesTotalPages >= 1) {
      int lastPage = ratedSeriesTotalPages;
      if (lastPage > 0 && lastPage <= 1000) {
        Map<dynamic, dynamic> ratedSeriesResultsLast = await tmdbWithCustLogs.v3.account.getRatedTvShows(
          widget.sessionID,
          widget.accountID,
          page: lastPage,
        );
        ratedSeriesPages.add(ratedSeriesResultsLast);
      }
      int secondLastPage = ratedSeriesTotalPages - 1;
      if (secondLastPage > 0 && secondLastPage <= 1000) {
        Map<dynamic, dynamic> ratedSeriesResultsSecondLast = await tmdbWithCustLogs.v3.account.getRatedTvShows(
          widget.sessionID,
          widget.accountID,
          page: secondLastPage,
        );
        ratedSeriesPages.add(ratedSeriesResultsSecondLast);
      }
    }

    // Combine the results and reverse the items of each page
    List<dynamic> reversedRecommendedMovies = [];
    for (var i = 0; i < reccMoviePages.length; i++) {
      reversedRecommendedMovies.addAll(reccMoviePages[i]['results'].reversed);
    }

    List<dynamic> reversedRecommendedSeries = [];
    for (var i = 0; i < reccSeriesPages.length; i++) {
      reversedRecommendedSeries.addAll(reccSeriesPages[i]['results'].reversed);
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
      recommendedMovies = reversedRecommendedMovies;
      recommendedSeries = reversedRecommendedSeries;
      ratedMovies = reversedRatedMovies;
      ratedSeries = reversedRatedSeries;
    });
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

        body: Padding(
          padding: EdgeInsets.only(), child: ListView(children: [
          Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: NetworkImage(widget.user.imagePath),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.user.username,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
          ),
          SizedBox(height: 10,),
          recommendedMovies.isNotEmpty ?
          MoviesScreen(
            movies: recommendedMovies.length< 10
                ? recommendedMovies
                : recommendedMovies.sublist(0, 10),
            allMovies: recommendedMovies,
            title: 'Recommended Movies',
            buttonColor: Color(0xff690257),
            typeOfApiCall: 9,  accountID: widget.accountID, sessionID: widget.sessionID,
          ) : Container(),
           recommendedSeries.isNotEmpty ?
           SeriesScreen(
            series: recommendedSeries.length< 10
                ? recommendedSeries
                : recommendedSeries.sublist(0, 10),
            allSeries: recommendedSeries, title: 'Recommended Series',
            buttonColor: Color(0xff690257), typeOfApiCall: 9,  accountID: widget.accountID, sessionID: widget.sessionID,
          ) : Container(),
          ratedMovies.isNotEmpty ?
          RatedMovies(
            ratedMovies: ratedMovies.length< 10
                ? ratedMovies
                : ratedMovies.sublist(0, 10),
            allRatedMovies: ratedMovies, buttonColor: Color(0xff690257), accountID: widget.accountID, sessionID: widget.sessionID,
          ) :Container(),
          ratedSeries.isNotEmpty ?
          RatedSeries(
            ratedSeries: ratedSeries.length < 10
                ? ratedSeries
                : ratedSeries.sublist(0, 10),
            allRatedSeries: ratedSeries, buttonColor: Color(0xff690257), accountID: widget.accountID, sessionID: widget.sessionID,
          ) : Container(),
        ]),
        ));
  }

}
