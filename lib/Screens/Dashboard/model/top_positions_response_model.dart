import 'dart:convert';

import 'package:century_cqg/Screens/Dashboard/model/dashboard_models.dart';

class TopPositionsResponseModel {
  const TopPositionsResponseModel({
    required this.statusCode,
    required this.positions,
    this.errorMessage,
  });

  final int statusCode;
  final List<Position> positions;
  final String? errorMessage;

  bool get isSuccess => statusCode == 200;

  List<Position> get topPositions => positions;

  factory TopPositionsResponseModel.fromJson({
    required int statusCode,
    required String body,
  }) {
    if (statusCode != 200) {
      return TopPositionsResponseModel(
        statusCode: statusCode,
        positions: const [],
        errorMessage: _messageFrom(body),
      );
    }

    final decoded = jsonDecode(body);
    final rawData =
        decoded is Map<String, dynamic>
            ? (decoded['data'] is List
                ? decoded['data'] as List
                : decoded['positions'] is List
                ? decoded['positions'] as List
                : decoded['topPositions'] is List
                ? decoded['topPositions'] as List
                : decoded['top_positions'] is List
                ? decoded['top_positions'] as List
                : null)
            : decoded is List
            ? decoded
            : null;
    if (rawData == null) {
      return const TopPositionsResponseModel(
        statusCode: 200,
        positions: [],
        errorMessage: 'Top positions response is invalid.',
      );
    }

    return TopPositionsResponseModel(
      statusCode: statusCode,
      positions:
          rawData
              .whereType<Map>()
              .map((item) => Position.fromJson(Map<String, dynamic>.from(item)))
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
    return 'Unable to load top positions.';
  }
}
