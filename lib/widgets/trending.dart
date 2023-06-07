import 'package:couch_cinema/description.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';

class TrendingMovies extends StatelessWidget {
  final List trending;

  const TrendingMovies({Key? key, required this.trending}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const mod_Text(text: 'Trending Movies', color: Colors.white, size: 22),
          const SizedBox(height: 10),
          SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: trending.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Description(
                          name: trending[index]['title'],
                          description: trending[index]['overview'],
                          bannerURL: 'https://image.tmdb.org/t/p/w500' + trending[index]['backdrop_path'],
                          posterURL: 'https://image.tmdb.org/t/p/w500' + trending[index]['poster_path'],
                          vote: trending[index]['vote_average'].toString(),
                          launchOn: trending[index]['release_date'],
                        ),
                      ),
                    );
                  },
                  child: trending[index]['title'] != null
                      ? SizedBox(
                    width: 140,
                    child: Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://image.tmdb.org/t/p/w500' + trending[index]['poster_path'],
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
                                  color: PopularSeries.getCircleColor(trending[index]['vote_average']),
                                ),
                                child: Center(
                                  child: Text(
                                    trending[index]['vote_average'].toString(),
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
                            text: trending[index]['title'] ?? 'Loading',
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  )
                      : Container(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
