import 'package:couch_cinema/description_series.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../description.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class AllRatedSeriesScreen extends StatelessWidget {
  final List ratedSeries;

  const AllRatedSeriesScreen({Key? key, required this.ratedSeries});

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
              "Rated Series",
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
              ratedSeries.length,
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
                              builder: (context) => DescriptionSeries(seriesID: ratedSeries[index]['id'], isMovie: false)
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Container(
                                width: 250,
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500' +
                                          ratedSeries[index]['backdrop_path'],
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
                                      color: PopularSeries.getCircleColor(ratedSeries[index]['rating']),
                                    ),
                                    child: Center(
                                      child: Text(
                                        ratedSeries[index]['rating'].toString(),
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
                                  text: ratedSeries[index]['original_title'] != null
                                      ? ratedSeries[index]['original_title']
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
