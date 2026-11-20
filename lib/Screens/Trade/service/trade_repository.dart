import 'package:century_cqg/Screens/Trade/api/trade_api_client.dart';
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/model/trade_position_model.dart';
import 'package:century_cqg/Screens/Trade/model/trade_symbol_details_model.dart';

class TradeRepository {
  TradeRepository({TradeApiClient? apiClient})
    : _apiClient = apiClient ?? TradeApiClient();

  final TradeApiClient _apiClient;
  String? get currentAccountId => _apiClient.currentAccountId;

  Future<TradeSymbolDetails> fetchSymbolDetails(
    String symbolName, {
    String period = '1D',
  }) async {
    final response = await _apiClient.get(
      '/api/trade/symbolDetails',
      queryParameters: {'symbolName': symbolName, 'period': period},
    );
    return _object(
      response,
      'symbol details',
      TradeSymbolDetails.fromJson,
    );
  }

  Future<List<NetPositionDetail>> fetchNetPositionDetails(
    String symbolName,
  ) async {
    final response = await _apiClient.get(
      '/api/trade/netPosDet',
      queryParameters: {'symbolName': symbolName},
    );
    return _list(
      response,
      'net position details',
      (json) => NetPositionDetail.fromJson(json),
    );
  }

  Future<TradePositionSummary> fetchPositionDetails(String symbolName) async {
    final response = await _apiClient.get(
      '/api/trade/positionDet',
      queryParameters: {'symbolName': symbolName},
    );
    return _object(
      response,
      'position details',
      TradePositionSummary.fromJson,
    );
  }

  Future<TradeOrder> submitOrder(TradeOrderRequest request) async {
    final response = await _apiClient.post(
      '/api/trade/orders',
      body: request.toJson(),
    );
    return _object(response, 'order', TradeOrder.fromJson);
  }

  Future<List<TradeOrder>> fetchOrders() async {
    final response = await _apiClient.get('/api/trade/orders');
    return _list(response, 'orders', (json) => TradeOrder.fromJson(json));
  }

  Future<TradeFillResult> applyFill(TradeFillRequest request) async {
    final response = await _apiClient.post(
      '/api/trade/buySell/fill',
      body: request.toJson(),
    );
    return _object(response, 'fill result', TradeFillResult.fromJson);
  }

  Future<TradeOrder> cancelOrder(String orderId) async {
    final response = await _apiClient.post(
      '/api/trade/orders/${Uri.encodeComponent(orderId)}/cancel',
      queryParameters: const {},
      body: const {},
    );
    return _object(response, 'canceled order', TradeOrder.fromJson);
  }

  Future<List<TradeExecution>> fetchExecutions() async {
    final response = await _apiClient.get('/api/trade/executions');
    return _list(
      response,
      'executions',
      (json) => TradeExecution.fromJson(json),
    );
  }

  Future<List<TradePosition>> fetchPositions({String data = 'All'}) async {
    final response = await _apiClient.get(
      '/api/trade/tradePosition',
      queryParameters: {'Data': data},
    );
    return _list(response, 'positions', (json) => TradePosition.fromJson(json));
  }

  Future<void> deletePosition(String symbolName) async {
    await _apiClient.delete(
      '/api/trade/deletetradeposition',
      body: {'symbolName': symbolName},
    );
  }

  Future<List<TradeHistoryItem>> fetchHistory() async {
    final response = await _apiClient.get('/api/trade/history');
    return _list(
      response,
      'history',
      (json) => TradeHistoryItem.fromJson(json),
    );
  }

  List<T> _list<T>(
    Object? response,
    String name,
    T Function(Map<String, dynamic>) parse,
  ) {
    try {
      final payload = TradeResponseParser.unwrap(response);
      if (payload is! List) {
        throw FormatException('The trade $name response must be a list.');
      }
      return payload
          .map((item) {
            if (item is! Map) {
              throw FormatException('Trade $name entries must be objects.');
            }
            return parse(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);
    } on FormatException catch (error) {
      throw TradeRepositoryException(
        'Invalid trade $name response: ${error.message}',
        cause: error,
      );
    } on TypeError catch (error) {
      throw TradeRepositoryException(
        'Invalid trade $name response.',
        cause: error,
      );
    }
  }

  Map<String, dynamic> _map(Object? response, String name) {
    response = TradeResponseParser.unwrap(response);
    if (response is! Map) {
      throw TradeRepositoryException(
        'The trade $name response must be an object.',
      );
    }
    try {
      return Map<String, dynamic>.from(response);
    } on TypeError catch (error) {
      throw TradeRepositoryException(
        'Invalid trade $name response.',
        cause: error,
      );
    }
  }

  T _object<T>(
    Object? response,
    String name,
    T Function(Map<String, dynamic>) parse,
  ) {
    try {
      return parse(_map(response, name));
    } on TradeRepositoryException {
      rethrow;
    } on FormatException catch (error) {
      throw TradeRepositoryException(
        'Invalid trade $name response: ${error.message}',
        cause: error,
      );
    } on TypeError catch (error) {
      throw TradeRepositoryException(
        'Invalid trade $name response.',
        cause: error,
      );
    }
  }

  void close() => _apiClient.close();
}

class TradeRepositoryException implements Exception {
  const TradeRepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
