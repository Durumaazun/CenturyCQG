import 'dart:convert';

import 'package:century_cqg/Screens/Trade/api/trade_api_client.dart';
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/model/trade_symbol_details_model.dart';
import 'package:century_cqg/Screens/Trade/service/trade_orders_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_repository.dart';
import 'package:century_cqg/Screens/Trade/service/trade_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Trade API models', () {
    test('serializes order request fields for the backend contract', () {
      const request = TradeOrderRequest(
        symbolName: 'TEST',
        side: 'BUY',
        quantity: 3,
        orderType: 'LIMIT',
        amount: 300,
        limitPrice: 100,
      );

      expect(request.toJson(), {
        'symbolName': 'TEST',
        'BS': 'buy',
        'quantity': 3,
        'orderType': 'limit',
        'amount': 300,
        'limitPrice': 100,
        'stopPrice': null,
        'stopLoss': null,
        'takeProfit': null,
      });
    });

    test('maps order response and keeps optional prices null', () {
      final order = TradeOrder.fromJson(_orderJson());

      expect(order.orderId, 'order-1');
      expect(order.side, 'buy');
      expect(order.status, 'pending');
      expect(order.remainingQuantity, 3);
      expect(order.limitPrice, isNull);
      expect(order.createdAt, DateTime.parse('2026-01-02T03:04:05Z'));
    });

    test('parses all backend chart points and retains ISO timezone', () {
      final point = TradeSymbolChartPoint.fromJson({
        'timestamp': '2026-11-16T23:06:44.4883452+00:00',
        'price': 577.87,
      });

      expect(point.timestamp.toUtc().year, 2026);
      expect(point.timestamp.toUtc().day, 16);
      expect(point.timestamp.toUtc().hour, 23);
      expect(point.timestamp.toUtc().minute, 6);
      expect(point.price, 577.87);
    });
  });

  group('TradeApiClient', () {
    test(
      'returns decoded payloads and reports HTTP failures to interceptors',
      () async {
        final interceptor = _RecordingInterceptor();
        final client = TradeApiClient(
          baseUrl: 'https://trade.test',
          interceptors: [interceptor],
          accountIdProvider: () => 'account-1',
          httpClient: MockClient((request) async {
            if (request.url.path == '/success') {
              return http.Response('{"data":{"ok":true}}', 200);
            }
            return http.Response('{"message":"Invalid order"}', 422);
          }),
        );
        addTearDown(client.close);

        expect(await client.get('/success'), {
          'data': {'ok': true},
        });
        await expectLater(
          client.get('/failure'),
          throwsA(
            isA<TradeApiException>()
                .having((error) => error.statusCode, 'status code', 422)
                .having((error) => error.message, 'message', 'Invalid order'),
          ),
        );
        expect(interceptor.lastError, isA<TradeApiException>());
      },
    );

    test('requires an account ID and always includes it in query and body', () async {
      final requests = <http.Request>[];
      final client = TradeApiClient(
        baseUrl: 'https://trade.test',
        interceptors: const [],
        accountIdProvider: () => 'account-1',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('[]', 200);
        }),
      );
      addTearDown(client.close);

      await client.get('/orders');
      await client.post('/orders', body: const {'symbolName': 'TEST'});
      expect(requests, hasLength(2));
      for (final request in requests) {
        expect(request.url.queryParameters['accnt_id'], 'account-1');
      }
      expect(
        jsonDecode(requests.last.body),
        {'symbolName': 'TEST', 'accnt_id': 'account-1'},
      );

      final noAccountClient = TradeApiClient(
        baseUrl: 'https://trade.test',
        interceptors: const [],
        accountIdProvider: () => null,
        httpClient: MockClient((_) async => http.Response('[]', 200)),
      );
      addTearDown(noAccountClient.close);
      await expectLater(
        noAccountClient.get('/orders'),
        throwsA(
          isA<TradeApiException>().having(
            (error) => error.message,
            'message',
            'A trade account ID is required.',
          ),
        ),
      );
    });
  });

  test('shared response parser accepts direct and enveloped payloads', () {
    const direct = [1, 2];
    expect(TradeResponseParser.unwrap(direct), direct);
    expect(TradeResponseParser.unwrap({'data': direct}), direct);
  });

  test('repository maps the supplied trade endpoint routes', () async {
    final requests = <String>[];
    final requestAccounts = <String?>[];
    final requestBodies = <Map<String, dynamic>>[];
    final apiClient = TradeApiClient(
      baseUrl: 'https://trade.test',
      interceptors: const [],
      accountIdProvider: () => 'account-1',
      httpClient: MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        requestAccounts.add(request.url.queryParameters['accnt_id']);
        if (request.body.isNotEmpty) {
          requestBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        }
        final path = request.url.path;
        if (path.endsWith('/symbolDetails')) {
          return http.Response(
            '{"data":{"symbolName":"TEST","price":100,"pricePercentage":1,'
            '"bid":99,"ask":101,"low":90,"high":110,"chartPoints":[]}}',
            200,
          );
        }
        if (path.endsWith('/netPosDet')) {
          return http.Response('{"data":[]}', 200);
        }
        if (path.endsWith('/positionDet')) {
          return http.Response(
            '{"data":{"symbolName":"TEST","b_s":"Buy","netUnit":3,'
            '"avgPrice":100,"netPnl":0,"marketPrice":100,"positionValue":300}}',
            200,
          );
        }
        if (path.endsWith('/buySell/fill')) {
          return http.Response(
            '{"data":{"orderId":"order-1","status":"partial",'
            '"symbolName":"TEST","BS":"buy","units":3,"amount":300,'
            '"orderType":"market","timeInForce":"DAY","goodTillDate":null,'
            '"limitPrice":null,"stopEntryPrice":null,"filledUnits":1,'
            '"remainingUnits":2,"completionReported":false}}',
            200,
          );
        }
        if (path.endsWith('/cancel')) {
          return http.Response(jsonEncode({'data': _orderJson()}), 200);
        }
        if (path.endsWith('/orders') && request.method == 'POST') {
          return http.Response(jsonEncode({'data': _orderJson()}), 201);
        }
        if (path.endsWith('/tradePosition') ||
            path.endsWith('/executions') ||
            path.endsWith('/history') ||
            path.endsWith('/orders')) {
          return http.Response('{"data":[]}', 200);
        }
        if (path.endsWith('/deletetradeposition')) {
          return http.Response('{"data":true}', 200);
        }
        return http.Response('{"message":"Unexpected endpoint"}', 404);
      }),
    );
    final repository = TradeRepository(apiClient: apiClient);
    addTearDown(repository.close);

    await repository.fetchSymbolDetails('TEST');
    await repository.fetchNetPositionDetails('TEST');
    await repository.fetchPositionDetails('TEST');
    await repository.submitOrder(
      const TradeOrderRequest(
        symbolName: 'TEST',
        side: 'buy',
        quantity: 3,
        orderType: 'market',
        amount: 300,
      ),
    );
    await repository.fetchOrders();
    await repository.applyFill(
      const TradeFillRequest(
        orderId: 'order-1',
        fillId: 'fill-1',
        filledUnits: 1,
        fillPrice: 100,
      ),
    );
    await repository.cancelOrder('order-1');
    await repository.fetchExecutions();
    await repository.fetchPositions();
    await repository.fetchPositions(data: 'TEST');
    await repository.fetchHistory();
    await repository.deletePosition('TEST');

    expect(
      requests,
      containsAll([
        'GET /api/trade/symbolDetails',
        'GET /api/trade/netPosDet',
        'GET /api/trade/positionDet',
        'POST /api/trade/orders',
        'GET /api/trade/orders',
        'POST /api/trade/buySell/fill',
        'POST /api/trade/orders/order-1/cancel',
        'GET /api/trade/executions',
        'GET /api/trade/tradePosition',
        'GET /api/trade/history',
        'DELETE /api/trade/deletetradeposition',
      ]),
    );
    expect(
      requests.where((request) => request == 'GET /api/trade/tradePosition'),
      hasLength(2),
    );
    expect(requestAccounts, everyElement('account-1'));
    expect(
      requestBodies.every((body) => body['accnt_id'] == 'account-1'),
      isTrue,
    );
  });

  test('submitting an order exposes the API-confirmed pending order', () async {
    final apiClient = TradeApiClient(
      baseUrl: 'https://trade.test',
      interceptors: const [],
      accountIdProvider: () => 'account-1',
      httpClient: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({'data': [_orderJson()]}),
            200,
          );
        }
        expect(request.method, 'POST');
        expect(request.url.path, '/api/trade/orders');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['symbolName'], 'TEST');
        expect(body['BS'], 'buy');
        expect(body['quantity'], 3);
        return http.Response(jsonEncode({'data': _orderJson()}), 201);
      }),
    );
    final repository = TradeRepository(apiClient: apiClient);
    final service = TradeOrdersService(
      useCases: TradeUseCases(repository),
      accountIdProvider: () => 'account-1',
    );
    addTearDown(() {
      service.dispose();
      repository.close();
    });

    final order = await service.submitOrder(
      const TradeOrderRequest(
        symbolName: 'TEST',
        side: 'buy',
        quantity: 3,
        orderType: 'market',
        amount: 300,
      ),
    );

    expect(order?.status, 'pending');
    expect(service.orders.single.orderId, 'order-1');
    expect(service.isSubmitting, isFalse);
  });

  test('a completed fill requests downstream trade-section refresh', () async {
    var fillIsComplete = false;
    var refreshCount = 0;
    var updateCount = 0;
    final apiClient = TradeApiClient(
      baseUrl: 'https://trade.test',
      interceptors: const [],
      accountIdProvider: () => 'account-1',
      httpClient: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response('{"data":[]}', 200);
        }
        final isComplete = fillIsComplete;
        return http.Response(
          jsonEncode({
            'data': {
              'orderId': 'order-1',
              'status': isComplete ? 'filled' : 'partial',
              'symbolName': 'TEST',
              'BS': 'buy',
              'units': 3,
              'amount': 300,
              'orderType': 'market',
              'timeInForce': 'DAY',
              'goodTillDate': null,
              'limitPrice': null,
              'stopEntryPrice': null,
              'filledUnits': isComplete ? 3 : 1,
              'remainingUnits': isComplete ? 0 : 2,
              'completionReported': isComplete,
            },
          }),
          200,
        );
      }),
    );
    final repository = TradeRepository(apiClient: apiClient);
    final service = TradeOrdersService(
      useCases: TradeUseCases(repository),
      onOrderCompleted: () => refreshCount++,
      onOrderUpdated: () => updateCount++,
      accountIdProvider: () => 'account-1',
    );
    addTearDown(() {
      service.dispose();
      repository.close();
    });

    const fillRequest = TradeFillRequest(
      orderId: 'order-1',
      fillId: 'fill-1',
      filledUnits: 1,
      fillPrice: 100,
    );
    final partialFill = await service.applyFillForTesting(fillRequest);
    expect(partialFill.status, 'partial');
    expect(refreshCount, 0);
    expect(updateCount, 1);

    fillIsComplete = true;
    final completedFill = await service.applyFillForTesting(fillRequest);
    expect(completedFill.status, 'filled');
    expect(refreshCount, 1);
    expect(updateCount, 2);
  });

  test('failed fill retries reuse the same fill ID', () async {
    final fillIds = <String>[];
    var fillAttempts = 0;
    final apiClient = TradeApiClient(
      baseUrl: 'https://trade.test',
      interceptors: const [],
      accountIdProvider: () => 'account-1',
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/buySell/fill')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          fillIds.add(body['fillId'] as String);
          fillAttempts++;
          if (fillAttempts == 1) {
            return http.Response('{"message":"Temporary failure"}', 503);
          }
          return http.Response(
            jsonEncode({
              'data': _fillJson(
                status: 'partial',
                filledUnits: 1,
                remainingUnits: 2,
                completionReported: false,
              ),
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/orders')) {
          return http.Response(
            jsonEncode({
              'data': [
                _orderJson(
                  status: 'partial',
                  filledQuantity: 1,
                  remainingQuantity: 2,
                ),
              ],
            }),
            200,
          );
        }
        return http.Response('{"message":"Unexpected endpoint"}', 404);
      }),
    );
    final repository = TradeRepository(apiClient: apiClient);
    final service = TradeOrdersService(
      useCases: TradeUseCases(repository),
      accountIdProvider: () => 'account-1',
    );
    addTearDown(() {
      service.dispose();
      repository.close();
    });

    expect(
      await service.fillOrder(
        orderId: 'order-1',
        filledUnits: 1,
        fillPrice: 100,
      ),
      isNull,
    );
    expect(service.fillError, 'Temporary failure');

    final result = await service.fillOrder(
      orderId: 'order-1',
      filledUnits: 1,
      fillPrice: 100,
    );

    expect(result?.status, 'partial');
    expect(fillIds, hasLength(2));
    expect(fillIds.first, fillIds.last);
    expect(fillIds.first, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(service.orders.single.status, 'partial');
    expect(service.fillError, isNull);
  });

  test('partial and full fills refresh orders and all trade state providers', () async {
    var fillCount = 0;
    final apiClient = TradeApiClient(
      baseUrl: 'https://trade.test',
      interceptors: const [],
      accountIdProvider: () => 'account-1',
      httpClient: MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/buySell/fill')) {
          fillCount++;
          return http.Response(
            jsonEncode({
              'data':
                  fillCount == 1
                      ? _fillJson(
                        status: 'partial',
                        filledUnits: 1,
                        remainingUnits: 2,
                        completionReported: false,
                      )
                      : _fillJson(
                        status: 'filled',
                        filledUnits: 3,
                        remainingUnits: 0,
                        completionReported: true,
                      ),
            }),
            200,
          );
        }
        if (path.endsWith('/orders')) {
          return http.Response(
            jsonEncode({
              'data': [
                _orderJson(
                  status: fillCount == 1 ? 'partial' : 'filled',
                  filledQuantity: fillCount == 1 ? 1 : 3,
                  remainingQuantity: fillCount == 1 ? 2 : 0,
                  completionReported: fillCount > 1,
                ),
              ],
            }),
            200,
          );
        }
        if (path.endsWith('/executions')) {
          return http.Response(
            jsonEncode({
              'data': List.generate(fillCount, (index) => _executionJson(index)),
            }),
            200,
          );
        }
        if (path.endsWith('/tradePosition')) {
          return http.Response(
            jsonEncode({
              'data': [_positionJson(netUnit: fillCount == 1 ? 1 : 3)],
            }),
            200,
          );
        }
        if (path.endsWith('/netPosDet')) {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'b_s': 'Buy',
                  'netUnit': fillCount == 1 ? 1 : 3,
                  'avgPrice': 100,
                  'netPnl': 0,
                },
              ],
            }),
            200,
          );
        }
        if (path.endsWith('/positionDet')) {
          return http.Response(
            jsonEncode({
              'data': {
                'symbolName': 'TEST',
                'b_s': 'Buy',
                'netUnit': fillCount == 1 ? 1 : 3,
                'avgPrice': 100,
                'netPnl': 0,
                'marketPrice': 100,
                'positionValue': fillCount == 1 ? 100 : 300,
              },
            }),
            200,
          );
        }
        if (path.endsWith('/history')) {
          return http.Response(
            jsonEncode({
              'data': [
                _historyJson(status: fillCount == 1 ? 'partial' : 'filled'),
              ],
            }),
            200,
          );
        }
        return http.Response('{"message":"Unexpected endpoint"}', 404);
      }),
    );
    final repository = TradeRepository(apiClient: apiClient);
    final useCases = TradeUseCases(repository);
    final executions = ExecutionService(
      useCases: useCases,
      accountIdProvider: () => 'account-1',
    );
    final positions = TradePageService(
      useCases: useCases,
      accountIdProvider: () => 'account-1',
    );
    final history = HistoryService(
      useCases: useCases,
      accountIdProvider: () => 'account-1',
    );
    final orders = TradeOrdersService(
      useCases: useCases,
      accountIdProvider: () => 'account-1',
      onFillApplied: (_) async {
        await Future.wait([
          executions.fetchExecutions(),
          positions.refreshPositions(),
          positions.refreshPositionDetails(symbolName: 'TEST'),
          history.fetchHistory(),
        ]);
      },
    );
    addTearDown(() {
      orders.dispose();
      executions.dispose();
      positions.dispose();
      history.dispose();
      repository.close();
    });

    final partial = await orders.fillOrder(
      orderId: 'order-1',
      filledUnits: 1,
      fillPrice: 100,
    );
    expect(partial?.status, 'partial');
    expect(orders.orders.single.status, 'partial');
    expect(executions.executions, hasLength(1));
    expect(positions.positions.single.netUnit, 1);
    expect(positions.netPositionDetails.single.netUnit, 1);
    expect(positions.positionSummary?.netUnit, 1);
    expect(history.history.single.status, 'partial');

    final filled = await orders.fillOrder(
      orderId: 'order-1',
      filledUnits: 2,
      fillPrice: 101,
    );
    expect(filled?.status, 'filled');
    expect(filled?.completionReported, isTrue);
    expect(orders.orders.single.status, 'filled');
    expect(orders.orders.single.remainingQuantity, 0);
    expect(executions.executions, hasLength(2));
    expect(positions.positions.single.netUnit, 3);
    expect(positions.netPositionDetails.single.netUnit, 3);
    expect(positions.positionSummary?.netUnit, 3);
    expect(history.history.single.status, 'filled');
  });

  test('trade providers clear cached state when the account changes', () async {
    var activeAccountId = 'account-a';
    final accountIdProvider = () => activeAccountId;
    final apiClient = TradeApiClient(
      baseUrl: 'https://trade.test',
      interceptors: const [],
      accountIdProvider: accountIdProvider,
      httpClient: MockClient((request) async {
        final accountId = request.url.queryParameters['accnt_id'];
        if (request.url.path.endsWith('/orders')) {
          return http.Response(
            jsonEncode({'data': [_orderJson(symbolName: accountId!)]}),
            200,
          );
        }
        if (request.url.path.endsWith('/executions')) {
          return http.Response(
            jsonEncode({'data': [_executionJson(0, symbolName: accountId!)]}),
            200,
          );
        }
        if (request.url.path.endsWith('/tradePosition')) {
          return http.Response(
            jsonEncode({
              'data': [_positionJson(symbolName: accountId!)],
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/history')) {
          return http.Response(
            jsonEncode({'data': [_historyJson(symbolName: accountId!)]}),
            200,
          );
        }
        return http.Response('{"data":[]}', 200);
      }),
    );
    final repository = TradeRepository(apiClient: apiClient);
    final useCases = TradeUseCases(repository);
    final orders = TradeOrdersService(
      useCases: useCases,
      accountIdProvider: accountIdProvider,
    );
    final executions = ExecutionService(
      useCases: useCases,
      accountIdProvider: accountIdProvider,
    );
    final positions = TradePageService(
      useCases: useCases,
      accountIdProvider: accountIdProvider,
    );
    final history = HistoryService(
      useCases: useCases,
      accountIdProvider: accountIdProvider,
    );
    addTearDown(() {
      orders.dispose();
      executions.dispose();
      positions.dispose();
      history.dispose();
      repository.close();
    });

    await Future.wait([
      orders.fetchOrders(),
      executions.fetchExecutions(),
      positions.refreshPositions(),
      history.fetchHistory(),
    ]);
    expect(orders.orders.single.symbolName, 'account-a');
    expect(executions.executions.single.symbolName, 'account-a');
    expect(positions.positions.single.symbolName, 'account-a');
    expect(history.history.single.symbolName, 'account-a');

    activeAccountId = 'account-b';
    expect(orders.orders, isEmpty);
    expect(executions.executions, isEmpty);
    expect(positions.positions, isEmpty);
    expect(history.history, isEmpty);
  });

  test('cancel updates the order state from the backend response', () async {
    final apiClient = TradeApiClient(
      baseUrl: 'https://trade.test',
      interceptors: const [],
      accountIdProvider: () => 'account-1',
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/cancel')) {
          return http.Response(
            jsonEncode({'data': _orderJson(status: 'canceled')}),
            200,
          );
        }
        return http.Response('{"data":[]}', 200);
      }),
    );
    final repository = TradeRepository(apiClient: apiClient);
    final service = TradeOrdersService(
      useCases: TradeUseCases(repository),
      accountIdProvider: () => 'account-1',
    );
    addTearDown(() {
      service.dispose();
      repository.close();
    });

    expect(await service.cancelOrder('order-1'), isTrue);
    expect(service.orders.single.status, 'canceled');
  });
}

