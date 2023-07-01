import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../seriesDetail.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class GenreButtonModel {
  final String id;
  final String name;
  bool isSelected;

  GenreButtonModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
}

class MovieFilterWidget extends StatefulWidget {
  @override
  _MovieFilterWidgetState createState() => _MovieFilterWidgetState();
}

class _MovieFilterWidgetState extends State<MovieFilterWidget> {
  List<String> selectedGenres = [];
  RangeValues voteAverageRange = RangeValues(1.0, 10.0);
  RangeValues releaseYearRange =
      RangeValues(1900.toDouble(), DateTime.now().year.toDouble());
  SortMoviesBy sortMoviesBy = SortMoviesBy.popularityDesc;

  List<Map<String, dynamic>> filteredMovies = [];

  List<GenreButtonModel> genresList = [];


  List<Map<SortMoviesBy, String>> sortByOptions = [
    {SortMoviesBy.popularityAsc: 'Popularity Ascending'},
    {SortMoviesBy.popularityDesc: 'Popularity Descending'},
    {SortMoviesBy.releaseDateAsc: 'Release Date Ascending'},
    {SortMoviesBy.releaseDateDesc: 'Release Date Descending'},
    {SortMoviesBy.voteAverageAsc: 'Vote Average Ascending'},
    {SortMoviesBy.voteAverageDesc: 'Vote Average Descending'},
    {SortMoviesBy.voteCountAsc: 'Vote Count Ascending'},
    {SortMoviesBy.voteCountDesc: 'Vote Count Descending'},
    {SortMoviesBy.orginalTitleAsc: 'Original Title Ascending'},
    {SortMoviesBy.orginalTitleDesc: 'Original Title Descending'},
    {SortMoviesBy.primaryReleaseDateAsc: 'Primary Release Date Ascending'},
    {SortMoviesBy.primaryReleaseDateDesc: 'Primary Release Date Descending'},
    {SortMoviesBy.revenueAsc: 'Revenue Ascending'},
    {SortMoviesBy.revenueDesc: 'Revenue Descending'},
  ];

  @override
  void initState() {
    super.initState();
    getGenres();
  }

  Future<void> getGenres() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    Map watchlistResults = await tmdbWithCustLogs.v3.genres.getMovieList();

