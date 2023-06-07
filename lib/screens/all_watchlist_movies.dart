import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../description.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class AllWatchlistMovieScreen extends StatelessWidget {
  final List watchlistMovies;

  const AllWatchlistMovieScreen({Key? key, required this.watchlistMovies});

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    int columnCount = 2;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xffd6069b),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Watchlist Movies",
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
              watchlistMovies.length,
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Description(
                                name: watchlistMovies[index]['original_title'],
                                description: watchlistMovies[index]['overview'],
                                bannerURL:
                                'https://image.tmdb.org/t/p/w500' +
                                    watchlistMovies[index]['backdrop_path'],
                                posterURL:
                                'https://image.tmdb.org/t/p/w500' +
                                    watchlistMovies[index]['poster_path'],
                                vote: watchlistMovies[index]['vote_average']
                                    .toString(),
                                launchOn: watchlistMovies[index]['release_date'],
                              ),
                            ),
                          );
                        },
                        child: Column(
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
                                          watchlistMovies[index]['poster_path'],
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
                                      color: PopularSeries.getCircleColor(watchlistMovies[index]['vote_average']),
                                    ),
                                    child: Center(
                                      child: Text(
                                        watchlistMovies[index]['vote_average'].toString(),
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
                                  text: watchlistMovies[index]['original_title'] != null
                                      ? watchlistMovies[index]['original_title']
                                      : 'Loading',
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
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
