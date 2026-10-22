import 'dart:convert';
import 'dart:math' as io_math;
import 'package:century_cqg/Helper/nerve_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:century_cqg/Helper/nerve_enum.dart';

class NetworkResponse {
  const NetworkResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

class NetworkManager {
  static const String baseUrl = 'http://localhost:5001';

  final BuildContext _networkContext;
  NetworkManager(this._networkContext);
  static NetworkManager of(BuildContext networkContext) {
    return NetworkManager(networkContext);
  }

  Future<Object?> postApi({
    required APINames apiName,
    required dynamic postBodyData,
    bool includeFailureResponse = false,
  }) async {
    final apiNo = io_math.Random().nextInt(999);
    final path = _pathFor(apiName);
    final uri = Uri.parse('$baseUrl$path');

    final jsonBody = jsonEncode(postBodyData);

    printLog(
      apiNo.toString(),
      apiName.name,
      false,
      'URL: $uri\nBody: ${jsonEncode(_redactSensitiveValues(postBodyData))}',
    );

    try {
      final httpClient = http.Client();

      final response = await httpClient.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      httpClient.close();
      final statusCode = response.statusCode.intToApiErrorCode();

      if (statusCode == APIErrorCode.success) {
        if (response.body.isNotEmpty) {
          final jsonObj = json.decode(response.body);

          // If response has a "data" wrapper, return jsonObj["data"], else return jsonObj
          if (jsonObj is Map<String, dynamic> && jsonObj['data'] != null) {
            final responseResult = jsonObj['data'];

            printLog(
              apiNo.toString(),
              apiName.name,
              true,
              jsonEncode(_redactSensitiveValues(responseResult)),
            );

            return responseResult;
          }

          printLog(
            apiNo.toString(),
            apiName.name,
            true,
            jsonEncode(_redactSensitiveValues(jsonObj)),
          );

          return jsonObj;
        } else {
          printLog(apiNo.toString(), apiName.name, true, 'No Data');
        }
      } else {
        printLog(
          apiNo.toString(),
          apiName.name,
          true,
          _responseBodyForLog(response.body),
        );
        if (includeFailureResponse) {
          return NetworkResponse(
            statusCode: response.statusCode,
            body: response.body,
          );
        }
      }
    } catch (exception) {
      printLog(apiNo.toString(), apiName.name, true, exception.toString());
    }

    return null;
  }

  Future<Object?> getApi({
    required APINames apiName,
    Map<String, String>? queryParameters,
    bool includeFailureResponse = false,
  }) async {
    final apiNo = io_math.Random().nextInt(999);
    final path = _pathFor(apiName);
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParameters);

    printLog(apiNo.toString(), apiName.name, false, 'URL: $uri');

    try {
      final httpClient = http.Client();

      final response = await httpClient.get(
        uri,
        headers: const {'Content-Type': 'application/json'},
      );

      httpClient.close();
      final statusCode = response.statusCode.intToApiErrorCode();

      if (statusCode == APIErrorCode.success) {
        if (response.body.isNotEmpty) {
          final jsonObj = json.decode(response.body);

          // If response has a "data" wrapper, return jsonObj["data"], else return jsonObj
          if (jsonObj is Map<String, dynamic> && jsonObj['data'] != null) {
            final responseResult = jsonObj['data'];

            printLog(
              apiNo.toString(),
              apiName.name,
              true,
              jsonEncode(_redactSensitiveValues(responseResult)),
            );

            return responseResult;
          }

          printLog(
            apiNo.toString(),
            apiName.name,
            true,
            jsonEncode(_redactSensitiveValues(jsonObj)),
          );

          return jsonObj;
        } else {
          printLog(apiNo.toString(), apiName.name, true, 'No Data');
        }
      } else {
        printLog(
          apiNo.toString(),
          apiName.name,
          true,
          _responseBodyForLog(response.body),
        );
        if (includeFailureResponse) {
          return NetworkResponse(
            statusCode: response.statusCode,
            body: response.body,
          );
        }
      }
    } catch (exception) {
      printLog(apiNo.toString(), apiName.name, true, exception.toString());
    }

    return null;
  }

  void printLog(String apiNo, String apiName, bool isRes, String msg) {
    if (kDebugMode) {
      if (isRes) {
        print(
          '\n---------------$apiNo. Response - ($apiName)---(${DateTime.now().toString()})------------\n$msg\n------------------------------------------------------------------------',
        );
      } else {
        print(
          '\n---------------$apiNo. Request - ($apiName)---(${DateTime.now().toString()})------------\n$msg\n------------------------------------------------------------------------',
        );
      }
    }
  }

  String _pathFor(APINames apiName) {
    switch (apiName) {
      case APINames.login:
        return '/api/login';
      case APINames.accountSummary:
        return '/api/accounts/account_summary';
      case APINames.watchedStocks:
        return '/watched_stocks';
      case APINames.topPositions:
        return '/top_positions';
      case APINames.marketMover:
        return '/api/product/marketmover';
      case APINames.activityFeed:
        return '/api/product/activity_feed';
      case APINames.addWatchlist:
        return '/api/watchlist/add';
      case APINames.deleteWatchlist:
        return '/api/watchlist/delete';
      case APINames.renameWatchlist:
        return '/api/watchlist/rename';
      case APINames.addWatchlistSymbol:
        return '/api/watchlist/add_symbol';
      case APINames.getWatchlist:
        return '/api/watchlist/getwatchlist';
    }
  }

  Object? _redactSensitiveValues(Object? value) {
    const sensitiveKeys = {
      'password',
      'user_name',
      'username',
      'user_id',
      'userid',
      'accnt_id',
      'account_id',
      'token',
      'access_token',
      'refresh_token',
      'authorization',
    };

    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString():
              sensitiveKeys.contains(entry.key.toString().toLowerCase())
                  ? '[REDACTED]'
                  : _redactSensitiveValues(entry.value),
      };
    }
    if (value is List) {
      return value.map(_redactSensitiveValues).toList();
    }
    return value;
  }

  String _responseBodyForLog(String body) {
    try {
      return jsonEncode(_redactSensitiveValues(jsonDecode(body)));
    } on FormatException {
      return body;
    }
  }
}
