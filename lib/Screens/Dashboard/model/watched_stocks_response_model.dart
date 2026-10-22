import 'dart:convert';

import 'package:century_cqg/Screens/Dashboard/model/dashboard_models.dart';

class WatchedStocksResponseModel {
  const WatchedStocksResponseModel({
    required this.statusCode,
    required this.stocks,
    this.errorMessage,
  });

  final int statusCode;
  final List<Stock> stocks;
  final String? errorMessage;

  bool get isSuccess => statusCode == 200;

  factory WatchedStocksResponseModel.fromJson({
    required int statusCode,
    required String body,
  }) {
    if (statusCode != 200) {
      return WatchedStocksResponseModel(
        statusCode: statusCode,
        stocks: const [],
        errorMessage: _messageFrom(body),
      );
    }

    final decoded = jsonDecode(body);
    final rawData =
        decoded is Map<String, dynamic> && decoded['data'] is List
            ? decoded['data'] as List
            : decoded is List
            ? decoded
            : null;
    if (rawData == null) {
      return const WatchedStocksResponseModel(
        statusCode: 200,
        stocks: [],
        errorMessage: 'Watched stocks response is invalid.',
      );
    }

    return WatchedStocksResponseModel(
      statusCode: statusCode,
      stocks:
          rawData
              .whereType<Map>()
              .map((item) => Stock.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
    );
  }

  static String _messageFrom(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] ?? decoded['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return 'Unable to load watched stocks.';
  }
}
