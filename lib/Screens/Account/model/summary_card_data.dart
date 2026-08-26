import 'package:flutter/material.dart';

class SummaryCardData {
  final String label;
  final String value;
  final Color valueColor;
  final Color lightBackground;
  final Color darkBackground;

  const SummaryCardData({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.lightBackground,
    required this.darkBackground,
  });
}
