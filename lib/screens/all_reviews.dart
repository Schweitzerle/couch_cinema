import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/SessionManager.dart';
import '../utils/text.dart';

class AllReviewsScreen extends StatefulWidget {
  final int movieID;
  final bool isMovie;

  AllReviewsScreen({required this.movieID, required this.isMovie});

  @override
  _AllReviewsScreenState createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  int currentPage = 1;
  bool isLoadingMore = false;
  List<dynamic> allReviews = [];

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
      allReviews.addAll(initialMovies);
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
        allReviews.addAll(nextMovies);
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

    Map<dynamic, dynamic> reviewResults = {};

    if (widget.isMovie) {
      reviewResults = await tmdbWithCustLogs.v3.movies.getReviews(
        widget.movieID,
        page: page,
      );
    } else {
      reviewResults = await tmdbWithCustLogs.v3.tv.getReviews(
        widget.movieID,
        page: page,
      );
    }

    List<dynamic> reviews = reviewResults['results'];
    print('Number of reviews: ${reviews.length}');
    return reviews;
  }

  Widget buildReviewItem(dynamic review) {
    final backgroundColor =
    allReviews.indexOf(review) % 2 == 0 ? Color(0xff690257) : Color(0xff540126);

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 240,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: CachedNetworkImage(
                        imageUrl: review['author_details']['avatar_path'] != null
                            ? 'https://image.tmdb.org/t/p/w500${review['author_details']['avatar_path']}'
                            : 'Failed Path',
                        imageBuilder: (context, imageProvider) => Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mod_Text(
                            text: review['author_details']['username'] ?? 'Loading',
                            color: Colors.black,
                            size: 16,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(CupertinoIcons.film_fill, color: Color(0xffd6069b), size: 16),
                              SizedBox(width: 4),
                              mod_Text(
                                text: review['author_details']['rating'] != null
                                    ? review['author_details']['rating'].toString()
                                    : 'Loading',
                                color: Colors.black,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Flexible(
                  flex: 4,
                  child: mod_Text(
                    text: review['content'],
                    color: Colors.black,
                    size: 14,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    mod_Text(
                      text: review['created_at'],
                      color: Colors.grey,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // Added SizedBox
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Reviews'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: allReviews.length + 1,
        itemBuilder: (context, index) {
          if (index < allReviews.length) {
            return buildReviewItem(allReviews[index]);
          } else {
            return _buildLoadingIndicator();
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