    setState(() {
      genresList = List<GenreButtonModel>.from(
        watchlistResults['genres'].map(
          (genre) => GenreButtonModel(
            id: genre['id'].toString(),
            name: genre['name'],
          ),
        ),
      );
    });
  }

  void applyFilters() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdb = TMDB(ApiKeys(apiKey, readAccToken));

    print('vg ' + voteAverageRange.start.toString());
    var genres = selectedGenres.join(',');
    var response = await tmdb.v3.discover.getMovies(
      includeAdult: true,
      sortBy: sortMoviesBy,
      includeVideo: true,
      voteAverageGreaterThan: voteAverageRange.start.toInt(),
      voteAverageLessThan: voteAverageRange.end.toInt(),
      primaryReleaseDateGreaterThan:
          DateTime(releaseYearRange.start.toInt()).toIso8601String(),
      primaryReleaseDateLessThan:
          DateTime(releaseYearRange.end.toInt()).toIso8601String(),
      withGenres: genres,
    );

    setState(() {
      filteredMovies = response['results'].cast<Map<String, dynamic>>();
    });
  }

  void toggleGenre(String genreId) {
    setState(() {
      final genre = genresList.firstWhere((g) => g.id == genreId);
      genre.isSelected = !genre.isSelected;

      if (genre.isSelected) {
        selectedGenres.add(genreId);
      } else {
        selectedGenres.remove(genreId);
      }
    });
  }

  void resetFilters() {
    setState(() {
      selectedGenres.clear();
      voteAverageRange = RangeValues(1.0, 10.0);
      releaseYearRange = RangeValues(
        1900.toDouble(),
        DateTime.now().year.toDouble(),
      );
      filteredMovies.clear();

      for (final genre in genresList) {
        genre.isSelected = false;
      }
    });
  }

  void openFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      title: mod_Text(text: 'Sort By',color: Colors.white,size: 18),
                      trailing: DropdownButton<SortMoviesBy>(
                        dropdownColor: Colors.black,
                        value: sortMoviesBy,
                        onChanged: (SortMoviesBy? value) {
                          setState(() {
                            sortMoviesBy = value!;
                          });
                        },
                        items: sortByOptions.map((Map<SortMoviesBy, String> sortBy) {
                          SortMoviesBy sortByValue = sortBy.keys.first;
                          String displayString = sortBy.values.first;
                          return DropdownMenuItem<SortMoviesBy>(
                            value: sortByValue,
                            child: mod_Text(text: displayString, color: Colors.white, size: 18,),
                          );
                        }).toList(),
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: genresList.map<Widget>((genre) {
                        return GenreButton(
                          genre: genre,
                          onPressed: toggleGenre,
                        );
                      }).toList(),
                    ),
                    ListTile(
                      title: mod_Text(text: 'Vote Average Range', color: Colors.white, size: 18,),
                      subtitle: RangeSlider(
                        values: voteAverageRange,
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        onChanged: (values) {
                          setState(() {
                            voteAverageRange = values;
                          });
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          mod_Text(text: voteAverageRange.start.toStringAsFixed(1), color: Colors.white, size: 18,),
                          SizedBox(width: 8.0),
                          mod_Text(text: '-', color: Colors.white, size: 18,),
                          SizedBox(width: 8.0),
                          mod_Text(text: voteAverageRange.end.toStringAsFixed(1), color: Colors.white, size: 18,),
                        ],
                      ),
                    ),
                    ListTile(
                      title: mod_Text(text: 'Release Year Range', color: Colors.white, size: 18,),
                      subtitle: RangeSlider(
                        values: releaseYearRange,
                        min: 1900.toDouble(),
                        max: DateTime.now().year.toDouble(),
                        onChanged: (values) {
                          setState(() {
                            releaseYearRange = values;
                          });
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          mod_Text(text: releaseYearRange.start.toInt().toString(), color: Colors.white, size: 18,),
                          SizedBox(width: 8.0),
                          mod_Text(text: '-',color: Colors.white, size: 18,),
                          SizedBox(width: 8.0),
                          mod_Text(text: releaseYearRange.end.toInt().toString(), color: Colors.white, size: 18,),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        applyFilters();
                        Navigator.pop(context);
                      },
                      child: mod_Text(text: 'Apply Filters', color: Colors.white, size: 18,),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        resetFilters();
                        Navigator.pop(context);
                      },
                      child: mod_Text(text: 'Reset Filters', color: Colors.white, size: 18,),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    int columnCount = 2;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        Center(
          child: ElevatedButton(
            onPressed: openFilterMenu,
            child: Text('Open Filter Menu'),
          ),
        ),
        SizedBox(height: 16.0),
        filteredMovies.isNotEmpty
            ? Expanded(
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
                        filteredMovies.length,
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
                                        builder: (context) =>

                                                DescriptionMovies(
                                                    movieID:
                                                        filteredMovies[index]
                                                            ['id'],
                                                    isMovie: true,
                                                  )

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
                                              image: filteredMovies[index]
                                                          ['poster_path'] !=
                                                      null
                                                  ? NetworkImage(
                                                      'https://image.tmdb.org/t/p/w200' +
                                                          filteredMovies[index]
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
                                                        .parseDouble(
                                                            filteredMovies[
                                                                    index][
                                                                'vote_average'])),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  filteredMovies[index][
                                                              'vote_average'] !=
                                                          null
                                                      ? filteredMovies[index]
                                                              ['vote_average']
                                                          .toStringAsFixed(1)
                                                      : '0',
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
                                        Flexible(
                                          child: Column(children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              child: Expanded(
                                                child: mod_Text(
                                                  text: filteredMovies[index]
                                                          ['title'] ??
                                                      filteredMovies[index]
                                                          ['name'],
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
                                                      '(${filteredMovies[index]['release_date'] ?? filteredMovies[index]['first_air_date']})',
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
              )
            : SizedBox.shrink(),
      ]),
    );
  }
}

class GenreButton extends StatefulWidget {
  final GenreButtonModel genre;
  final Function(String) onPressed;

  GenreButton({
    required this.genre,
    required this.onPressed,
  });

  @override
  _GenreButtonState createState() => _GenreButtonState();
}

class _GenreButtonState extends State<GenreButton> {
  Color getButtonColor() {
    return widget.genre.isSelected ? Colors.blue : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        widget.onPressed(widget.genre.id);
      },
      style: ElevatedButton.styleFrom(
        primary: getButtonColor(),
      ),
      child: Text(widget.genre.name),
    );
  }
}
