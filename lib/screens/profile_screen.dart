import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmdb_api/tmdb_api.dart';

import '../Database/user.dart';
import '../main.dart';
import '../utils/SessionManager.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final Future<String?> sessionID = SessionManager.getSessionId();
  final Future<int?> accountID = SessionManager.getAccountId();
  String name = '';
  String imagePath = '';
  String username = '';
  int moviesRanked = 0;
  int friendsCount = 0;
  List rankedMovies = [];
  List rankedSeries = [];
  List<User> following = [];
  int minutesMoviesWatched = 0;
  String? sessionId;
  int? accountId;
  int addedRuntimeMovies = 0;
  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

  late Future<void> _searchUsersFuture;

  @override
  initState() {
    super.initState();
    _searchUsersFuture = _searchUsers();
    loadData();
    setIDs();
  }

  Future<void> getMoviesRuntime() async {
    int totalRuntime = 0;
    print(rankedMovies.length);
    print(rankedMovies.toString());
    for (int i = 0; i < rankedMovies.length; i++) {
      int runtime = rankedMovies[i]['runtime'] ??0;
      print(runtime.toString());
      totalRuntime += runtime;
    }

    setState(() {
      addedRuntimeMovies = totalRuntime;
    });
  }



  Future<void> _searchUsers() async {
    int? _accountId = await accountID;
    following.clear();
    final ref = FirebaseDatabase.instance
        .ref("users")
        .child(_accountId.toString())
        .child('following');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (final value in data.values) {
        final accountId = value['accountId'] as int;
        final sessionId = value['sessionId'] as String;
        final user = User(accountId: accountId, sessionId: sessionId);
        await user.loadUserData();
        setState(() {
          following.add(user);
        });
      }
    } else {
      print('No data available.');
    }
  }

  void loadData() async {
    int? accountId = await accountID;
    String? sessionId = await sessionID;
    TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));

    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/account/$accountId?api_key=$apiKey&session_id=$sessionId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Access the avatar path from the response data
      final namePath = data["name"];
      final userNamePath = data["username"];
      final avatarPath = data['avatar']['tmdb']['avatar_path'];

      // Construct the full URL for the avatar image
      final imageUrl = 'https://image.tmdb.org/t/p/w500$avatarPath';

      // Use the imageUrl as needed (e.g., display the image in a Flutter app)


      setState(() {
        imagePath = imageUrl;
        username = userNamePath;
        name = namePath;
      });

    } else {
      print('Error: ${sessionId}');
    }

    // Fetch all rated movies from all pages
    List<dynamic> allRatedMovies = [];
    int ratedMoviesPage = 1;
    bool hasMoreRatedMoviesPages = true;

    while (hasMoreRatedMoviesPages) {
      Map<dynamic, dynamic> ratedMoviesResults =
          await tmdbWithCustLogs.v3.account.getRatedMovies(
        sessionId!,
        accountId!,
        page: ratedMoviesPage,
      );
      List<dynamic> ratedMovies = ratedMoviesResults['results'];

      allRatedMovies.addAll(ratedMovies);

      if (ratedMoviesPage == ratedMoviesResults['total_pages'] ||
          ratedMovies.isEmpty) {
        hasMoreRatedMoviesPages = false;
      } else {
        ratedMoviesPage++;
      }
    }

    // Fetch all rated TV shows from all pages
    List<dynamic> allRatedSeries = [];
    int ratedSeriesPage = 1;
    bool hasMoreRatedSeriesPages = true;

    while (hasMoreRatedSeriesPages) {
      Map<dynamic, dynamic> ratedSeriesResults =
          await tmdbWithCustLogs.v3.account.getRatedTvShows(
        sessionId!,
        accountId!,
        page: ratedSeriesPage,
      );
      List<dynamic> ratedSeries = ratedSeriesResults['results'];

      allRatedSeries.addAll(ratedSeries);

      if (ratedSeriesPage == ratedSeriesResults['total_pages'] ||
          ratedSeries.isEmpty) {
        hasMoreRatedSeriesPages = false;
      } else {
        ratedSeriesPage++;
      }
    }



    setState(() {
    rankedMovies = allRatedMovies;
      rankedSeries = allRatedSeries;
    });

    getMoviesRuntime();
  }


  Future<void> setIDs() async {
    accountId = await accountID;
    sessionId = await sessionID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Color(0xff270140),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 5),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  logout(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff270140), // Set custom color here
                ),
                child: Text('Logout'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(imagePath),
                  ),
                  SizedBox(height: 40.0),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Text(
                    accountId.toString(),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 70.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileStat(
                          'Movies Ranked', rankedMovies.length.toString()),
                      _buildProfileStat(
                          'Series Ranked', rankedSeries.length.toString()),
                      _buildProfileStat('Followers', following.length.toString()),
                    ],
                  ),
                  SizedBox(height: 5,),
                  _buildProfileStat(
                    'Movie Time Watched',
                    '${addedRuntimeMovies.toString()} minutes',
                  ),
                  SizedBox(height: 20.0,),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserSearchDialog(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff270140), // Set custom background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Set custom corner radius
                      ),
                    ),
                    child: Text('Following'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('sessionId');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => MyHomePage()),
      (route) => false,
    );
  }
}


