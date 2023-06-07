import 'package:couch_cinema/screens/all_watchlist_movies.dart';
import 'package:couch_cinema/screens/all_watchlist_series.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';

import '../description.dart';

class WatchlistSeries extends StatelessWidget {
  final List watchlistSeries;
  final List allWachlistSeries;

  const WatchlistSeries({Key? key, required this.watchlistSeries, required this.allWachlistSeries}) : super(key: key);

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
              const mod_Text(text: 'Series', color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllWatchlistSeriesScreen(
                          watchlistSeries: allWachlistSeries
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
                child: Text('All Series'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: watchlistSeries.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final series = watchlistSeries[index];
                final name = series['original_name'] != null ? series['original_name'] as String : 'Loading';

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Description(
                          name: name,
                          description: series['overview'],
                          bannerURL: 'https://image.tmdb.org/t/p/w500${series['backdrop_path']}',
                          posterURL: 'https://image.tmdb.org/t/p/w500${series['backdrop_path']}',
                          vote: series['vote_average'].toString(),
                          launchOn: series['first_air_date'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: 250,
                    child: Column(
                      children: [
                        Container(
                          width: 250,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://image.tmdb.org/t/p/w500${series['backdrop_path']}',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: PopularSeries.getCircleColor(series['vote_average']),
                              ),
                              child: Center(
                                child: Text(
                                  series['vote_average'].toString(),
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
                        const SizedBox(height: 10),
                        mod_Text(
                          text: name,
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
