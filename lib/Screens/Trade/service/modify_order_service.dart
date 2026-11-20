import 'package:flutter/material.dart';

import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/model/trade_symbol_details_model.dart';
import 'package:century_cqg/Screens/Trade/service/trade_repository.dart';
import 'package:century_cqg/Screens/Trade/service/trade_use_cases.dart';

class ModifyOrderService extends ChangeNotifier {
  ModifyOrderService({TradeUseCases? useCases})
    : _useCases = useCases ?? TradeUseCases(TradeRepository());

  final TradeUseCases _useCases;
  int? _units;
  String? _selectedOrderType;
  String _selectedPeriod = '1D';
  TradeSymbolDetails? _symbolDetails;
  bool _isLoadingSymbolDetails = false;
  String? _symbolDetailsError;
  int _symbolDetailsRequestId = 0;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController limitPriceController = TextEditingController();
  final TextEditingController stopPriceController = TextEditingController();
  final TextEditingController stopLossController = TextEditingController();
  final TextEditingController takeProfitController = TextEditingController();

  int? get units => _units;
  String? get selectedOrderType => _selectedOrderType;
  String get selectedPeriod => _selectedPeriod;
  TradeSymbolDetails? get symbolDetails => _symbolDetails;
  bool get isLoadingSymbolDetails => _isLoadingSymbolDetails;
  String? get symbolDetailsError => _symbolDetailsError;

  void resetOrderForm() {
    _units = null;
    _selectedOrderType = null;
    quantityController.clear();
    amountController.clear();
    limitPriceController.clear();
    stopPriceController.clear();
    stopLossController.clear();
    takeProfitController.clear();
    notifyListeners();
  }

  void incrementUnits() {
    setUnits((_units ?? 0) + 1);
  }

  void decrementUnits() {
    if (_units == null || _units! <= 1) return;
    setUnits(_units! - 1);
  }

  void setUnits(int value) {
    _units = value > 0 ? value : null;
    quantityController.text = _units?.toString() ?? '';
    notifyListeners();
  }

  void updateUnits(String value) {
    final parsed = int.tryParse(value);
    _units = parsed != null && parsed > 0 ? parsed : null;
    notifyListeners();
  }

  void setOrderType(String type) {
    _selectedOrderType = type;
    if (type != 'Limit') limitPriceController.clear();
    if (type != 'Stop Entry' && type != 'Stop') stopPriceController.clear();
    notifyListeners();
  }

  Future<void> fetchSymbolDetails({
    required String symbolName,
    String? period,
  }) async {
    if (period != null) _selectedPeriod = period;
    final requestId = ++_symbolDetailsRequestId;
    _symbolDetails = null;
    _symbolDetailsError = null;
    _isLoadingSymbolDetails = true;
    notifyListeners();

    try {
      _symbolDetails = await _useCases.fetchSymbolDetails(
        symbolName,
        period: _selectedPeriod,
      );
    } on Exception catch (error) {
      if (requestId == _symbolDetailsRequestId) {
        _symbolDetailsError = error.toString();
      }
    } finally {
      if (requestId == _symbolDetailsRequestId) {
        _isLoadingSymbolDetails = false;
        notifyListeners();
      }
    }
  }

  TradeOrderRequest buildOrderRequest({
    required String symbolName,
    required String side,
  }) {
    final normalizedSymbol = symbolName.trim();
    if (normalizedSymbol.isEmpty) {
      throw const FormatException('Select a symbol before placing an order.');
    }
    final normalizedSide = side.toLowerCase();
    if (normalizedSide != 'buy' && normalizedSide != 'sell') {
      throw const FormatException('The selected trade side is invalid.');
    }
    final quantity = _units;
    if (quantity == null || quantity <= 0) {
      throw const FormatException('Enter a quantity greater than zero.');
    }

    final orderType = switch (_selectedOrderType?.toLowerCase()) {
      'market' => 'market',
      'limit' => 'limit',
      'stop' || 'stop entry' => 'stop',
      _ => throw const FormatException('Select an order type.'),
    };

    final limitPrice = _parseOptionalPositive(limitPriceController.text);
    final stopPrice = _parseOptionalPositive(stopPriceController.text);
    final stopLoss = _parseOptionalPositive(stopLossController.text);
    final takeProfit = _parseOptionalPositive(takeProfitController.text);
    if (orderType == 'limit' && limitPrice == null) {
      throw const FormatException('Enter a limit price.');
    }
    if (orderType == 'stop' && stopPrice == null) {
      throw const FormatException('Enter a stop price.');
    }
    if (orderType != 'limit' && limitPrice != null) {
      throw const FormatException(
        'Limit price is only valid for a limit order.',
      );
    }
    if (orderType != 'stop' && stopPrice != null) {
      throw const FormatException('Stop price is only valid for a stop order.');
    }

    final enteredAmount = _parseOptionalPositive(amountController.text);
    final referencePrice =
        orderType == 'limit'
            ? limitPrice
            : orderType == 'stop'
            ? stopPrice
            : _symbolDetails?.price;
    final amount =
        enteredAmount ??
        (referencePrice == null ? null : referencePrice * quantity);
    if (amount == null || amount <= 0) {
      throw const FormatException(
        'Enter a positive amount or wait for the market price to load.',
      );
    }

    return TradeOrderRequest(
      symbolName: normalizedSymbol,
      side: normalizedSide,
      quantity: quantity,
      orderType: orderType,
      amount: amount,
      limitPrice: limitPrice,
      stopPrice: stopPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );
  }

  double? _parseOptionalPositive(String value) {
    final normalized = value.replaceAll(',', '').replaceAll('\$', '').trim();
    if (normalized.isEmpty) return null;
    final parsed = double.tryParse(normalized);
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      throw const FormatException('Enter a valid positive number.');
    }
    return parsed;
  }

  @override
  void dispose() {
    amountController.dispose();
    quantityController.dispose();
    limitPriceController.dispose();
    stopPriceController.dispose();
    stopLossController.dispose();
    takeProfitController.dispose();
    super.dispose();
  }
}
