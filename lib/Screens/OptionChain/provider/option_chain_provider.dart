import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OptionChainState {
  final String selectedExpirationDate;
  final String selectedType;
  final bool showCalls;
  final bool showPuts;
  final int? selectedRowIndex;
  final Set<int> basketRows;
  final bool basketEnabled;
  final Map<String, dynamic> filterValues;
  final String sortBy;
  final bool sortAscending;
  final Map<int, int> quantities;
  final double requiredMargin;
  final double accountBalance;
  final bool showSpotPrice;

  OptionChainState({
    this.selectedExpirationDate = 'JUN 20',
    this.selectedType = 'call',
    this.showCalls = true,
    this.showPuts = true,
    this.selectedRowIndex,
    Set<int>? basketRows,
    this.basketEnabled = false,
    Map<String, dynamic>? filterValues,
    this.sortBy = 'strikePrice',
    this.sortAscending = true,
    Map<int, int>? quantities,
    this.requiredMargin = 5000.0,
    this.accountBalance = 50000.0,
    this.showSpotPrice = true,
  }) : basketRows = basketRows ?? {},
       filterValues =
           filterValues ??
           {'delta': null, 'oi': null, 'ltp': null, 'searchStrike': null},
       quantities = quantities ?? {};

  OptionChainState copyWith({
    String? selectedExpirationDate,
    String? selectedType,
    bool? showCalls,
    bool? showPuts,
    int? selectedRowIndex,
    Set<int>? basketRows,
    bool? basketEnabled,
    Map<String, dynamic>? filterValues,
    String? sortBy,
    bool? sortAscending,
    Map<int, int>? quantities,
    bool? showSpotPrice,
    double? requiredMargin,
    double? accountBalance,
  }) {
    return OptionChainState(
      selectedExpirationDate:
          selectedExpirationDate ?? this.selectedExpirationDate,
      selectedType: selectedType ?? this.selectedType,
      showCalls: showCalls ?? this.showCalls,
      showPuts: showPuts ?? this.showPuts,
      selectedRowIndex: selectedRowIndex ?? this.selectedRowIndex,
      basketRows: basketRows ?? this.basketRows,
      basketEnabled: basketEnabled ?? this.basketEnabled,
      filterValues: filterValues ?? this.filterValues,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      quantities: quantities ?? this.quantities,
      requiredMargin: requiredMargin ?? this.requiredMargin,
      accountBalance: accountBalance ?? this.accountBalance,
      showSpotPrice: showSpotPrice ?? this.showSpotPrice,
    );
  }
}

class OptionChainNotifier extends ChangeNotifier {
  OptionChainState _state = OptionChainState();

  OptionChainState get state => _state;

  void setBasketEnabled(bool enabled) {
    if (!enabled) {
      _state = _state.copyWith(
        basketEnabled: enabled,
        basketRows: {},
        selectedRowIndex: null,
      );
    } else {
      _state = _state.copyWith(basketEnabled: enabled, selectedRowIndex: null);
    }
    notifyListeners();
  }

  void setSelectedExpirationDate(String date) {
    _state = _state.copyWith(
      selectedExpirationDate: date,
      selectedRowIndex: null,
    );
    notifyListeners();
  }

  void clearSelection() {
    if (_state.selectedRowIndex != null) {
      _state = _state.copyWith(selectedRowIndex: null);
      notifyListeners();
    }
  }

  void setSelectedRowIndex(int? index) {
    _state = _state.copyWith(selectedRowIndex: index);
    notifyListeners();
  }

  void setSelectedRowAndType(int? index, String type) {
    _state = _state.copyWith(selectedRowIndex: index, selectedType: type);
    notifyListeners();
  }

  void setSelectedType(String type) {
    _state = _state.copyWith(selectedType: type);
    notifyListeners();
  }

  void addBasketRow(int index) {
    final updatedBasketRows = {..._state.basketRows};
    updatedBasketRows.add(index);
    _state = _state.copyWith(basketRows: updatedBasketRows);
    notifyListeners();
  }

  void removeBasketRow(int index) {
    final updatedBasketRows = {..._state.basketRows};
    updatedBasketRows.remove(index);
    _state = _state.copyWith(basketRows: updatedBasketRows);
    notifyListeners();
  }

  void updateOnRowSelect(int index, bool selected) {
    if (selected && !_state.basketRows.contains(index)) {
      final updatedBasketRows = {..._state.basketRows};
      updatedBasketRows.add(index);
      _state = _state.copyWith(
        basketRows: updatedBasketRows,
        selectedRowIndex: index,
      );
    } else if (!selected) {
      final updatedBasketRows = {..._state.basketRows};
      updatedBasketRows.remove(index);
      _state = _state.copyWith(
        basketRows: updatedBasketRows,
        selectedRowIndex: null,
      );
    }
    notifyListeners();
  }

  void clearBasketRows() {
    _state = _state.copyWith(basketRows: {});
    notifyListeners();
  }

  // Filtering
  void setFilterValue(String filterKey, dynamic value) {
    final updatedFilters = {..._state.filterValues};
    updatedFilters[filterKey] = value;
    _state = _state.copyWith(filterValues: updatedFilters);
    notifyListeners();
  }

  void clearFilters() {
    _state = _state.copyWith(
      filterValues: {
        'delta': null,
        'oi': null,
        'ltp': null,
        'searchStrike': null,
      },
    );
    notifyListeners();
  }

  // Sorting
  void setSortBy(String sortBy) {
    _state = _state.copyWith(
      sortBy: sortBy,
      sortAscending: sortBy == _state.sortBy ? !_state.sortAscending : true,
    );
    notifyListeners();
  }

  // Quantity Managementv
  void setQuantity(int index, int quantity) {
    final updatedQuantities = {..._state.quantities};
    if (quantity > 0) {
      updatedQuantities[index] = quantity;
    } else {
      updatedQuantities.remove(index);
    }
    _state = _state.copyWith(quantities: updatedQuantities);
    notifyListeners();
  }

  // Trading Calculations
  Map<String, double> calculateTradingMetrics(
    List<Map<String, dynamic>> selectedRows,
  ) {
    double maxProfit = 0;
    double maxLoss = 0;
    double probability = 0;
    double totalMargin = _state.requiredMargin;
    double balance = _state.accountBalance - totalMargin;

    for (var row in selectedRows) {
      final callLTP = (row['callLTP'] as num).toDouble();
      final putLTP = (row['putLTP'] as num).toDouble();

      // Simple calculation - in production, use Black-Scholes
      maxProfit += callLTP + putLTP;
      maxLoss += 0;
      probability += 0.5; // Placeholder
    }

    return {
      'maxProfit': maxProfit,
      'maxLoss': maxLoss,
      'probability': (probability / selectedRows.length) * 100,
      'requiredMargin': totalMargin,
      'balance': balance,
    };
  }

  // Order Submission
  Future<bool> submitOrder(
    String symbol,
    List<int> selectedRows,
    Map<int, int> quantities,
  ) async {
    try {
      _state = _state.copyWith(
        basketRows: {},
        quantities: {},
        selectedRowIndex: null,
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final optionChainNotifierProvider = ChangeNotifierProvider<OptionChainNotifier>(
  create: (ref) => OptionChainNotifier(),
);
