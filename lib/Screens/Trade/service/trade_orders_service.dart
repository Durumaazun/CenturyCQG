import 'package:flutter/material.dart';
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/service/trade_account_scoped_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_use_cases.dart';

class TradeOrdersService extends TradeAccountScopedService {
  TradeOrdersService({
    required TradeUseCases useCases,
    VoidCallback? onOrderCompleted,
    VoidCallback? onOrderUpdated,
    Future<void> Function(TradeFillResult result)? onFillApplied,
    String? Function()? accountIdProvider,
  }) : _useCases = useCases,
       _onOrderCompleted = onOrderCompleted,
       _onOrderUpdated = onOrderUpdated,
       _onFillApplied = onFillApplied,
       super(accountIdProvider: accountIdProvider);

  final TradeUseCases _useCases;
  final VoidCallback? _onOrderCompleted;
  final VoidCallback? _onOrderUpdated;
  final Future<void> Function(TradeFillResult result)? _onFillApplied;
  List<TradeOrder> _orders = [];
  final Set<String> _cancelingOrderIds = {};
  final Set<String> _fillingOrderKeys = {};
  final Map<String, TradeFillRequest> _retryableFills = {};
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String? _submitError;
  String? _cancelError;
  String? _fillError;
  int _requestId = 0;
  bool _disposed = false;

  List<TradeOrder> get orders {
    synchronizeAccountScope();
    return List.unmodifiable(_orders);
  }

  bool get isLoading {
    synchronizeAccountScope();
    return _isLoading;
  }

  bool get isSubmitting {
    synchronizeAccountScope();
    return _isSubmitting;
  }
  String? get error {
    synchronizeAccountScope();
    return _error;
  }

  String? get submitError {
    synchronizeAccountScope();
    return _submitError;
  }

  String? get cancelError {
    synchronizeAccountScope();
    return _cancelError;
  }

  String? get fillError {
    synchronizeAccountScope();
    return _fillError;
  }

