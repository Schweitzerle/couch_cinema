import 'dart:convert';

import 'package:tmdb_api/tmdb_api.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';


class User {
  late int accountId;
  late String sessionId;
  List<User> followingUsers;
  String imagePath;
  String name;
  String username;
  bool isSelected;

  User({
    required this.accountId,
    required this.sessionId,
    List<User>? followingUsers,
    this.imagePath = '',
    this.name = '',
    this.username = '',
    this.isSelected = false,
  }): followingUsers = followingUsers ?? [];


  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'sessionId': sessionId,
      'followingUsers': followingUsers.map((user) => user.toMap()).toList(),
      'isFollowing': isSelected,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      accountId: map['accountId'],
      sessionId: map['sessionId'],
      followingUsers: List<User>.from(map['followingUsers']?.map((user) => User.fromMap(user))),
      imagePath: map['imagePath'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      isSelected: map['isFollowing'] ?? false,

    );
  }



  Future<void> loadUserData() async {
    final String apiKey = '24b3f99aa424f62e2dd5452b83ad2e43';

    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/account/$accountId?api_key=$apiKey&session_id=$sessionId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Access the avatar path from the response data
      final namePath = data["name"];
      final userNamePath = data["username"];
      final avatarPath = data['avatar']['tmdb']['avatar_path'];

      // Construct the full URL for the avatar image
      final imageUrl = 'https://image.tmdb.org/t/p/w500$avatarPath';

      // Use the imageUrl as needed (e.g., display the image in a Flutter app)
      imagePath = imageUrl;
      username = userNamePath;
      name = namePath;
    } else {
      print('Error: ${sessionId}');
    }
  }
}
