import 'package:intl/intl.dart';

class TradeSymbolDetails {
  const TradeSymbolDetails({
    required this.symbolName,
    required this.price,
    required this.pricePercentage,
    required this.bid,
    required this.ask,
    required this.low,
    required this.high,
    required this.chartPoints,
  });

  final String symbolName;
  final double price;
  final double pricePercentage;
  final double bid;
  final double ask;
  final double low;
  final double high;
  final List<TradeSymbolChartPoint> chartPoints;

  factory TradeSymbolDetails.fromJson(Map<String, dynamic> json) {
    final points = json['chartPoints'];
    if (points is! List) {
      throw const FormatException(
        'Trade symbol details "chartPoints" must be a list.',
      );
    }

    return TradeSymbolDetails(
      symbolName: _requiredString(json, 'symbolName'),
      price: _requiredDouble(json, 'price'),
      pricePercentage: _requiredDouble(json, 'pricePercentage'),
      bid: _requiredDouble(json, 'bid'),
      ask: _requiredDouble(json, 'ask'),
      low: _requiredDouble(json, 'low'),
      high: _requiredDouble(json, 'high'),
      chartPoints:
          points.map((point) {
            if (point is! Map) {
              throw const FormatException(
                'Trade symbol chart points must be objects.',
              );
            }
            return TradeSymbolChartPoint.fromJson(
              Map<String, dynamic>.from(point),
            );
          }).toList(),
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key]?.toString().trim();
    if (value == null || value.isEmpty) {
      throw FormatException('Trade symbol details "$key" is missing.');
    }
    return value;
  }

  static double _requiredDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    if (parsed == null || !parsed.isFinite) {
      throw FormatException('Trade symbol details "$key" is invalid.');
    }
    return parsed;
  }
}

class TradeSymbolChartPoint {
  const TradeSymbolChartPoint({required this.timestamp, required this.price});

  final DateTime timestamp;
  final double price;

  String get displayDate =>
      DateFormat('dd-MM-yyyy').format(timestamp.toLocal());

  factory TradeSymbolChartPoint.fromJson(Map<String, dynamic> json) {
    final timestampValue = json['timestamp']?.toString().trim();
    if (timestampValue == null || timestampValue.isEmpty) {
      throw const FormatException('Chart point "timestamp" is missing.');
    }

    final timestamp = _parseDate(timestampValue);
    final priceValue = json['price'];
    final price =
        priceValue is num
            ? priceValue.toDouble()
            : double.tryParse('$priceValue');
    if (price == null || !price.isFinite) {
      throw const FormatException('Chart point "price" is invalid.');
    }

    return TradeSymbolChartPoint(timestamp: timestamp, price: price);
  }

  static DateTime _parseDate(String value) {
    final isoDate = DateTime.tryParse(value);
    if (isoDate != null) return isoDate;

    try {
      return DateFormat('dd-MM-yyyy').parseStrict(value);
    } on FormatException {
      throw FormatException('Chart point timestamp "$value" is invalid.');
    }
  }
}
