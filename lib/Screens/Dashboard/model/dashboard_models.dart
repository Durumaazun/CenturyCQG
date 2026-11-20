class Stock {
  final String symbol;
  final String logo;
  final String price;
  final String change;
  final String changePoints;
  final String minPrice;
  final String maxPrice;

  Stock({
    required this.symbol,
    required this.logo,
    required this.price,
    required this.change,
    required this.changePoints,
    required this.minPrice,
    required this.maxPrice,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: '${json['symbol'] ?? ''}',
      logo: '${json['logo'] ?? ''}',
      price: _displayValue(json['price']),
      change: _displayPercent(json['percentageChange'] ?? json['change']),
      changePoints: _displayValue(json['pointsChange']),
      minPrice: _displayValue(json['bid']),
      maxPrice: _displayValue(json['ask']),
    );
  }

  static List<Stock> listFromResponse(Object? response) {
    final rawStocks =
        response is List
            ? response
            : response is Map && response['productList'] is List
            ? response['productList'] as List
            : response is Map && response['data'] is List
            ? response['data'] as List
            : null;
    if (rawStocks == null) {
      throw const FormatException(
        'The watched stocks response must contain a stock list.',
      );
    }

    return rawStocks.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'Each watched stocks item must be an object.',
        );
      }
      return Stock.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  static String _displayValue(dynamic value) {
    if (value == null) return '--';
    return value is num ? value.toStringAsFixed(2) : value.toString();
  }

  static String _displayPercent(dynamic value) {
    if (value == null) return '--';
    final text = value is num ? value.toStringAsFixed(2) : value.toString();
    return text.endsWith('%') ? text : '$text%';
  }
}

class Position {
  final String symbol;
  final String type;
  final int quantity;
  final String avgPrice;
  final String value;
  final String ltp;

  Position({
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.avgPrice,
    required this.value,
    required this.ltp,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      symbol: '${json['symbol'] ?? json['ticker'] ?? ''}',
      type: '${json['type'] ?? 'BUY'}',
      quantity: _parseQuantity(json['quantity'] ?? json['qty']),
      avgPrice: _displayValue(json['avgPrice']),
      value: _displayValue(
        json['value'] ?? json['profit'] ?? json['totalValue'],
      ),
      ltp: _displayValue(json['ltp']),
    );
  }

  static int _parseQuantity(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _displayValue(dynamic value) {
    if (value == null) return '--';
    return value is num ? value.toStringAsFixed(2) : value.toString();
  }
}