class _RecordingInterceptor extends TradeApiInterceptor {
  Object? lastError;

  @override
  void onError(Object error) {
    lastError = error;
  }
}

Map<String, dynamic> _orderJson({
  String symbolName = 'TEST',
  String status = 'pending',
  num filledQuantity = 0,
  num remainingQuantity = 3,
  bool completionReported = false,
}) => {
  'orderId': 'order-1',
  'symbolName': symbolName,
  'BS': 'buy',
  'orderType': 'market',
  'amount': 300,
  'quantity': 3,
  'filledQuantity': filledQuantity,
  'remainingQuantity': remainingQuantity,
  'status': status,
  'limitPrice': null,
  'stopPrice': null,
  'stopLoss': null,
  'takeProfit': null,
  'createdAt': '2026-01-02T03:04:05Z',
  'updatedAt': '2026-01-02T03:04:05Z',
  'completionReported': completionReported,
};

Map<String, dynamic> _fillJson({
  required String status,
  required num filledUnits,
  required num remainingUnits,
  required bool completionReported,
}) => {
  'orderId': 'order-1',
  'status': status,
  'symbolName': 'TEST',
  'BS': 'buy',
  'units': 3,
  'amount': 300,
  'orderType': 'market',
  'timeInForce': 'DAY',
  'goodTillDate': null,
  'limitPrice': null,
  'stopEntryPrice': null,
  'filledUnits': filledUnits,
  'remainingUnits': remainingUnits,
  'completionReported': completionReported,
};

Map<String, dynamic> _executionJson(int index, {String symbolName = 'TEST'}) => {
  'executionId': 'execution-$index',
  'orderId': 'order-1',
  'symbolName': symbolName,
  'BS': 'buy',
  'fillQuantity': 1,
  'fillPrice': 100,
  'amount': 100,
  'executedAt': '2026-01-02T03:04:05Z',
};

Map<String, dynamic> _positionJson({
  String symbolName = 'TEST',
  num netUnit = 1,
}) => {
  'symbolName': symbolName,
  'price': 100,
  'pricePercentage': 1,
  'b_s': 'Buy',
  'netUnit': netUnit,
  'avgPrice': 100,
  'netPnl': 0,
};

Map<String, dynamic> _historyJson({
  String symbolName = 'TEST',
  String status = 'filled',
}) => {
  'orderId': 'order-1',
  'symbolName': symbolName,
  'BS': 'buy',
  'status': status,
  'filledQuantity': 1,
  'amount': 100,
  'price': 100,
  'realizedPnl': 0,
  'stopLoss': null,
  'takeProfit': null,
  'updatedAt': '2026-01-02T03:04:05Z',
};
