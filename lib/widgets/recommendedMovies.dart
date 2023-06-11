import 'package:couch_cinema/screens/all_rated_movies.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';

import '../description.dart';

class RecommendedMovies extends StatelessWidget {
  final List recommendedMovies;
  final List allRecommmendedMovies;

  const RecommendedMovies({Key? key, required this.recommendedMovies, required this.allRecommmendedMovies}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const mod_Text(text: 'Recommended Movies', color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllMoviesScreen(
                          movies: allRecommmendedMovies, title: 'Recommended Movies',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xffd6069b), // Set custom background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Set custom corner radius
                  ),
                ),
                child: Text('All'),
              ),
              ],
          ),
              const SizedBox(height: 10),
              SizedBox(
                height: 270,
                child: ListView.builder(
                  itemCount: recommendedMovies.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DescriptionMovies(movieID: recommendedMovies[index]['id'], isMovie: true,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://image.tmdb.org/t/p/w500' +
                                        recommendedMovies[index]['poster_path'],
                                  ),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: PopularSeries.getCircleColor(
                                      PopularSeries.parseDouble(recommendedMovies[index]['vote_average'])),
                                  ),
                                  child: Center(
                                    child: Text(
                                      recommendedMovies[index]['vote_average'].toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            mod_Text(
                              text: recommendedMovies[index]['original_title'] != null
                                  ? recommendedMovies[index]['original_title']
                                  : 'Loading',
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

      ),
    );
  }

}
