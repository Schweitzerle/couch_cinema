import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../main.dart';

class UserProfileScreen extends StatefulWidget {


  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final Future<String?> sessionID = SessionManager.getSessionId();
  final Future<int?> accountID = SessionManager.getAccountId();
  String name = '';
  String imagePath = '';
  String username = '';
  int moviesRanked = 0;
  int friendsCount = 0;
  List rankedMovies = [];
  List rankedSeries = [];
  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';


  @override
  initState() {
    super.initState();
    loadData();
  }


  void loadData() async{
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/account/$accountId?api_key=$apiKey&session_id=$sessionId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Access the avatar path from the response data
      final namePath = data["name"];
      final userNamePath = data["username"];
      final avatarPath = data['avatar']['tmdb']['avatar_path'];

      // Construct the full URL for the avatar image
      final imageUrl = 'https://image.tmdb.org/t/p/w500$avatarPath';

      // Use the imageUrl as needed (e.g., display the image in a Flutter app)

      imagePath = imageUrl;
      username = userNamePath;
      name = namePath;
    } else {
      print('Error: ${sessionId}');
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
      rankedMovies = allRatedMovies;
      rankedSeries = allRatedSeries;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  logout(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff270140), // Set custom color here
                ),
                child: Text('Logout'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(imagePath),
                  ),
                  SizedBox(height: 40.0),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 70.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileStat('Movies Ranked', rankedMovies.length.toString()),
                      _buildProfileStat('Series Ranked', rankedSeries.length.toString()),
                      _buildProfileStat('Friends', '0'.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('sessionId');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => MyHomePage()),
          (route) => false,
    );
  }





}