import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FiltersScreen extends StatefulWidget {
  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  List<dynamic> moviesAndSeries = [];
  String selectedType = 'movie';

  Future<void> searchMoviesAndSeries(String type) async {
    final apiKey = '24b3f99aa424f62e2dd5452b83ad2e43'; // Replace with your own TMDb API key
    final url = Uri.parse(
        'https://api.themoviedb.org/3/discover/$type?api_key=$apiKey');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    setState(() {
      moviesAndSeries = data['results'];
    });
  }

  void showFiltersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select type:'),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
                items: <String>[
                  'movie',
                  'tv',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                searchMoviesAndSeries(selectedType);
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Filters'),
        backgroundColor: Color(0xff480178),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showFiltersDialog();
            },
            child: Text('Filters'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: moviesAndSeries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    moviesAndSeries[index]['title'] ??
                        moviesAndSeries[index]['name'],
                  ),
                  subtitle: Text(
                    moviesAndSeries[index]['release_date'] ??
                        moviesAndSeries[index]['first_air_date'],
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
