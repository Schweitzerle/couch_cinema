import 'dart:convert';
import 'dart:ui';
import 'package:couch_cinema/Database/firebase_database_instance.dart';
import 'package:couch_cinema/screens/FluidTabBarScreen.dart';
import 'package:couch_cinema/screens/splash_screen.dart';
import 'package:couch_cinema/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmdb_api/tmdb_api.dart';

import 'Database/user.dart';
import 'api/tmdb_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';



Future<void> main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: 'CouchCinema',
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = FirebaseDatabase.instance.ref();

  bool _isLoggedIn = false;
  late String _sessionId;
  late int _accountId;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final Future<String?> sessionID = SessionManager.getSessionId();
  final Future<int?> accountID = SessionManager.getAccountId();
  String name = '';
  String imagePath = '';
  String username = '';
  final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';
  final readAccToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNGIzZjk5YWE0MjRmNjJlMmRkNTQ1MmI4M2FkMmU0MyIsInN1YiI6IjYzNjI3NmU5YTZhNGMxMDA4MmRhN2JiOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fiB3ZZLqxCWYrIvehaJyw6c4LzzOFwlqoLh8Dw77SUw';

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
    loadData();
  }

  void loadData() async {
    int? accountId = await accountID;
    String? sessionId = await sessionID;

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
    }
  }

  void checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');
    if (sessionId != null) {
      setState(() {
        _isLoggedIn = true;
        _sessionId = sessionId;
      });
      _accountId = (await TMDBApiService.getAccountId(sessionId))!;
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoggedIn
          ? FluidPage(sessionId: _sessionId)
          : _buildLoginScreen(size),
    );
  }


  Widget _buildLoginScreen(Size size) {
    //final userRef = database.child('users');
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              SizedBox(
                height: size.height,
                child: Image.asset(
                  'assets/images/cinema.jpg',
                  fit: BoxFit.fitHeight,
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaY: 25, sigmaX: 25),
                          child: SizedBox(
                            width: size.width * .9,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: size.width * .15,
                                    bottom: size.width * .1,
                                  ),
                                  child: Text(
                                    'SIGN IN',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(.8),
                                    ),
                                  ),
                                ),
                                component(
                                  Icons.account_circle_outlined,
                                  'User name...',
                                  false,
                                  false,
                                  _usernameController,
                                ),
                                component(
                                  Icons.lock_outline,
                                  'Password...',
                                  true,
                                  false,
                                  _passwordController,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // Forgotten password
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Fluttertoast.showToast(
                                          msg:
                                              'Forgotten password! button pressed',
                                        );
                                      },
                                      child: Text(
                                        'Forgotten password!',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // Create new account
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Fluttertoast.showToast(
                                          msg:
                                              'Create a new Account button pressed',
                                        );
                                      },
                                      child: Text(
                                        'Create a new Account',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.width * .3),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    String? sessionId =
                                        await TMDBApiService.login(
                                      _usernameController.text,
                                      _passwordController.text,
                                    );
                                    if (sessionId != null) {
                                      setState(() {
                                        _isLoggedIn = true;
                                        _sessionId = sessionId;
                                      });
                                      _accountId =
                                          (await TMDBApiService.getAccountId(
                                              sessionId))!;
                                      try {
                                        final userSnapshot = await database.child('users').orderByChild('accountId').equalTo(_accountId).once();

                                        if (userSnapshot.snapshot.exists) {
                                          print('User already exists');
                                        } else {
                                          TMDB tmdbWithCustLogs = TMDB(ApiKeys(apiKey, readAccToken),
                                              logConfig: ConfigLogger(showLogs: true, showErrorLogs: true));
                                          tmdbWithCustLogs.v3.lists.createList(sessionId, 'CouchCinema Recommended Series', 'Recommended Series for followed users');
                                          tmdbWithCustLogs.v3.lists.createList(sessionId, 'CouchCinema Recommended Movies', 'Recommended Movies for followed users');
                                          // Create a new user entry in the database
                                          final newUser = User(accountId: _accountId, sessionId: sessionId);
                                          final newUserRef = database.child('users').child(_accountId.toString());
                                          await newUserRef.set(newUser.toMap());
                                          print('New user created successfully');
                                        }
                                      } catch (error) {
                                        print('Error storing data: $error');
                                      }
                                      saveSessionId(sessionId, _accountId);

                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      bottom: size.width * .05,
                                    ),
                                    height: size.width / 8,
                                    width: size.width / 1.25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Color(0xff540126).withOpacity(1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Sign-In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }







  Widget component(IconData icon, String hintText, bool isPassword,
      bool isEmail, TextEditingController controller) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.width / 8,
      width: size.width / 1.25,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: size.width / 30),
      decoration: BoxDecoration(
        color: Color(0xff540126).withOpacity(1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Colors.white.withOpacity(.9),
        ),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(.8),
          ),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(.5),
          ),
        ),
      ),
    );
  }

  void saveSessionId(String sessionId, int accountId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sessionId', sessionId);
    prefs.setInt('accountId', accountId);
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
