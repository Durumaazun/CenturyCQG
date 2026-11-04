class GetSymbolFromWatchlistRequest {
  const GetSymbolFromWatchlistRequest({required this.watchlistName});

  final String watchlistName;

  Map<String, dynamic> toJson() => {'watchlistName': watchlistName};
}
