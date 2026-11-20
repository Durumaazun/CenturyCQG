import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/model/trade_position_model.dart';
import 'package:century_cqg/Screens/Trade/model/trade_symbol_details_model.dart';
import 'package:century_cqg/Screens/Trade/service/trade_repository.dart';

class TradeUseCases {
  const TradeUseCases(this._repository);

  final TradeRepository _repository;
  String? get currentAccountId => _repository.currentAccountId;

  Future<TradeSymbolDetails> fetchSymbolDetails(
    String symbolName, {
    String period = '1D',
  }) => _repository.fetchSymbolDetails(symbolName, period: period);

  Future<List<NetPositionDetail>> fetchNetPositionDetails(String symbolName) =>
      _repository.fetchNetPositionDetails(symbolName);

  Future<TradePositionSummary> fetchPositionDetails(String symbolName) =>
      _repository.fetchPositionDetails(symbolName);

  Future<TradeOrder> submitOrder(TradeOrderRequest request) =>
      _repository.submitOrder(request);

  Future<List<TradeOrder>> fetchOrders() => _repository.fetchOrders();

  Future<TradeFillResult> applyFill(TradeFillRequest request) =>
      _repository.applyFill(request);

  Future<TradeOrder> cancelOrder(String orderId) =>
      _repository.cancelOrder(orderId);

  Future<List<TradeExecution>> fetchExecutions() =>
      _repository.fetchExecutions();

  Future<List<TradePosition>> fetchPositions({String data = 'All'}) =>
      _repository.fetchPositions(data: data);

  Future<void> deletePosition(String symbolName) =>
      _repository.deletePosition(symbolName);

  Future<List<TradeHistoryItem>> fetchHistory() => _repository.fetchHistory();
}
