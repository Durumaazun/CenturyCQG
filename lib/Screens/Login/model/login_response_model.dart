import 'dart:convert';

class LoginResponseModel {
  const LoginResponseModel({
    required this.statusCode,
    this.message,
    this.error,
    this.accountId,
  });

  final int statusCode;
  final String? message;
  final String? error;
  final String? accountId;

  bool get isSuccess => statusCode == 200;

  factory LoginResponseModel.fromJson({
    required int statusCode,
    required String body,
  }) {
    String? message;
    String? error;
    String? accountId;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final value = decoded['message'];
        final errorValue = decoded['error'];
        message = value is String ? value : null;
        error = errorValue is String ? errorValue : null;

        final payload =
            decoded['data'] is Map<String, dynamic>
                ? decoded['data'] as Map<String, dynamic>
                : decoded;
        final user =
            payload['user'] is Map<String, dynamic>
                ? payload['user'] as Map<String, dynamic>
                : const <String, dynamic>{};
        final rawAccountId =
            user['accountId'] ??
            user['account_id'] ??
            payload['accountId'] ??
            payload['account_id'] ??
            decoded['accountId'] ??
            decoded['account_id'];
        if (rawAccountId != null) {
          accountId = rawAccountId.toString();
        }
      }
    } on FormatException {
      error = body.isEmpty ? null : body;
    }

    return LoginResponseModel(
      statusCode: statusCode,
      message: message,
      error: error,
      accountId: accountId,
    );
  }
}
