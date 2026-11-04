class GetSymbolFromWatchlistResponse {
  const GetSymbolFromWatchlistResponse({required this.productList});

  final List<ProductItem> productList;

  factory GetSymbolFromWatchlistResponse.fromJson(Map<String, dynamic> json) {
    final rawProductList = json['productList'];
    if (rawProductList is! List) {
      throw const FormatException(
        'The symbols response must contain a productList array.',
      );
    }

    return GetSymbolFromWatchlistResponse(
      productList:
          rawProductList.map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Each productList item must be an object.',
              );
            }
            return ProductItem.fromJson(Map<String, dynamic>.from(item));
          }).toList(),
    );
  }
}

class ProductItem {
  const ProductItem({
    required this.symbol,
    required this.price,
    required this.percentageChange,
    required this.pointsChange,
    required this.bid,
    required this.ask,
  });

  final String symbol;
  final double price;
  final double percentageChange;
  final double pointsChange;
  final double bid;
  final double ask;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final rawSymbol = json['symbol'];
    if (rawSymbol is! String || rawSymbol.trim().isEmpty) {
      throw const FormatException('Each product item must have a symbol.');
    }

    return ProductItem(
      symbol: rawSymbol.trim(),
      price: _numberFromJson(json, 'price'),
      percentageChange: _numberFromJson(json, 'percentageChange'),
      pointsChange: _numberFromJson(json, 'pointsChange'),
      bid: _numberFromJson(json, 'bid'),
      ask: _numberFromJson(json, 'ask'),
    );
  }

  static double _numberFromJson(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsedValue = double.tryParse(value.trim());
      if (parsedValue != null) {
        return parsedValue;
      }
    }
    throw FormatException('Product item field "$key" must be numeric.');
  }
}
