import 'package:couch_cinema/screens/all_list_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/SessionManager.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class AllListsScreen extends StatefulWidget {
  final List movies;
  final String title;
  final Color appBarColor;
  final int? movieID;
  final int? accountID;
  final String? sessionID;

  AllListsScreen({
    Key? key,
    required this.movies,
    required this.title,
    required this.appBarColor,
    this.movieID,
    this.accountID,
    this.sessionID,
  }) : super(key: key);

  /*
  0:Similar
  1:Recommended
  2:Trending
  3:Popular
  4:TopRated
  5:Upcoming
  6:Now
  7:Watchlist
  8:PeopleContribution
   */

  @override
  _AllListsState createState() => _AllListsState();
}

class _AllListsState extends State<AllListsScreen> {
  int currentPage = 1;
  bool isLoadingMore = false;
  List<dynamic> allLists = [];

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
      allLists.addAll(initialMovies);
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
        allLists.addAll(nextMovies);
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

    Map<dynamic, dynamic> watchlistResults = {};

    watchlistResults = await tmdbWithCustLogs.v3.movies.getLists(
      widget.movieID!,
      page: page,
    );

    List<dynamic> watchlistSeries = watchlistResults['results'];

    return watchlistSeries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          GridView.builder(
            controller: _scrollController,
            itemCount: allLists.length + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (BuildContext context, int index) {
              if (index == allLists.length) {
                if (isLoadingMore) {
                  return Container();
                } else {
                  return SizedBox();
                }
              }

              final list = allLists[index];
              double voteAverage =
                  double.parse(list['favorite_count'].toString());
              int movieId = list['id'];

              return FutureBuilder<double>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerPlaceholder();
                  } else if (snapshot.hasError) {
                    return _buildErrorContainer();
                  } else {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllListsItemsScreen(
                                    title: widget.title,
                                    appBarColor: widget.appBarColor,
                                    listID: movieId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        children: [
                                          list['poster_path'] != null ?
                                          Image.network(
                                            'https://image.tmdb.org/t/p/w300${list['poster_path']}',
                                            fit: BoxFit.cover,
                                          ): _buildShimmerPlaceholder(),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: PopularSeries
                                                    .getCircleColor(
                                                  PopularSeries.parseDouble(
                                                      voteAverage),
                                                ),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      voteAverage
                                                          .toStringAsFixed(1),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    list['name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          if (isLoadingMore)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: widget.appBarColor,
      highlightColor: Colors.grey[600]!,
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 250,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.error,
          color: Colors.white,
        ),
      ),
    );
  }
}
