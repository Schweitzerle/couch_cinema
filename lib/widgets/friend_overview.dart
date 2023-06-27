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
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));



    Map<dynamic, dynamic> reccMovieResults =
    await tmdbWithCustLogs.v3.account.getFavoriteMovies(
      widget.sessionID,
      widget.accountID,
    );
    // Fetch all watchlist movies from all pages
    List<dynamic> allRecommendedSeries = [];
    Map<dynamic, dynamic> reccSeriesResults =
    await tmdbWithCustLogs.v3.account.getFavoriteTvShows(
      widget.sessionID,
      widget.accountID,
    );



      Map<dynamic, dynamic> ratedMoviesResults =
      await tmdbWithCustLogs.v3.account.getRatedMovies(
        widget.sessionID,
        widget.accountID,
      );

      Map<dynamic, dynamic> ratedSeriesResults =
      await tmdbWithCustLogs.v3.account.getRatedTvShows(
        widget.sessionID,
        widget.accountID,
      );

    setState(() {
      recommendedMovies.addAll(reccMovieResults['results'].reversed.toList());
      recommendedSeries.addAll(reccSeriesResults['results'].reversed.toList());
      ratedMovies.addAll(ratedMoviesResults['results'].reversed.toList());
      ratedSeries.addAll(ratedSeriesResults['results'].reversed.toList());
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
          MoviesScreen(
            movies: recommendedMovies,
            allMovies: recommendedMovies,
            title: 'Recommended Movies',
            buttonColor: Color(0xff690257),
            typeOfApiCall: 9,
          ),
           SeriesScreen(
            series: recommendedSeries,
            allSeries: recommendedSeries, title: 'Recommended Series',
            buttonColor: Color(0xff690257), typeOfApiCall: 9,
          ),
          RatedMovies(
            ratedMovies: ratedMovies.length < 10 ? ratedMovies : ratedMovies
                .sublist(0, 10),
            allRatedMovies: ratedMovies, buttonColor: Color(0xff690257), accountID: widget.accountID, sessionID: widget.sessionID,
          ),
          RatedSeries(
            ratedSeries: ratedSeries.length < 10
                ? ratedSeries
                : ratedSeries.sublist(0, 10),
            allRatedSeries: ratedSeries, buttonColor: Color(0xff690257), accountID: widget.accountID, sessionID: widget.sessionID,
          ),
        ]),
        ));
  }

}
