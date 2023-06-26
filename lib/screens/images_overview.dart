import 'dart:convert';

import 'package:couch_cinema/widgets/images_screen.dart';
import 'package:couch_cinema/widgets/movies.dart';
import 'package:couch_cinema/widgets/people.dart';
import 'package:couch_cinema/widgets/series.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../utils/SessionManager.dart';
import '../widgets/popular_series.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;


class ImagesOverview extends StatefulWidget {
  final int movieID;
  final bool isMovie;

  const ImagesOverview({super.key, required this.movieID, required this.isMovie});


@override
_ImagesOverviewState createState() => _ImagesOverviewState();
}

class _ImagesOverviewState extends State<ImagesOverview> {

  List backdrops = [];
  List logos = [];
  List posters = [];
  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';


  @override
  void initState() {
    getImages();
    super.initState();
  }

  Future<void> getImages() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';
    String? sessionId = await SessionManager.getSessionId();


    final response = await http.get(Uri.parse(widget.isMovie ?
        'https://api.themoviedb.org/3/movie/${widget
            .movieID}/images?api_key=$apiKey&session_id=$sessionId' : 'https://api.themoviedb.org/3/tv/${widget
        .movieID}/images?api_key=$apiKey&session_id=$sessionId'));

    if (response.statusCode == 200) {
      Map data = json.decode(response.body);

      // Access the avatar path from the response data

      setState(() {
        backdrops = data['backdrops'];
        logos = data['logos'];
        posters = data['posters'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Images'),
        backgroundColor: Color(0xff540126),
      ),

      backgroundColor: Colors.black,
      body: Padding(padding: EdgeInsets.only(bottom: 0), child: ListView(children: [
        ImageScreen(images: logos.length < 10 ? logos : logos.sublist(0, 10), title: 'Backdrop Images', buttonColor: Color(0xff540126), movieID: widget.movieID, backdrop: true, overview: false, imageType: 0, isMovie: widget.isMovie,),

        ImageScreen(images: backdrops.length < 10 ? backdrops : backdrops.sublist(0, 10), title: 'Logo Images', buttonColor: Color(0xff540126), movieID: widget.movieID, backdrop: true, overview: false, imageType: 1, isMovie: widget.isMovie,),

        ImageScreen(images: posters.length < 10 ? posters : posters.sublist(0, 10), title: 'Poster Images', buttonColor: Color(0xff540126), movieID: widget.movieID, backdrop: false, overview: false, imageType: 2, isMovie: widget.isMovie,),


      ]),
    ));
  }
}
