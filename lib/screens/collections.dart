import 'package:couch_cinema/screens/all_list_items.dart';
import 'package:couch_cinema/screens/all_lists.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/SessionManager.dart';

class CollectionScreen extends StatefulWidget {
  final Map collections;
  final String title;
  final Color buttonColor;
  final int? listID;
  final int? accountID;
  final String? sessionID;

  const CollectionScreen({
    Key? key,
    required this.collections,
    required this.title,
    required this.buttonColor,
    this.listID,
    this.accountID,
    this.sessionID,
  }) : super(key: key);

  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Center(
            child: mod_Text(text: widget.title, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Center(child: SizedBox(
              height: 270,
              child: FutureBuilder<double>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerPlaceholder();
                  } else if (snapshot.hasError) {
                    return _buildErrorContainer();
                  } else {
                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AllMoviesScreen(
                                      title: widget.collections['name'],
                                      appBarColor: widget.buttonColor,
                                      typeOfApiCall: 11, collectionID: widget.collections['id'],),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          children: [
                            widget.collections['poster_path'] != null ?
                            Flexible(
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500' +
                                          widget.collections['poster_path'],
                                    ),
                                  ),
                                ),
                              ),
                            ) : _buildShimmerPlaceholder(),
                            mod_Text(
                              text: widget.collections['name'] ?? 'Loading',
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              )
          ),
          )

        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: widget.buttonColor,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: 140,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
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
