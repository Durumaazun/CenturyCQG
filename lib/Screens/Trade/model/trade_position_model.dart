import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TradePosition {
  const TradePosition({
    required this.symbolName,
    required this.price,
    required this.pricePercentage,
    required this.side,
    required this.netUnit,
    required this.avgPrice,
    required this.netPnl,
  });

  final String symbolName;
  final double price;
  final double pricePercentage;
  final String side;
  final num netUnit;
  final double avgPrice;
  final double netPnl;

  String get symbol => symbolName;
  String get displayPrice => '\$${_format(price, 2)}';
  String get displayPricePercentage =>
      '${pricePercentage >= 0 ? '+' : ''}${_format(pricePercentage, 2)}%';
  String get netUnits => NumberFormat('#,##0.##').format(netUnit);
  String get averageAmount => _format(avgPrice, 2);
  String get displayNetPnl => '${netPnl >= 0 ? '+' : ''}${_format(netPnl, 2)}';
  String get netPnL => displayNetPnl;
  String get badge => symbolName.isEmpty ? '' : symbolName[0].toUpperCase();

  Color get badgeColor => const Color(0xFF8E8E93);

  factory TradePosition.fromJson(Map<String, dynamic> json) {
    return TradePosition(
      symbolName: _requiredString(json, 'symbolName'),
      price: _requiredDouble(json, 'price'),
      pricePercentage: _requiredDouble(json, 'pricePercentage'),
      side: _requiredString(json, 'b_s'),
      netUnit: _requiredNumber(json, 'netUnit'),
      avgPrice: _requiredDouble(json, 'avgPrice'),
      netPnl: _requiredDouble(json, 'netPnl'),
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key]?.toString().trim();
    if (value == null || value.isEmpty) {
      throw FormatException('Trade position "$key" is missing.');
    }
    return value;
  }

  static num _requiredNumber(Map<String, dynamic> json, String key) {
    final value = json[key];
    final parsed = value is num ? value : num.tryParse('$value');
    if (parsed == null || !parsed.isFinite) {
      throw FormatException('Trade position "$key" is invalid.');
    }
    return parsed;
  }

  static double _requiredDouble(Map<String, dynamic> json, String key) =>
      _requiredNumber(json, key).toDouble();

  static String _format(num value, int decimalDigits) {
    final decimalPattern = List<String>.filled(decimalDigits, '0').join();
    return NumberFormat(
      decimalDigits == 0 ? '#,##0' : '#,##0.$decimalPattern',
    ).format(value);
  }
}
