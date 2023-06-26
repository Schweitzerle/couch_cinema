import 'package:flutter/material.dart';

class GenreList extends StatelessWidget {
  final List<String> genres;
  final Color color;

  GenreList({required this.genres, required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: genres.map((genre) {
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Text(
            genre,
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
    );
  }
}
