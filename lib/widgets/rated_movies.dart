import 'package:couch_cinema/screens/all_rated_movies.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../description.dart';

class RatedMovies extends StatelessWidget {
  final List ratedMovies;
  final List allRatedMovies;
  final Color buttonColor;

  const RatedMovies({Key? key, required this.ratedMovies, required this.allRatedMovies, required this.buttonColor}) : super(key: key);

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
              const mod_Text(text: 'Rated Movies', color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllRatedMovieScreen(
                          ratedMovies: allRatedMovies, appBarColor: buttonColor,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: buttonColor, // Set custom background color
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
                  itemCount: ratedMovies.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DescriptionMovies(movieID: ratedMovies[index]['id'], isMovie: true,
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
                                        ratedMovies[index]['poster_path'],
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
                                      PopularSeries.parseDouble(ratedMovies[index]['rating'])),
                                  ),
                                  child: Center(
                                    child: Text(
                                      ratedMovies[index]['rating'].toStringAsFixed(1),
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
                              text: ratedMovies[index]['original_title'] != null
                                  ? ratedMovies[index]['original_title']
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
