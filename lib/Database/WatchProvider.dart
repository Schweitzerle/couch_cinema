class WatchProvider {
  final String country;
  final String link;
  final List<Map<String, dynamic>> flatrate;
  final List<Map<String, dynamic>> rent;
  final List<Map<String, dynamic>> buy;

  WatchProvider({
    required this.country,
    required this.link,
    required this.flatrate,
    required this.rent,
    required this.buy,
  });
}