  bool isCanceling(String orderId) {
    synchronizeAccountScope();
    return _cancelingOrderIds.contains(orderId);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchOrders() async {
    if (_disposed) return;
    final accountId = synchronizeAccountScope();
    if (accountId == null) {
      _error = 'A trade account ID is required.';
      _notifyListeners();
      return;
    }
    final requestId = ++_requestId;
    _isLoading = true;
    _error = null;
    _notifyListeners();
    try {
      final orders = await _useCases.fetchOrders();
      if (requestId == _requestId &&
          !_disposed &&
          isCurrentAccount(accountId)) {
        _orders = orders;
      }
    } on Exception catch (error) {
      if (requestId == _requestId &&
          !_disposed &&
          isCurrentAccount(accountId)) {
        _error = _message(error);
      }
    } finally {
      if (requestId == _requestId &&
          !_disposed &&
          isCurrentAccount(accountId)) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  Future<TradeOrder?> submitOrder(TradeOrderRequest request) async {
    if (_disposed || _isSubmitting) return null;
    final accountId = synchronizeAccountScope();
    if (accountId == null) {
      _submitError = 'A trade account ID is required.';
      _notifyListeners();
      return null;
    }
    _isSubmitting = true;
    _submitError = null;
    _notifyListeners();
    try {
      final order = await _useCases.submitOrder(request);
      if (_disposed || !isCurrentAccount(accountId)) return order;
      _upsertOrder(order);
      _onOrderUpdated?.call();
      if (_isCompleted(order.status, order.completionReported)) {
        _onOrderCompleted?.call();
      }
      await fetchOrders();
      return order;
    } on Exception catch (error) {
      if (!_disposed && isCurrentAccount(accountId)) {
        _submitError = _message(error);
      }
      return null;
    } finally {
      if (isCurrentAccount(accountId)) {
        _isSubmitting = false;
        _notifyListeners();
      }
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    if (_disposed) return false;
    final accountId = synchronizeAccountScope();
    if (accountId == null) {
      _cancelError = 'A trade account ID is required.';
      _notifyListeners();
      return false;
    }
    if (!_cancelingOrderIds.add(orderId)) return false;
    _cancelError = null;
    _notifyListeners();
    try {
      final order = await _useCases.cancelOrder(orderId);
      if (_disposed || !isCurrentAccount(accountId)) return true;
      _upsertOrder(order);
      _onOrderUpdated?.call();
      return true;
    } on Exception catch (error) {
      if (!_disposed && isCurrentAccount(accountId)) {
        _cancelError = _message(error);
      }
      return false;
    } finally {
      _cancelingOrderIds.remove(orderId);
      if (isCurrentAccount(accountId)) _notifyListeners();
    }
  }

  Future<TradeFillResult?> fillOrder({
    required String orderId,
    required num filledUnits,
    required double fillPrice,
  }) async {
    final accountId = synchronizeAccountScope();
    if (accountId == null) {
      _fillError = 'A trade account ID is required.';
      _notifyListeners();
      return null;
    }
    final key = '$accountId:$orderId';
    final previousRequest = _retryableFills[key];
    if (previousRequest != null &&
        (previousRequest.filledUnits != filledUnits ||
            previousRequest.fillPrice != fillPrice)) {
      _fillError =
          'Retry the pending fill with the same quantity and fill price.';
      _notifyListeners();
      return null;
    }
    final request =
        previousRequest ??
        TradeFillRequest.create(
          orderId: orderId,
          filledUnits: filledUnits,
          fillPrice: fillPrice,
        );
    return _performFill(request, accountId, key);
  }

  Future<TradeFillResult> applyFillForTesting(TradeFillRequest request) async {
    synchronizeAccountScope();
    final accountId = currentAccountId;
    if (accountId == null) {
      throw StateError('A trade account ID is required.');
    }
    final key = '$accountId:${request.orderId}';
    final previousRequest = _retryableFills[key];
    if (previousRequest != null &&
        (previousRequest.fillId != request.fillId ||
            previousRequest.filledUnits != request.filledUnits ||
            previousRequest.fillPrice != request.fillPrice)) {
      throw StateError(
        'Retry the pending fill with the same fill ID, quantity, and price.',
      );
    }
    final result = await _performFill(request, accountId, key);
    if (result == null) {
      throw StateError(_fillError ?? 'Unable to apply trade fill.');
    }
    return result;
  }

  Future<TradeFillResult?> _performFill(
    TradeFillRequest request,
    String accountId,
    String key,
  ) async {
    if (_disposed || !_fillingOrderKeys.add(key)) return null;
    _retryableFills[key] = request;
    _fillError = null;
    _notifyListeners();

    TradeFillResult result;
    try {
      result = await _useCases.applyFill(request);
    } on Exception catch (error) {
      if (!_disposed && isCurrentAccount(accountId)) {
        _fillError = _message(error);
        _notifyListeners();
      }
      return null;
    } finally {
      _fillingOrderKeys.remove(key);
    }

    if (_disposed || !isCurrentAccount(accountId)) return result;
    _retryableFills.remove(key);
    await fetchOrders();
    if (_onFillApplied != null) {
      await _onFillApplied(result);
    } else {
      _onOrderUpdated?.call();
      if (_isCompleted(result.status, result.completionReported)) {
        _onOrderCompleted?.call();
      }
    }
    _notifyListeners();
    return result;
  }

  bool _isCompleted(String status, bool completionReported) =>
      completionReported || status.toLowerCase() == 'filled';

  void _upsertOrder(TradeOrder order) {
    if (_disposed) return;
    final index = _orders.indexWhere((item) => item.orderId == order.orderId);
    if (index == -1) {
      _orders = [order, ..._orders];
    } else {
      final updated = List<TradeOrder>.of(_orders);
      updated[index] = order;
      _orders = updated;
    }
    _notifyListeners();
  }

  @override
  void clearAccountState() {
    _requestId++;
    _orders = [];
    _cancelingOrderIds.clear();
    _fillingOrderKeys.clear();
    _retryableFills.clear();
    _isLoading = false;
    _isSubmitting = false;
    _error = null;
    _submitError = null;
    _cancelError = null;
    _fillError = null;
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  String _message(Object error) => error.toString();
}
