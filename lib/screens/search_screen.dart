import 'dart:convert';
import 'package:couch_cinema/description_series.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../description.dart';

class FilmSearchScreen extends StatefulWidget {
  @override
  _FilmSearchScreenState createState() => _FilmSearchScreenState();
}

class _FilmSearchScreenState extends State<FilmSearchScreen> {
  List<dynamic> films = [];

  Future<void> searchFilms(String query) async {
    final apiKey =
        '24b3f99aa424f62e2dd5452b83ad2e43'; // Ersetzen Sie YOUR_API_KEY durch Ihren eigenen TMDb API-Schlüssel
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

    return Scaffold(
      backgroundColor: Colors.black, // Schwarzer Hintergrund
      body: Column(
        children: [
          SizedBox(
              height: MediaQuery.of(context).padding.top +
                  16), // Abstand zur Statusleiste
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                searchFilms(value);
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Suche nach einem Film oder einer Serie',
                hintStyle: TextStyle(color: Colors.grey),
                fillColor: Colors.grey[900],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimationLimiter(
              child: GridView.builder(
                padding: EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 70),
                itemCount: films.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final film = films[index];
                  String? mediaType = film['media_type'];
                  bool isMovie = mediaType == 'movie'? true: false;
                  return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: Duration(milliseconds: 500),
                      columnCount: 2,
                      child: ScaleAnimation(
                        duration: Duration(milliseconds: 900),
                        curve: Curves.fastLinearToSlowEaseIn,
                        child: FadeInAnimation(
                          child: GestureDetector(
                  onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => isMovie? DescriptionMovies(movieID: film['id'], isMovie: isMovie): DescriptionSeries(seriesID: film['id'], isMovie: isMovie),
                  ));
                  },
                            child: Container(
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF242323),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w200${film['poster_path']}',
                                      fit: BoxFit.cover,
                                      height: 200.0, // Specify a fixed height for images
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          film['title'] ?? film['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          '(${film['release_date']?.substring(0, 4) ?? film['first_air_date']?.substring(0, 4)})',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
