import 'package:flutter/material.dart';

class OptionChainService {
  // Badge system: row index to badge letter mapping
  static const Map<int, Map<String, dynamic>> rowBadges = {
    0: {'letter': 'A', 'color': Colors.pink},
    4: {'letter': 'B', 'color': Colors.green},
    9: {'letter': 'S', 'color': Colors.red},
    11: {'letter': 'S', 'color': Colors.red},
  };

  // Mock option chain data
  static const List<Map<String, dynamic>> optionChainData = [
    {
      'strikePrice': 155,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 156,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 164,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': true,
      'label': 'ATM',
      'labelColor': Colors.orange,
    },
    {
      'strikePrice': 155,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 176,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 150,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 151,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 152,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 165,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 166,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 167,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 168,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 169,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 170,
      'callVega': 12.60,
      'callGamma': 12.60,
      'callTheta': 12.60,
      'callDelta': 12.60,
      'callOI': 12.60,
      'callLTP': 12.40,
      'putLTP': 1.40,
      'putOI': 1.05,
      'putDelta': 12.60,
      'putTheta': 12.60,
      'putGamma': 12.60,
      'putVega': 12.60,
      'type': 'call',
      'highlight': false,
    },
  ];

  // Default state values
  static const String defaultExpirationDate = 'JUN 20';
  static const String defaultType = 'call';
  static const bool defaultShowCalls = true;
  static const bool defaultShowPuts = true;
  static const bool defaultBasketEnabled = false;

  // Available options
  static const List<String> availableExpirationDates = [
    'JUN 20',
    'JUL 20',
    'AUG 20',
  ];
  static const List<String> filterPills = ['DELTA', 'OI', 'LTP'];

  /// Fetch option chain data
  Future<dynamic> fetchOptionChainData({
    required String symbol,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // TODO: Implement API call to fetch option chain data
      return optionChainData;
    } catch (e) {
      throw Exception('Error fetching option chain data: $e');
    }
  }

  /// Fetch available expiration dates
  Future<List<String>> fetchExpirationDates(String symbol) async {
    try {
      // TODO: Implement API call to fetch expiration dates
      return availableExpirationDates;
    } catch (e) {
      throw Exception('Error fetching expiration dates: $e');
    }
  }

  /// Fetch strikes for specific expiration
  Future<List<double>> fetchStrikes({
    required String symbol,
    required String expirationDate,
  }) async {
    try {
      // TODO: Implement API call to fetch strikes
      return [];
    } catch (e) {
      throw Exception('Error fetching strikes: $e');
    }
  }

  /// Get mock option chain data
  List<Map<String, dynamic>> getOptionChainData() {
    return optionChainData;
  }

  /// Get row badges mapping
  Map<int, Map<String, dynamic>> getRowBadges() {
    return rowBadges;
  }

  /// Get available expiration dates
  List<String> getAvailableExpirationDates() {
    return availableExpirationDates;
  }

  /// Get filter pills
  List<String> getFilterPills() {
    return filterPills;
  }
}
