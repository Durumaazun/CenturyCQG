import 'package:flutter/material.dart';

import 'package:century_cqg/Screens/Trade/Holdings/model/holding_model.dart';

class HoldingService extends ChangeNotifier {
  final List<HoldingItem> _holdings = const [
    HoldingItem(
      symbol: 'AAPL',
      orderId: '#5458592',
      orderTime: '2:56 GST',
      side: 'Buy',
      units: '200',
      amount: '6000',
      profit: '172.00',
      iconText: 'A',
      iconColor: Color(0xFF111111),
    ),
    HoldingItem(
      symbol: 'TSLA',
      orderId: '#5458592',
      orderTime: '2:56 GST',
      side: 'Buy',
      units: '200',
      amount: '6000',
      profit: '172.00',
      iconText: 'T',
      iconColor: Color(0xFFE82127),
    ),
    HoldingItem(
      symbol: 'NVDA',
      orderId: '#5458592',
      orderTime: '2:56 GST',
      side: 'Buy',
      units: '200',
      amount: '6000',
      profit: '172.00',
      iconText: 'N',
      iconColor: Color(0xFF6BAF2A),
    ),
  ];

  List<HoldingItem> get holdings => List.unmodifiable(_holdings);

  String _filterTime = 'Today';
  String _filterSymbol = 'AAPL';
  String _filterType = 'Index';

  String get filterTime => _filterTime;
  String get filterSymbol => _filterSymbol;
  String get filterType => _filterType;

  void setFilterTime(String value) {
    _filterTime = value;
    notifyListeners();
  }

  void setFilterSymbol(String value) {
    _filterSymbol = value;
    notifyListeners();
  }

  void setFilterType(String value) {
    _filterType = value;
    notifyListeners();
  }
}
