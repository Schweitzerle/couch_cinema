import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

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

  List<Map<String, dynamic>> filteredMovies = [];

  List<GenreButtonModel> genresList = [];

  String selectedSortBy = SortMoviesBy.popularityDesc.toString();


  List<String> sortByOptions = [
    SortMoviesBy.popularityDesc.toString(),
    SortMoviesBy.releaseDateDesc.toString(),
    SortMoviesBy.voteAverageDesc.toString(),
    SortMoviesBy.voteCountDesc.toString(),
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
    final String apiKey = 'YOUR_API_KEY';
    final readAccToken = 'YOUR_READ_ACCESS_TOKEN';

    TMDB tmdb = TMDB(ApiKeys(apiKey, readAccToken));

    var genres = selectedGenres.join(',');
    var response = await tmdb.v3.discover.getMovies(
      sortBy: SortMoviesBy.popularityAsc,
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                DropdownButton<String>(
                  value: selectedSortBy,
                  onChanged: (value) {
                    setState(() {
                      selectedSortBy = value!;
                    });
                  },
                  items: sortByOptions.map((String sortBy) {
                    return DropdownMenuItem<String>(
                      value: sortBy,
                      child: Text(sortBy),
                    );
                  }).toList(),
                ),

                  ListTile(
                      title: Text('Genres'),
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
                      title: Text('Vote Average Range'),
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
                          Text(voteAverageRange.start.toStringAsFixed(1)),
                          SizedBox(width: 8.0),
                          Text('-'),
                          SizedBox(width: 8.0),
                          Text(voteAverageRange.end.toStringAsFixed(1)),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text('Release Year Range'),
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
                          Text(releaseYearRange.start.toInt().toString()),
                          SizedBox(width: 8.0),
                          Text('-'),
                          SizedBox(width: 8.0),
                          Text(releaseYearRange.end.toInt().toString()),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        applyFilters();
                        Navigator.pop(context);
                      },
                      child: Text('Apply Filters'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        resetFilters();
                        Navigator.pop(context);
                      },
                      child: Text('Reset Filters'),
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
    return Scaffold(
      body: Column(children: [
        SizedBox(height: 16.0),
        filteredMovies.isNotEmpty
            ? Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredMovies.length,
            itemBuilder: (context, index) {
              var movie = filteredMovies[index];
              return ListTile(
                title: Text(movie['title']),
                subtitle: Text(movie['overview']),
              );
            },
          ),
        )
            : SizedBox.shrink(),
        Center(
          child: ElevatedButton(
            onPressed: openFilterMenu,
            child: Text('Open Filter Menu'),
          ),
        ),
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


