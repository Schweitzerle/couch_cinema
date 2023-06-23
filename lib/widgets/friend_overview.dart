import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../Database/user.dart';
import '../widgets/friends_rated_movies.dart';
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
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    // Fetch all watchlist movies from all pages
    late List<dynamic> allLists = [];
    int listPage = 1;
    bool hasMoreListPages = true;
    int seriesListId = 0; // Initialize the seriesId variable outside the loop
    int movieListId = 0;

    while (hasMoreListPages) {
      Map<dynamic, dynamic> listResults =
      await tmdbWithCustLogs.v3.account.getCreatedLists(
        widget.sessionID,
        widget.accountID,
        page: listPage,
      );
      List<dynamic> lists = listResults['results'];

      allLists.addAll(lists);

      if (listPage == listResults['total_pages'] || lists.isEmpty) {
        hasMoreListPages = false;
      } else {
        listPage++;
      }

      for (final series in lists) {
        if (series['name'] == 'CouchCinema Recommended Series') {
          seriesListId = series['id'];
          break; // Exit the loop once the matching series is found
        }
      }

      for (final series in lists) {
        if (series['name'] == 'CouchCinema Recommended Movies') {
          movieListId = series['id'];
          break; // Exit the loop once the matching series is found
        }
      }
    }

    List<dynamic> allRecommendedMovies = [];
    Map<dynamic, dynamic> reccMovieResults =
    await tmdbWithCustLogs.v3.lists.getDetails(movieListId.toString());
    List<dynamic> reccMovies = reccMovieResults['items'];
    allRecommendedMovies.addAll(reccMovies);

    // Fetch all watchlist movies from all pages
    List<dynamic> allRecommendedSeries = [];
    Map<dynamic, dynamic> reccSeriesResults =
    await tmdbWithCustLogs.v3.lists.getDetails(seriesListId.toString());
    List<dynamic> reccSeries = reccSeriesResults['items'];
    allRecommendedMovies.addAll(reccSeries);

    // Fetch all rated movies from all pages
    List<dynamic> allRatedMovies = [];
    int ratedMoviesPage = 1;
    bool hasMoreRatedMoviesPages = true;

    while (hasMoreRatedMoviesPages) {
      Map<dynamic, dynamic> ratedMoviesResults =
      await tmdbWithCustLogs.v3.account.getRatedMovies(
        widget.sessionID,
        widget.accountID,
        page: ratedMoviesPage,
      );
      List<dynamic> ratedMovies = ratedMoviesResults['results'];


      allRatedMovies.addAll(ratedMovies);

      if (ratedMoviesPage == ratedMoviesResults['total_pages'] ||
          ratedMovies.isEmpty) {
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
      Map<dynamic, dynamic> ratedSeriesResults =
      await tmdbWithCustLogs.v3.account.getRatedTvShows(
        widget.sessionID,
        widget.accountID,
        page: ratedSeriesPage,
      );
      List<dynamic> ratedSeries = ratedSeriesResults['results'];

      allRatedSeries.addAll(ratedSeries);

      if (ratedSeriesPage == ratedSeriesResults['total_pages'] ||
          ratedSeries.isEmpty) {
        hasMoreRatedSeriesPages = false;
      } else {
        ratedSeriesPage++;
      }
    }
    setState(() {
      recommendedMovies.addAll(allRecommendedMovies.reversed.toList());
      recommendedSeries.addAll(allRecommendedSeries.reversed.toList());
      ratedMovies.addAll(allRatedMovies.reversed.toList());
      ratedSeries.addAll(allRatedSeries.reversed.toList());
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
          padding: EdgeInsets.only(bottom: 50), child: ListView(children: [
          Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 10,),
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
          MoviesScreen(
            movies: recommendedMovies.length < 10
                ? recommendedMovies
                : recommendedMovies.sublist(0, 10),
            allMovies: recommendedMovies,
            title: 'Recommended Movies',
            buttonColor: Color(0xff690257),
            typeOfApiCall: 1,
          ),
          /* SeriesScreen(
            series: recommendedSeries.length < 10
                ? recommendedSeries
                : recommendedSeries.sublist(0, 10),
            allSeries: recommendedSeries, title: 'Recommended Series',
            buttonColor: Color(0xff690257), typeOfApiCall: 1,
          ),*/
          FriendsRatedMovies(
            ratedMovies: ratedMovies.length < 10 ? ratedMovies : ratedMovies
                .sublist(0, 10),
            allRatedMovies: ratedMovies, buttonColor: Color(0xff690257),
          ),
          RatedSeries(
            ratedSeries: ratedSeries.length < 10
                ? ratedSeries
                : ratedSeries.sublist(0, 10),
            allRatedSeries: ratedSeries, buttonColor: Color(0xff690257),
          ),
        ]),
        ));
  }

}
