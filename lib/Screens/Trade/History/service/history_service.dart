import 'package:flutter/material.dart';

import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/service/trade_account_scoped_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_repository.dart';
import 'package:century_cqg/Screens/Trade/service/trade_use_cases.dart';

class HistoryService extends TradeAccountScopedService {
  HistoryService({
    TradeUseCases? useCases,
    String? Function()? accountIdProvider,
  }) : _useCases = useCases ?? TradeUseCases(TradeRepository()),
       super(accountIdProvider: accountIdProvider);

  final TradeUseCases _useCases;
  int _selectedTabIndex = 1;
  List<TradeHistoryItem> _history = [];
  bool _isLoading = false;
  String? _error;

  List<TradeHistoryItem> get history {
    synchronizeAccountScope();
    return List.unmodifiable(_history);
  }
  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading {
    synchronizeAccountScope();
    return _isLoading;
  }

  String? get error {
    synchronizeAccountScope();
    return _error;
  }

  Future<void> fetchHistory() async {
    final accountId = synchronizeAccountScope();
    if (accountId == null) {
      _error = 'A trade account ID is required.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final history = await _useCases.fetchHistory();
      if (isCurrentAccount(accountId)) _history = history;
    } on Exception catch (error) {
      if (isCurrentAccount(accountId)) _error = error.toString();
    } finally {
      if (isCurrentAccount(accountId)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setSelectedTabIndex(int index) {
    final boundedIndex = index.clamp(0, 1);
    if (_selectedTabIndex == boundedIndex) return;
    _selectedTabIndex = boundedIndex;
    notifyListeners();
  }

  @override
  void clearAccountState() {
    _history = [];
    _isLoading = false;
    _error = null;
  }
}
