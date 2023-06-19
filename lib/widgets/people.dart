import 'package:cached_network_image/cached_network_image.dart';
import 'package:couch_cinema/peopleDetail.dart';
import 'package:couch_cinema/screens/all_movies.dart';
import 'package:couch_cinema/screens/all_people.dart';
import 'package:couch_cinema/utils/text.dart';
import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../movieDetail.dart';

class PeopleScreen extends StatelessWidget {
  final List people;
  final List allPeople;
  final String title;
  final Color buttonColor;

  const PeopleScreen(
      {Key? key,
      required this.people,
      required this.allPeople,
      required this.title,
      required this.buttonColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              mod_Text(text: title, color: Colors.white, size: 22),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllPeopleScreen(
                        people: allPeople,
                        title: title,
                        appBarColor: buttonColor,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: buttonColor, // Set custom background color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Set custom corner radius
                  ),
                ),
                child: Text('All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: people.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DescriptionPeople(
                                peopleID: people[index]['id'],
                                isMovie: true,
                              )),
                    );
                  },
                  child: SizedBox(
                    width: 140,
                    child: Column(
                      children: [
                        Flexible(
                          child: Container(
                            height: 200,
                            child: CachedNetworkImage(
                              imageUrl: people[index]['profile_path'] != null ? 'https://image.tmdb.org/t/p/w500' +
                                  people[index]['profile_path'] : 'Failed Path',
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: imageProvider,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                        mod_Text(
                          text: people[index]['name'] != null
                              ? people[index]['name']
                              : 'Loading',
                          color: Colors.white,
                          size: 14,
                        ),
                        mod_Text(
                          text: people[index]['known_for_department'] != null
                              ? people[index]['known_for_department']
                              : 'Loading',
                          color: Colors.white,
                          size: 14,
                        ),
                        mod_Text(
                          text: people[index]['character'] != null
                              ? '(' + people[index]['character'] + ')'
                              : people[index]['job'],
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
