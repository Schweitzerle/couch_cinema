import 'package:couch_cinema/widgets/movies.dart';
import 'package:couch_cinema/widgets/series.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../widgets/popular_series.dart';
import 'package:firebase_database/firebase_database.dart';


class MainScreen extends StatefulWidget {
@override
_MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  List trendingMovies = [];
  List topratedMovies = [];
  List popularMovies = [];
  List upcomingMovies = [];
  List nowPlayingMovies = [];

  List trendingSeries = [];
  List topratedSeries = [];
  List popularSeries = [];
  List airingTodaySeries = [];
  List onTheAirSeries = [];

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

    Map trendingMoviesResults = await tmdbWithCustLogs.v3.trending.getTrending(mediaType: MediaType.movie);
    Map topratedMoviesResults = await tmdbWithCustLogs.v3.movies.getTopRated();
    Map popularMoviesResults = await tmdbWithCustLogs.v3.movies.getPopular();
    Map nowPlayingMoviesResults = await tmdbWithCustLogs.v3.movies.getNowPlaying();
    Map upcomingMoviesResults = await tmdbWithCustLogs.v3.movies.getUpcoming();

    Map popularSeriesResults = await tmdbWithCustLogs.v3.tv.getPopular();
    Map topratedSeriesResults = await tmdbWithCustLogs.v3.tv.getTopRated();
    Map trendingSeriesResults = await tmdbWithCustLogs.v3.trending.getTrending(mediaType: MediaType.tv);
    Map airingTodaySeriesResults = await tmdbWithCustLogs.v3.tv.getAiringToday();
    Map ontheAirSeriesResults = await tmdbWithCustLogs.v3.tv.getOnTheAir();

    setState(() {

      trendingMovies = trendingMoviesResults['results'];
      topratedMovies = topratedMoviesResults['results'];
      nowPlayingMovies = nowPlayingMoviesResults['results'];
      upcomingMovies = upcomingMoviesResults['results'];
      popularMovies = popularMoviesResults['results'];

      trendingSeries = trendingSeriesResults['results'];
      topratedSeries = topratedSeriesResults['results'];
      onTheAirSeries= ontheAirSeriesResults['results'];
      airingTodaySeries = airingTodaySeriesResults['results'];
      popularSeries = popularSeriesResults['results'];
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(padding: EdgeInsets.only(bottom: 50), child: ListView(children: [
        SeriesScreen(series: topratedSeries.length < 10 ? topratedSeries : topratedSeries.sublist(0, 10), allSeries: topratedSeries, title: 'Top Rated Series', buttonColor: Color(0xff540126),),
        MoviesScreen(movies: topratedMovies.length < 10 ? topratedMovies : topratedMovies.sublist(0, 10), allMovies: topratedMovies, title: 'Top Rated Movies', buttonColor: Color(0xff540126),),

        SeriesScreen(series: trendingSeries.length < 10 ? trendingSeries : trendingSeries.sublist(0, 10), allSeries: trendingSeries, title: 'Trending Series', buttonColor: Color(0xff540126),),
        MoviesScreen(movies: trendingMovies.length < 10 ? trendingMovies : trendingMovies.sublist(0, 10), allMovies: trendingMovies, title: 'Trending Movies', buttonColor: Color(0xff540126),),

        SeriesScreen(series: popularSeries.length < 10 ? popularSeries : popularSeries.sublist(0, 10), allSeries: popularSeries, title: 'Popular Series', buttonColor: Color(0xff540126),),
        MoviesScreen(movies: popularMovies.length < 10 ? popularMovies : popularMovies.sublist(0, 10), allMovies: popularMovies, title: 'Popular Movies', buttonColor: Color(0xff540126),),

        SeriesScreen(series: airingTodaySeries.length < 10 ? airingTodaySeries : airingTodaySeries.sublist(0, 10), allSeries: airingTodaySeries, title: 'Airing Today Series', buttonColor: Color(0xff540126),),
        MoviesScreen(movies: nowPlayingMovies.length < 10 ? nowPlayingMovies : nowPlayingMovies.sublist(0, 10), allMovies: nowPlayingMovies, title: 'Now Playing Movies', buttonColor: Color(0xff540126),),

        SeriesScreen(series: onTheAirSeries.length < 10 ? onTheAirSeries : onTheAirSeries.sublist(0, 10), allSeries: onTheAirSeries, title: 'On The Air Series', buttonColor: Color(0xff540126),),
        MoviesScreen(movies: upcomingMovies.length < 10 ? upcomingMovies : upcomingMovies.sublist(0, 10), allMovies: upcomingMovies, title: 'Upcoming Movies', buttonColor: Color(0xff540126),)

      ]),
    ));
  }
}