import 'package:couch_cinema/seriesDetail.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../movieDetail.dart';

class PopularSeries extends StatelessWidget {
  final List popularSeries;

  const PopularSeries({Key? key, required this.popularSeries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const mod_Text(text: 'Popular Series', color: Colors.white, size: 22),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: popularSeries.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final series = popularSeries[index];
                Map<String, dynamic> data = series;
                final name = series['original_name'] != null ? series['original_name'] as String : 'Loading';
                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescriptionSeries(seriesID: data['id'], isMovie: false)
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
                                color: getCircleColor(parseDouble(series['vote_average'])),
                              ),
                              child: Center(
                                child: Text(
                                  series['vote_average'].toStringAsFixed(1),
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

  static double parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      // Handle other cases, such as string representation of a number
      return double.tryParse(value.toString()) ?? 0.0;
    }
  }


  static Color getCircleColor(double rating) {
    if (rating < 2.0) {
      return Color(0xFF212121);
    } else if (rating >= 2.5 && rating <= 5.0) {
      return Color(0xFF6E3A06);
    } else if (rating >= 5.0 && rating <= 7.0) {
      return Color(0xFF87868c);
    } else if (rating >= 7.0 && rating <= 8.5) {
      return Color(0xFFA48111);
    } else {
      return Color(0xFF6B0000);
    }
  }
}
