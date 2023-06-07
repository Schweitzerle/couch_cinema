import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';

import '../description.dart';

class TopRatedMovies extends StatelessWidget {
  final List topRatedMovies;

  const TopRatedMovies({Key? key, required this.topRatedMovies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const mod_Text(text: 'Top Rated Movies', color: Colors.white, size: 22),
          const SizedBox(height: 10),
          SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: topRatedMovies.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Description(
                          name: topRatedMovies[index]['title'],
                          description: topRatedMovies[index]['overview'],
                          bannerURL: 'https://image.tmdb.org/t/p/w500' + topRatedMovies[index]['backdrop_path'],
                          posterURL: 'https://image.tmdb.org/t/p/w500' + topRatedMovies[index]['poster_path'],
                          vote: topRatedMovies[index]['vote_average'].toString(),
                          launchOn: topRatedMovies[index]['release_date'],
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
                                'https://image.tmdb.org/t/p/w500' + topRatedMovies[index]['poster_path'],
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
                                color: PopularSeries.getCircleColor(topRatedMovies[index]['vote_average']),
                              ),
                              child: Center(
                                child: Text(
                                  topRatedMovies[index]['vote_average'].toString(),
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
                          text: topRatedMovies[index]['title'] != null ? topRatedMovies[index]['title'] : 'Loading',
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
