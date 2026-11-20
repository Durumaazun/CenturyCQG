import 'package:flutter/material.dart';

import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/service/trade_account_scoped_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_repository.dart';
import 'package:century_cqg/Screens/Trade/service/trade_use_cases.dart';

class ExecutionService extends TradeAccountScopedService {
  ExecutionService({
    TradeUseCases? useCases,
    String? Function()? accountIdProvider,
  }) : _useCases = useCases ?? TradeUseCases(TradeRepository()),
       super(accountIdProvider: accountIdProvider);

  final TradeUseCases _useCases;
  List<TradeExecution> _executions = [];
  bool _isLoading = false;
  String? _error;

  List<TradeExecution> get executions {
    synchronizeAccountScope();
    return List.unmodifiable(_executions);
  }
  bool get isLoading {
    synchronizeAccountScope();
    return _isLoading;
  }

  String? get error {
    synchronizeAccountScope();
    return _error;
  }

  Future<void> fetchExecutions() async {
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
      final executions = await _useCases.fetchExecutions();
      if (isCurrentAccount(accountId)) _executions = executions;
    } on Exception catch (error) {
      if (isCurrentAccount(accountId)) _error = error.toString();
    } finally {
      if (isCurrentAccount(accountId)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void clearAccountState() {
    _executions = [];
    _isLoading = false;
    _error = null;
  }
}
