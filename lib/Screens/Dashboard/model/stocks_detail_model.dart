import 'package:flutter/material.dart';

class StockItem {
  final String symbol;
  final String name;
  final String iconUrl; // Or use an IconData / local asset path
  final double price;
  final double percentageChange;
  final double pointsChange;
  final double bid;
  final double ask;
  final List<Offset> sparklinePoints;

  const StockItem({
    required this.symbol,
    required this.name,
    required this.iconUrl,
    required this.price,
    required this.percentageChange,
    required this.pointsChange,
    required this.bid,
    required this.ask,
    required this.sparklinePoints,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      symbol: '${json['symbol'] ?? json['ticker'] ?? ''}',
      name: '${json['name'] ?? json['companyName'] ?? json['symbol'] ?? ''}',
      iconUrl: '${json['iconUrl'] ?? json['icon'] ?? json['logo'] ?? ''}',
      price: _parseDouble(json['price']),
      percentageChange: _parseDouble(
        json['percentageChange'] ?? json['changePercent'] ?? json['change'],
      ),
      pointsChange: _parseDouble(
        json['pointsChange'] ?? json['changePoints'] ?? json['points'],
      ),
      bid: _parseDouble(json['bid'] ?? json['minPrice']),
      ask: _parseDouble(json['ask'] ?? json['maxPrice']),
      sparklinePoints: _parseSparklinePoints(json['sparklinePoints']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final sanitized = value
          .replaceAll('%', '')
          .replaceAll('\$', '')
          .replaceAll(',', '')
          .trim();
      return double.tryParse(sanitized) ?? 0.0;
    }
    return 0.0;
  }

  static List<Offset> _parseSparklinePoints(dynamic value) {
    if (value is List) {
      final points = <Offset>[];
      for (final item in value) {
        if (item is Map) {
          final dx = _parseDouble(item['dx'] ?? item['x']);
          final dy = _parseDouble(item['dy'] ?? item['y']);
          points.add(Offset(dx, dy));
        } else if (item is num) {
          points.add(Offset(0.0, item.toDouble()));
        }
      }
      if (points.isNotEmpty) return points;
    }
    return const [
      Offset(0.0, 0.5),
      Offset(0.2, 0.6),
      Offset(0.4, 0.3),
      Offset(0.6, 0.7),
      Offset(0.8, 0.4),
      Offset(1.0, 0.5),
    ];
  }
}

