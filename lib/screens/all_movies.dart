
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/SessionManager.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class AllMoviesScreen extends StatefulWidget {
  final List movies;
  final String title;
  final Color appBarColor;

  AllMoviesScreen({super.key, required this.movies, required this.title, required this.appBarColor});

  @override
  _AllMoviesState createState() => _AllMoviesState();
}

class _AllMoviesState extends State<AllMoviesScreen> {




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
              widget.movies.length,
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
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DescriptionMovies(movieID: widget.movies[index]['id'], isMovie: true)
                            ),
                          );
                        },
                        child: widget.movies[index]['poster_path'] != null
                            ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Container(
                                width: 140,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500' +
                                          widget.movies[index]['poster_path'],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    margin: EdgeInsets.all(1),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PopularSeries.getCircleColor(PopularSeries.parseDouble(widget.movies[index]['vote_average'])),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.movies[index]['vote_average'].toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            SizedBox(height: 8),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16), // Add horizontal margin
                              child: Expanded(
                                child: mod_Text(
                                  text: widget.movies[index]['original_title'] != null
                                      ? widget.movies[index]['original_title']
                                      : 'Loading',
                                  color: Colors.white,
                                  size: 14,
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

