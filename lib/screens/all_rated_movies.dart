import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class AllRatedMovieScreen extends StatefulWidget {
  final List ratedMovies;
  final Color appBarColor;
  final int? accountID;
  final String? sessionID;

  const AllRatedMovieScreen({Key? key, required this.ratedMovies, required this.appBarColor, this.accountID, this.sessionID});


  @override
  _AllRatedMoviesState createState() => _AllRatedMoviesState();
}

class _AllRatedMoviesState extends State<AllRatedMovieScreen> {
  int currentPage = 1;
  int itemsPerPage = 10;
  bool isLoadingMore = false;
  List<dynamic> allMovies = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMovies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!isLoadingMore && _scrollController.position.atEdge) {
      final isBottom = _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      if (isBottom) {
        _loadMoreMovies();
      }
    }
  }

  void _loadMovies() async {
    final List<dynamic> initialMovies = await _fetchMoviesPage(currentPage);
    setState(() {
      allMovies.addAll(initialMovies);
    });
  }

  void _loadMoreMovies() async {
    if (!isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final nextPage = currentPage + 1;
      final List<dynamic> nextMovies = await _fetchMoviesPage(nextPage);

      setState(() {
        allMovies.addAll(nextMovies);
        currentPage = nextPage;
        isLoadingMore = false;
      });
    }
  }

  Future<List<dynamic>> _fetchMoviesPage(int page) async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
    final readAccToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

    TMDB tmdbWithCustLogs = TMDB(
      ApiKeys(apiKey, readAccToken),
      logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
    );

    Map<dynamic, dynamic> watchlistResults = await tmdbWithCustLogs.v3.account
        .getRatedMovies(
      widget.sessionID!,
      widget.accountID!,
      page: page,
    );

    List<dynamic> watchlistSeries = watchlistResults['results'];

    return watchlistSeries;
  }


  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    int columnCount = 2;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Rated Movies",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GridView.builder(
        controller: _scrollController,
        physics: ScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(_w / 60),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          childAspectRatio: 2 / 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: allMovies.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == allMovies.length) {
            // Show a loading indicator at the end
            return Visibility(
              visible: isLoadingMore,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 140,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                ),
              ),
            );
          } else {
            final movie = allMovies[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: Duration(milliseconds: 500),
              columnCount: columnCount,
              child: ScaleAnimation(
                duration: Duration(milliseconds: 900),
                curve: Curves.fastLinearToSlowEaseIn,
                child: FadeInAnimation(
                  child: InkWell(
                    onLongPress: () {},
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DescriptionMovies(
                            movieID: allMovies[index]['id'],
                            // Modify this line
                            isMovie: true,
                          ),
                        ),
                      );
                    },
                    child: allMovies[index]['poster_path'] != null
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://image.tmdb.org/t/p/w500' +
                                    allMovies[index][
                                    'poster_path'], // Modify this line
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
                                color: PopularSeries.getCircleColor(
                                  PopularSeries.parseDouble(
                                    allMovies[index][
                                    'rating'], // Modify this line
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  allMovies[index]['rating']
                                      .toStringAsFixed(
                                      1), // Modify this line
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
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: Expanded(
                            child: mod_Text(
                              text: allMovies[index]['original_title'] !=
                                  null
                                  ? allMovies[index][
                              'original_title'] // Modify this line
                                  : 'Loading',
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                        : Container(),
                  ),
                ),
              ),
            );
          }
        },
      ),

    );
  }

}
