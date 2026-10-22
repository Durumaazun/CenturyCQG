class WatchlistItem {
  final String symbol;
  final String companyName;
  final double price;
  final double changePercent;
  final double pointsChange;
  final double bid;
  final double ask;

  const WatchlistItem({
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.changePercent,
    this.pointsChange = 0,
    this.bid = 0,
    this.ask = 0,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      symbol: json['symbol']?.toString() ?? '',
      companyName:
          json['companyName']?.toString() ??
          json['name']?.toString() ??
          json['symbol']?.toString() ??
          '',
      price: _parseAmount(json['price']),
      changePercent: _parseAmount(
        json['percentageChange'] ?? json['changePercent'],
      ),
      pointsChange: _parseAmount(json['pointsChange']),
      bid: _parseAmount(json['bid']),
      ask: _parseAmount(json['ask']),
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
    }
    return 0;
  }
}

class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  const Tuple2(this.item1, this.item2);
}
