import 'package:couch_cinema/screens/all_rated_movies.dart';
import 'package:couch_cinema/screens/all_watchlist_movies.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';

import '../description.dart';

class RatedMovies extends StatelessWidget {
  final List ratedMovies;
  final List allRatedMovies;

  const RatedMovies({Key? key, required this.ratedMovies, required this.allRatedMovies}) : super(key: key);

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
              const mod_Text(text: 'Movies', color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllRatedMovieScreen(
                          ratedMovies: allRatedMovies
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
                child: Text('All Movies'),
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
                                        ratedMovies[index]['rating']),
                                  ),
                                  child: Center(
                                    child: Text(
                                      ratedMovies[index]['rating'].toString(),
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
