
import 'package:couch_cinema/peopleDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../movieDetail.dart';
import '../utils/SessionManager.dart';
import '../utils/text.dart';
import '../widgets/popular_series.dart';

class AllPeopleScreen extends StatefulWidget {
  final List people;
  final String title;
  final Color appBarColor;

  AllPeopleScreen({super.key, required this.people, required this.title, required this.appBarColor});

  @override
  _AllPeopleState createState() => _AllPeopleState();
}

class _AllPeopleState extends State<AllPeopleScreen> {




  @override
  Widget build(BuildContext context) {
    print(widget.people.toString());
    double _w = MediaQuery.of(context).size.width;
    int columnCount = 2;
    double initRating = 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.title,
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
              widget.people.length,
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
                        onLongPress: () {
                          /*getUserMovieRating(widget.movies[index]['id']);
                          print('Rat: '+initRating.toString());
                          MovieDialogHelper.showMovieRatingDialog(context, initRating, rating, widget.movies[index]['id']);
                        */},
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DescriptionPeople(peopleID: widget.people[index]['id'], isMovie: true)
                            ),
                          );
                        },
                        child: widget.people[index]['profile_path'] != null
                            ?
                            Column(
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          'https://image.tmdb.org/t/p/w500' +
                                              widget.people[index]['profile_path'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                mod_Text(
                                  text: widget.people[index]['name'] != null
                                      ? widget.people[index]['name']
                                      : 'Loading',
                                  color: Colors.white,
                                  size: 14,
                                ),
                                mod_Text(
                                  text: widget.people[index]['known_for_department'] != null
                                      ? widget.people[index]['known_for_department']
                                      : 'Loading',
                                  color: Colors.white,
                                  size: 14,
                                ),
                                mod_Text(
                                  text: widget.people[index]['character'] != null
                                      ? '(' + widget.people[index]['character'] + ')'
                                      : widget.people[index]['job'] != null ?  widget.people[index]['job'] : '',
                                  color: Colors.white,
                                  size: 14,
                                ),

                              ],
                            )
                            :Container(),
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

