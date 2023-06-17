import 'package:couch_cinema/description_series.dart';
import 'package:couch_cinema/screens/all_rated_series.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/screens/all_series.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../description.dart';

class SeriesScreen extends StatelessWidget {
  final List series;
  final List allSeries;
  final String title;
  final Color buttonColor;

  const SeriesScreen({Key? key, required this.series, required this.allSeries, required this.title, required this.buttonColor}) : super(key: key);

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
              mod_Text(text: title, color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllSeriesScreen(
                          series: allSeries, title: title, appBarColor: buttonColor,
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
            height: 200,
            child: ListView.builder(
              itemCount: series.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final show = series[index];
                final name = show['original_name'] != null ? show['original_name'] as String : 'Loading';

                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DescriptionSeries(seriesID: series[index]['id'], isMovie: false)
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
                                'https://image.tmdb.org/t/p/w500${show['backdrop_path']}',
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
                                color: PopularSeries.getCircleColor(PopularSeries.parseDouble(show['vote_average'])),
                              ),
                              child: Center(
                                child: Text(
                                  show['vote_average'].toStringAsFixed(1),
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
