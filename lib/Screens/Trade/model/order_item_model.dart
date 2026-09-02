import 'package:flutter/material.dart';

class OrderItem {
  final String symbol;
  final String iconText;
  final Color iconBg;
  final String type;
  final String tag1;
  final String tag2;

  const OrderItem({
    required this.symbol,
    required this.iconText,
    required this.iconBg,
    required this.type,
    required this.tag1,
    required this.tag2,
  });
}