class UserSearchDialog extends StatefulWidget {
  @override
  _UserSearchDialogState createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final Future<String?> sessionID = SessionManager.getSessionId();
  final Future<int?> accountID = SessionManager.getAccountId();
  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

  List<User> users = [];
  bool isPressed2 = true;
  bool isHighlighted = false;
  int? accountId = 0;

  final database = FirebaseDatabase.instance.ref().child('users');

  @override
  void initState()  {
    super.initState();
    setAccId();
  }

  Future<void> setAccId() async {
    accountId = await accountID;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 180),
      shadowColor: Color(0xff690257),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Color(0xFF1f1f1f),
      content: Scaffold(
        backgroundColor: Colors.grey[900], // Schwarzer Hintergrund
        body: Column(
          children: [
            SizedBox(
              child: TextField(
                onChanged: (value) {
                  _searchUsers(context, value);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Suche nach UserID',
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
                  itemCount: users.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    //_searchFollowers(context, accountId.toString(), user.accountId.toString());
                    return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: Duration(milliseconds: 500),
                        columnCount: 2,
                        child: ScaleAnimation(
                          duration: Duration(milliseconds: 900),
                          curve: Curves.fastLinearToSlowEaseIn,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {},
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      height: 200,
                                      width: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          user.imagePath,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Text(
                                              user.username,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            InkWell(
                                              highlightColor:
                                              Colors.transparent,
                                              splashColor:
                                              Colors.transparent,
                                              onHighlightChanged: (value) {
                                                setState(() {
                                                  isHighlighted =
                                                  !isHighlighted;
                                                });
                                              },
                                              onTap: () {
                                                isPressed2 = !isPressed2;
                                                setState(() async {
                                                  // Create a new user entry in the database
                                                  final newUser = User(
                                                      accountId: user.accountId,
                                                      sessionId: user
                                                          .sessionId);
                                                  final newUserRef = database
                                                      .child(
                                                      accountId.toString())
                                                      .child('following')
                                                      .child(user.accountId
                                                      .toString());
                                                  await newUserRef.set(newUser
                                                      .toMap());
                                                });
                                              },
                                              child: AnimatedContainer(
                                                margin: EdgeInsets.all(
                                                    isHighlighted
                                                        ? 0
                                                        : 2.5),
                                                height:
                                                isHighlighted ? 50 : 45,
                                                width:
                                                isHighlighted ? 50 : 45,
                                                curve: Curves
                                                    .fastLinearToSlowEaseIn,
                                                duration: Duration(
                                                    milliseconds: 300),
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 20,
                                                      offset: Offset(5, 10),
                                                    ),
                                                  ],
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: isPressed2
                                                    ? Icon(
                                                  Icons
                                                      .favorite_border,
                                                  color: Colors.black
                                                      .withOpacity(
                                                      0.6),
                                                )
                                                    : Icon(
                                                  Icons.favorite,
                                                  color: Colors.pink
                                                      .withOpacity(
                                                      1.0),
                                                ),
                                              ),
                                            ),
                                          ])
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }


  Future<void> _searchFollowers(BuildContext context, String accId,
      String query) async {
    users.clear();
    final ref = FirebaseDatabase.instance.ref("users").child(accId).child(
        'following');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) async {
        final accountId = value['accountId'] as int;
        final sessionId = value['sessionId'] as String;

        if (accountId.toString() == query) {
          setState(() {
            isPressed2 = true;
          });
        }
        setState(() {
          isPressed2 = false;
        });
      });
    }
  }

    Future<void> _searchUsers(BuildContext context, String query) async {
      users.clear();
      final ref = FirebaseDatabase.instance.ref("users");
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) async {
          final accountId = value['accountId'] as int;
          final sessionId = value['sessionId'] as String;

          if (accountId.toString().contains(query)) {
            final user = User(accountId: accountId, sessionId: sessionId);
            await user.loadUserData();
            setState(() {
              users.add(user);
            });
          }
        });

        if (users.isNotEmpty) {
          print('Users found');
        } else {
          print('No users found with the specified query.');
        }
      } else {
        print('No data available.');
      }
    }
  }

