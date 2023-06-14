import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';

class FirebaseInstance {
  static late FirebaseDatabase _database;

  static FirebaseDatabase get database => _database;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyCqgKnwzH8FuuQCmw8oFPwkl_bREO1GRDc',
        projectId: 'couchcinema-b03e3',
        databaseURL: 'https://couchcinema-b03e3-default-rtdb.europe-west1.firebasedatabase.app/',
        messagingSenderId: '',
        appId: '1:419028926058:android:808d4d2d74826708985413',
      ),
    );
    _database = FirebaseDatabase.instance;
  }
}
