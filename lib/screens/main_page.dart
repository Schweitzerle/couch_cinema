import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../widgets/popular_series.dart';
import '../widgets/top_rated_movies.dart';
import '../widgets/trending.dart';

class MainScreen extends StatefulWidget {
@override
_MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List trendingMovies = [];
  List topratedMovies = [];
  List seriesPopular = [];
  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

  @override
  void initState() {
    loadMovies();
    super.initState();
  }

  loadMovies() async {
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
    Map trendingResults = await tmdbWithCustLogs.v3.trending.getTrending();
    Map topratedResults = await tmdbWithCustLogs.v3.movies.getTopRated();
    Map seriesPopularResults = await tmdbWithCustLogs.v3.tv.getPopular();

    setState(() {
      trendingMovies = trendingResults['results'];
      topratedMovies = topratedResults['results'];
      seriesPopular = seriesPopularResults['results'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(padding: EdgeInsets.only(bottom: 40), child: ListView(children: [
        PopularSeries(popularSeries: seriesPopular),
        TopRatedMovies(topRatedMovies: topratedMovies),
        TrendingMovies(trending: trendingMovies)
      ]),
    ));
  }
}