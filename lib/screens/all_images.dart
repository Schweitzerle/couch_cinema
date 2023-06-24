
import 'dart:convert';

import 'package:couch_cinema/peopleDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tmdb_api/tmdb_api.dart';

import 'package:http/http.dart' as http;
import '../movieDetail.dart';
import '../utils/SessionManager.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class AllImagesScreen extends StatefulWidget {
  final String title;
  final Color appBarColor;
  final int movieID;
  final int imageType;
  final bool isMovie;

  AllImagesScreen({super.key, required this.title, required this.appBarColor, required this.movieID, required this.imageType, required this.isMovie});

  @override
  _AllPeopleState createState() => _AllPeopleState();
}

class _AllPeopleState extends State<AllImagesScreen> {
  List images = [];

  @override
  void initState() {
    super.initState();
    getImages();
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
        if(widget.imageType == 0) {
          images = data['logos'];
        } else if(widget.imageType == 1) {
          images = data['backdrops'];
        } else if(widget.imageType == 2) {
          images = data['posters'];
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    int columnCount = 2;
    double initRating = 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: AnimationLimiter(
          child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(_w / 60),
            crossAxisCount: columnCount,
            childAspectRatio: 2 / 3, // Set the aspect ratio for the grid items
            mainAxisSpacing: 16, // Add spacing between grid items vertically
            crossAxisSpacing: 16, // Add spacing between grid items horizontally
            children: List.generate(
              images.length,
                  (int index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: Duration(milliseconds: 500),
                  columnCount: columnCount,
                  child: ScaleAnimation(
                    duration: Duration(milliseconds: 900),
                    curve: Curves.fastLinearToSlowEaseIn,
                    child: FadeInAnimation(
                      child: InkWell(
                        onLongPress: () {
                          /*getUserMovieRating(widget.movies[index]['id']);
                          print('Rat: '+initRating.toString());
                          MovieDialogHelper.showMovieRatingDialog(context, initRating, rating, widget.movies[index]['id']);
                        */},
                        onTap: () {
                        },
                        child: images[index]['file_path'] != null
                            ?
                            Column(
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          'https://image.tmdb.org/t/p/w500' +
                                              images[index]['file_path'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            :Container(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

