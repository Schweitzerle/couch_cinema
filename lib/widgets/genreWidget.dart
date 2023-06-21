import 'package:flutter/material.dart';

class GenreList extends StatelessWidget {
  final List<String> genres;

  GenreList({required this.genres});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: genres.map((genre) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xff540126),
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
