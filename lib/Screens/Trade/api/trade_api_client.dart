import 'dart:async';
import 'dart:convert';

import 'package:century_cqg/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class TradeApiInterceptor {
  FutureOr<void> onRequest(http.Request request) {}

  FutureOr<void> onResponse(http.Response response) {}

  FutureOr<void> onError(Object error) {}
}

class TradeApiLoggingInterceptor extends TradeApiInterceptor {
  @override
  void onRequest(http.Request request) {
    final sanitizedUri = request.url.replace(
      queryParameters: {
        for (final entry in request.url.queryParameters.entries)
          if (entry.key.toLowerCase() != 'accnt_id') entry.key: entry.value,
      },
    );
    debugPrint('Trade API ${request.method} $sanitizedUri');
  }

  @override
  void onResponse(http.Response response) {
    debugPrint('Trade API response ${response.statusCode}');
  }
}

class TradeApiException implements Exception {
  const TradeApiException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  final String message;
  final int? statusCode;
  final String? responseBody;

  @override
  String toString() => message;
}

class TradeResponseParser {
  const TradeResponseParser._();

  static Object? unwrap(Object? response) {
    if (response is Map && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }
}

class TradeApiClient {
  TradeApiClient({
    http.Client? httpClient,
    this.baseUrl = 'http://localhost:5001',
    List<TradeApiInterceptor>? interceptors,
    Duration timeout = const Duration(seconds: 20),
    String? Function()? accountIdProvider,
  }) : _httpClient = httpClient ?? http.Client(),
       _interceptors =
           interceptors ??
           (kDebugMode ? [TradeApiLoggingInterceptor()] : const []),
       _timeout = timeout,
       _accountIdProvider = accountIdProvider ?? (() => AppConfig().accountId);

  final http.Client _httpClient;
  final String baseUrl;
  final List<TradeApiInterceptor> _interceptors;
  final Duration _timeout;
  final String? Function() _accountIdProvider;

  String? get currentAccountId {
    final accountId = _accountIdProvider()?.trim();
    return accountId == null || accountId.isEmpty ? null : accountId;
  }

  Future<Object?> get(
    String path, {
    Map<String, String> queryParameters = const {},
  }) => _send('GET', path, queryParameters: queryParameters);

  Future<Object?> post(
    String path, {
    Map<String, String> queryParameters = const {},
    required Map<String, Object?> body,
  }) => _send(
    'POST',
    path,
    queryParameters: queryParameters,
    body: body,
  );

  Future<Object?> delete(
    String path, {
    Map<String, String> queryParameters = const {},
    Map<String, Object?> body = const {},
  }) => _send(
    'DELETE',
    path,
    queryParameters: queryParameters,
    body: body,
  );

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, String> queryParameters = const {},
    Map<String, Object?>? body,
  }) async {
    try {
      final accountId = currentAccountId;
      if (accountId == null) {
        throw const TradeApiException(
          message: 'A trade account ID is required.',
        );
      }

      final uri = Uri.parse('$baseUrl$path').replace(
        queryParameters: {...queryParameters, 'accnt_id': accountId},
      );
      final request = http.Request(method, uri)
        ..headers['Accept'] = 'application/json';
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode({...body, 'accnt_id': accountId});
      }

      for (final interceptor in _interceptors) {
        await interceptor.onRequest(request);
      }

      final streamedResponse = await _httpClient
          .send(request)
          .timeout(_timeout);
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(_timeout);

      for (final interceptor in _interceptors) {
        await interceptor.onResponse(response);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = TradeApiException(
          statusCode: response.statusCode,
          responseBody: response.body,
          message: _errorMessage(response),
        );
        await _notifyError(error);
        throw error;
      }
      if (response.body.trim().isEmpty) return null;

      return jsonDecode(response.body);
    } on TradeApiException {
      rethrow;
    } on TimeoutException catch (error) {
      await _notifyError(error);
      throw const TradeApiException(message: 'The trade request timed out.');
    } on FormatException catch (error) {
      await _notifyError(error);
      throw TradeApiException(
        message: 'The trade API returned invalid JSON: ${error.message}',
      );
    } on Exception catch (error) {
      await _notifyError(error);
      throw TradeApiException(message: 'Unable to reach the trade API: $error');
    }
  }

  Future<void> _notifyError(Object error) async {
    for (final interceptor in _interceptors) {
      await interceptor.onError(error);
    }
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final message =
            decoded['message'] ?? decoded['error'] ?? decoded['title'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } on FormatException {
      if (response.body.trim().isNotEmpty) return response.body.trim();
    }
    return 'Trade request failed (${response.statusCode}).';
  }

  void close() => _httpClient.close();
}
