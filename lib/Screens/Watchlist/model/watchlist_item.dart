class WatchlistItem {
  final String symbol;
  final String companyName;
  final double price;
  final double changePercent;

  const WatchlistItem({
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.changePercent,
  });
}

class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  const Tuple2(this.item1, this.item2);
}
