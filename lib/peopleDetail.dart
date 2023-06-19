import 'dart:convert';

import 'package:couch_cinema/api/tmdb_api.dart';
import 'package:couch_cinema/screens/watchlist_and_rated.dart';
import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:couch_cinema/widgets/movies.dart';
import 'package:couch_cinema/widgets/people.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:couch_cinema/widgets/series.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:http/http.dart' as http;

import 'seriesDetail.dart';

class DescriptionPeople extends StatefulWidget {
  final int peopleID;
  late bool isMovie;

  DescriptionPeople({super.key, required this.peopleID, required this.isMovie});

  @override
  _DescriptionState createState() => _DescriptionState();
}

class _DescriptionState extends State<DescriptionPeople> {
  Map<String, dynamic> dataColl = {};
  List movieData = [];
  List seriesData = [];
  late Future<String?> sessionID;
  late String apiKey;
  String title = '';
  String posterUrl = '';
  String birthday = '';
  String biography = '';
  int id = 0;
  String deathday = '';
  int gender = 0;
  String known_for_department = '';
  String placeOfBirth = '';

  @override
  void initState() {
    super.initState();
    sessionID = SessionManager.getSessionId();
    apiKey = TMDBApiService.getApiKey();
    fetchData();
  }

  fetchData() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );
    String? sessionId = await sessionID;
    int ID = widget.peopleID;
    final url = Uri.parse(
        'https://api.themoviedb.org/3/person/$ID.?api_key=$apiKey&session_id=$sessionId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dataColl = data;
        title = dataColl['name'] ?? '';
        posterUrl =
            'https://image.tmdb.org/t/p/w500' + dataColl['profile_path'];
        birthday = dataColl['birthday'] ?? '';
        biography = dataColl['biography'];
        id = dataColl['id'];
        deathday = dataColl['deathday'] ?? '';
        gender = dataColl['gender'];
        known_for_department = dataColl['known_for_department'] ?? '';
        placeOfBirth = dataColl['place_of_birth'] ?? '';
      });
    } else {
      throw Exception('Failed to fetch data');
    }
    print(dataColl.toString());

    Map movies = await tmdbWithCustLogs.v3.people.getMovieCredits(ID);
    Map series = await tmdbWithCustLogs.v3.people.getTvCredits(ID);
    setState(() {
      movieData = movies['cast'];
      seriesData = series['cast'];
    });
  }

  @override
  Widget build(BuildContext context) {
    String genderResult = gender == 2 ? 'Male' : 'Female';

    // Extract the vote_average
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                        title != 'null' ? title : 'Not Loaded',
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
                                    posterUrl,
                                    fit: BoxFit.cover,
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
                                    'Gender: $genderResult',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Birthday: $birthday',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                deathday.isNotEmpty
                                    ? SizedBox(height: 10)
                                    : SizedBox(
                                        height: 0,
                                      ),
                                deathday.isNotEmpty
                                    ? Container(
                                        child: Text(
                                          'Deathday: ${deathday}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Place of birth: $placeOfBirth',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Department: $known_for_department',
                                    style: TextStyle(
                                      color: Colors.white,
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
                          Text(
                            'Biography:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          SingleChildScrollView(
                            child: Text(
                              biography,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          movieData.isNotEmpty
                              ? MoviesScreen(
                                  movies: movieData.length < 10
                                      ? movieData
                                      : movieData.sublist(0, 10),
                                  allMovies: movieData,
                                  title: 'Movies contributed',
                                  buttonColor: Color(0xff540126),
                                )
                              : Container(),
                          seriesData.isNotEmpty
                              ? SeriesScreen(
                                  series: seriesData.length < 10
                                      ? seriesData
                                      : seriesData.sublist(0, 10),
                                  allSeries: seriesData,
                                  title: 'Series contributed',
                                  buttonColor: Color(0xff540126))
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
