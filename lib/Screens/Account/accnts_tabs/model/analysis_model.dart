import 'package:flutter/material.dart';

enum TradeDayStatus { win, loss, none, future }

class AnalysisMetric {
  final String label;
  final String value;

  const AnalysisMetric({required this.label, required this.value});
}

class PerformancePoint {
  final String day;
  final double winningTrades;
  final double losingTrades;

  const PerformancePoint({
    required this.day,
    required this.winningTrades,
    required this.losingTrades,
  });
}

class StatData {
  final String label;
  final String value;
  final Color? valueColor;

  const StatData({required this.label, required this.value, this.valueColor});
}
