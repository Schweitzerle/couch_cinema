import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendedScreen extends StatefulWidget {
  @override
  _RecommendedScreenState createState() => _RecommendedScreenState();
}

class _RecommendedScreenState extends State<RecommendedScreen> {
  List<dynamic> recommendedMovies = [];
  List<dynamic> recommendedSeries = [];
  List<dynamic> ratedMovies = [];
  List<dynamic> ratedSeries = [];

  @override
  void initState() {
    super.initState();
    fetchRecommendedData();
    fetchRatedData();
  }

  Future<void> fetchRecommendedData() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=YOUR_API_KEY&language=en-US&page=1'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        recommendedMovies = jsonData['results'];
      });
    } else {
      print('Failed to fetch recommended movies. Error: ${response.statusCode}');
    }

    final seriesResponse = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/tv/popular?api_key=YOUR_API_KEY&language=en-US&page=1'));
    if (seriesResponse.statusCode == 200) {
      final jsonData = json.decode(seriesResponse.body);
      setState(() {
        recommendedSeries = jsonData['results'];
      });
    } else {
      print('Failed to fetch recommended series. Error: ${seriesResponse.statusCode}');
    }
  }

  Future<void> fetchRatedData() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/top_rated?api_key=YOUR_API_KEY&language=en-US&page=1'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        ratedMovies = jsonData['results'].take(10).toList();
      });
    } else {
      print('Failed to fetch rated movies. Error: ${response.statusCode}');
    }

    final seriesResponse = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/tv/top_rated?api_key=YOUR_API_KEY&language=en-US&page=1'));
    if (seriesResponse.statusCode == 200) {
      final jsonData = json.decode(seriesResponse.body);
      setState(() {
        ratedSeries = jsonData['results'].take(10).toList();
      });
    } else {
      print('Failed to fetch rated series. Error: ${seriesResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Recommended & Rated',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recommended',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedMovies.length,
                itemBuilder: (context, index) {
                  final movie = recommendedMovies[index];
                  return MovieCard(
                    title: movie['title'],
                    releaseYear: movie['release_date'] != null ? movie['release_date'].substring(0, 4) : '',
                    averageRating: movie['vote_average'] != null ? movie['vote_average'].toString() : '',
                    imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedSeries.length,
                itemBuilder: (context, index) {
                  final series = recommendedSeries[index];
                  return MovieCard(
                    title: series['name'],
                    releaseYear: series['first_air_date'] != null ? series['first_air_date'].substring(0, 4) : '',
                    averageRating: series['vote_average'] != null ? series['vote_average'].toString() : '',
                    imageUrl: 'https://image.tmdb.org/t/p/w500${series['poster_path']}',
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Last Rated',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ratedMovies.length,
                itemBuilder: (context, index) {
                  final movie = ratedMovies[index];
                  return MovieCard(
                    title: movie['title'],
                    releaseYear: movie['release_date'] != null ? movie['release_date'].substring(0, 4) : '',
                    averageRating: movie['vote_average'] != null ? movie['vote_average'].toString() : '',
                    imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ratedSeries.length,
                itemBuilder: (context, index) {
                  final series = ratedSeries[index];
                  return MovieCard(
                    title: series['name'],
                    releaseYear: series['first_air_date'] != null ? series['first_air_date'].substring(0, 4) : '',
                    averageRating: series['vote_average'] != null ? series['vote_average'].toString() : '',
                    imageUrl: 'https://image.tmdb.org/t/p/w500${series['poster_path']}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final String title;
  final String releaseYear;
  final String averageRating;
  final String imageUrl;

  const MovieCard({
    required this.title,
    required this.releaseYear,
    required this.averageRating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            '($releaseYear)',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          SizedBox(height: 4),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getRatingColor(),
            ),
            child: Center(
              child: Text(
                averageRating,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getRatingColor() {
    final rating = double.tryParse(averageRating);
    if (rating != null) {
      if (rating >= 8.0) {
        return Colors.green;
      } else if (rating >= 6.0) {
        return Colors.yellow;
      } else {
        return Colors.red;
      }
    }
    return Colors.grey;
  }
}
