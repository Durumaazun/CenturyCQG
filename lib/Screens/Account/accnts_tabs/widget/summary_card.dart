import 'package:flutter/material.dart';
import 'package:century_cqg/Screens/Account/model/account_model.dart';

class SummaryCard extends StatelessWidget {
  final SummaryCardData item;
  final bool isDarkMode;

  const SummaryCard({super.key, required this.item, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? item.darkBackground : item.lightBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1,
              letterSpacing: 0,
              color: item.valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
              color: item.valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
