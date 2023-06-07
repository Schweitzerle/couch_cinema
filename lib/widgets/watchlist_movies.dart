import 'package:couch_cinema/screens/all_watchlist_movies.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';

import '../description.dart';

class WatchlistMovies extends StatelessWidget {
  final List watchlistMovies;
  final List allWatchlistMovies;

  const WatchlistMovies({Key? key, required this.watchlistMovies, required this.allWatchlistMovies})
      : super(key: key);

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
                      builder: (context) => AllWatchlistMovieScreen(
                        watchlistMovies: allWatchlistMovies
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xffd6069b), // Set custom background color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Set custom corner radius
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
              itemCount: watchlistMovies.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Description(
                          name: watchlistMovies[index]['original_title'],
                          description: watchlistMovies[index]['overview'],
                          bannerURL: 'https://image.tmdb.org/t/p/w500' +
                              watchlistMovies[index]['backdrop_path'],
                          posterURL: 'https://image.tmdb.org/t/p/w500' +
                              watchlistMovies[index]['poster_path'],
                          vote:
                              watchlistMovies[index]['vote_average'].toString(),
                          launchOn: watchlistMovies[index]['release_date'],
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
                                    watchlistMovies[index]['poster_path'],
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
                                    watchlistMovies[index]['vote_average']),
                              ),
                              child: Center(
                                child: Text(
                                  watchlistMovies[index]['vote_average']
                                      .toString(),
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
                          text: watchlistMovies[index]['original_title'] != null
                              ? watchlistMovies[index]['original_title']
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
