class UserAccountState {
  final bool favorite;
  final bool watchlist;
  final double ratedValue;
  final int id;

  UserAccountState({required this.id,
    required this.favorite,
    required this.watchlist,
    required this.ratedValue,
  });
}
