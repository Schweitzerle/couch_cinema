import 'dart:convert';
import 'package:couch_cinema/screens/filter_screen.dart';
import 'package:couch_cinema/seriesDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class FilmSearchScreen extends StatefulWidget {
  @override
  _FilmSearchScreenState createState() => _FilmSearchScreenState();
}

class _FilmSearchScreenState extends State<FilmSearchScreen> {
  List<dynamic> films = [];

  Future<void> searchFilms(String query) async {
    final apiKey =
        '24b3f99aa424f62e2dd5452b83ad2e43'; // Replace with your own TMDb API key
    final url = Uri.parse(
        'https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$query');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    setState(() {
      films = data['results'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    int columnCount = 2;

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Film Search'),
          backgroundColor: Color(0xff480178),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Search'),
              Tab(text: 'Filters'),
            ],
            indicatorColor: Color(0xff480178),
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    cursorColor: Colors.black,
                    onSubmitted: (value) {
                      searchFilms(value);
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search for a movie or series...',
                      hintStyle: TextStyle(color: Colors.black45),
                      fillColor: Color(0xff480178),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: AnimationLimiter(
                      child: GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                            left: _w / 70,
                            right: _w / 70,
                            top: _w / 70,
                            bottom: 50),
                        crossAxisCount: columnCount,
                        childAspectRatio: 2 / 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: List.generate(
                          films.length,
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
                                      HapticFeedback.lightImpact();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => films[index]
                                                      ['media_type'] ==
                                                  'movie'
                                              ? DescriptionMovies(
                                                  movieID: films[index]['id'],
                                                  isMovie: true,
                                                )
                                              : DescriptionSeries(
                                                  seriesID: films[index]['id'],
                                                  isMovie: false),
                                        ),
                                      );
                                    },
                                    child: Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 140,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: DecorationImage(
                                                image: films[index]
                                                            ['poster_path'] !=
                                                        null
                                                    ? NetworkImage(
                                                        'https://image.tmdb.org/t/p/w200' +
                                                            films[index]
                                                                ['poster_path'],
                                                      )
                                                    : NetworkImage(
                                                        'https://placehold.co/600x400'),
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
                                                  color: PopularSeries
                                                      .getCircleColor(PopularSeries
                                                          .parseDouble(films[
                                                                  index][
                                                              'vote_average'])),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    films[index][
                                                                'vote_average'] !=
                                                            null
                                                        ? films[index]
                                                                ['vote_average']
                                                            .toStringAsFixed(1)
                                                        : '0',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Flexible(
                                            child: Column(children: [
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 16),
                                                child: Expanded(
                                                  child: mod_Text(
                                                    text: films[index]
                                                            ['title'] ??
                                                        films[index]['name'],
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 16),
                                                child: Expanded(
                                                  child: mod_Text(
                                                    text:
                                                        '(${films[index]['release_date'] ?? films[index]['first_air_date']})',
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          )
                                        ],
                                      ),
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
                ),
              ],
            ),
            Container(
              child: MovieFilterWidget()
              ),
          ],
        ),
      ),
    );
  }
}
