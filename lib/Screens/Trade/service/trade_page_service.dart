import 'package:flutter/material.dart';
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/model/trade_position_model.dart';
import 'package:century_cqg/Screens/Trade/service/trade_account_scoped_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_repository.dart';
import 'package:century_cqg/Screens/Trade/service/trade_use_cases.dart';

class TradePageService extends TradeAccountScopedService {
  TradePageService({
    TradeUseCases? useCases,
    String? Function()? accountIdProvider,
  }) : _useCases = useCases ?? TradeUseCases(TradeRepository()),
       super(accountIdProvider: accountIdProvider);

  final TradeUseCases _useCases;

  int _selectedTabIndex = 0;
  final List<String> _tabs = const [
    'Positions',
    'Orders',
    'Holdings',
    'History',
  ];
  List<TradePosition> _positions = [];
  List<TradePosition> _positionDetails = [];
  List<NetPositionDetail> _netPositionDetails = [];
  TradePositionSummary? _positionSummary;
  bool _isLoadingPositions = false;
  bool _isLoadingPositionDetails = false;
  String? _positionsError;
  String? _positionDetailsError;
  String? _deletePositionError;
  int _positionsRequestId = 0;
  int _positionDetailsRequestId = 0;

  int get selectedTabIndex => _selectedTabIndex;
  List<String> get tabs => _tabs;
  List<TradePosition> get positions {
    synchronizeAccountScope();
    return List.unmodifiable(_positions);
  }

  List<TradePosition> get positionDetails {
    synchronizeAccountScope();
    return List.unmodifiable(_positionDetails);
  }

  List<NetPositionDetail> get netPositionDetails {
    synchronizeAccountScope();
    return List.unmodifiable(_netPositionDetails);
  }

  TradePositionSummary? get positionSummary {
    synchronizeAccountScope();
    return _positionSummary;
  }
  bool get isLoadingPositions {
    synchronizeAccountScope();
    return _isLoadingPositions;
  }

  bool get isLoadingPositionDetails {
    synchronizeAccountScope();
    return _isLoadingPositionDetails;
  }

  String? get positionsError {
    synchronizeAccountScope();
    return _positionsError;
  }

  String? get positionDetailsError {
    synchronizeAccountScope();
    return _positionDetailsError;
  }

  String? get deletePositionError {
    synchronizeAccountScope();
    return _deletePositionError;
  }

  void setSelectedTabIndex(int index) {
    final boundedIndex = index.clamp(0, _tabs.length - 1);
    if (_selectedTabIndex == boundedIndex) {
      return;
    }
    _selectedTabIndex = boundedIndex;
    notifyListeners();
  }

  Future<void> fetchPositions(
    BuildContext context, {
    String data = 'All',
  }) => refreshPositions(data: data);

  Future<void> refreshPositions({String data = 'All'}) async {
    final accountId = synchronizeAccountScope();
    if (accountId == null) {
      _positionsError = 'A trade account ID is required.';
      notifyListeners();
      return;
    }
    if (_isLoadingPositions) return;

    final requestId = ++_positionsRequestId;
    _isLoadingPositions = true;
    _positionsError = null;
    notifyListeners();

    try {
      final positions = await _useCases.fetchPositions(data: data);
      if (requestId != _positionsRequestId ||
          !isCurrentAccount(accountId)) {
        return;
      }
      _positions = positions;
    } on Exception catch (error) {
      if (isCurrentAccount(accountId)) {
        _positionsError = 'Unable to load trade positions: $error';
      }
    } finally {
      if (requestId == _positionsRequestId &&
          isCurrentAccount(accountId)) {
        _isLoadingPositions = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchPositionDetails(
    BuildContext context, {
    required String symbolName,
  }) => refreshPositionDetails(symbolName: symbolName);

  Future<void> refreshPositionDetails({required String symbolName}) async {
    final accountId = synchronizeAccountScope();
    if (accountId == null) {
      _positionDetailsError = 'A trade account ID is required.';
      notifyListeners();
      return;
    }
    final requestId = ++_positionDetailsRequestId;
    _isLoadingPositionDetails = true;
    _positionDetailsError = null;
    _positionDetails = [];
    _netPositionDetails = [];
    _positionSummary = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        _useCases.fetchPositions(data: symbolName),
        _useCases.fetchNetPositionDetails(symbolName),
        _useCases.fetchPositionDetails(symbolName),
      ]);
      if (requestId != _positionDetailsRequestId ||
          !isCurrentAccount(accountId)) {
        return;
      }

      _positionDetails = results[0] as List<TradePosition>;
      _netPositionDetails = results[1] as List<NetPositionDetail>;
      _positionSummary = results[2] as TradePositionSummary;
    } on Exception catch (error) {
      if (isCurrentAccount(accountId)) {
        _positionDetailsError =
            'Unable to load positions for $symbolName: $error';
      }
    } finally {
      if (requestId == _positionDetailsRequestId &&
          isCurrentAccount(accountId)) {
        _isLoadingPositionDetails = false;
        notifyListeners();
      }
    }
  }

  Future<bool> deletePosition(BuildContext context, String symbolName) async {
    final accountId = synchronizeAccountScope();
    if (accountId == null) {
      _deletePositionError = 'A trade account ID is required.';
      notifyListeners();
      return false;
    }
    _deletePositionError = null;
    var deleted = false;

    try {
      await _useCases.deletePosition(symbolName);
      deleted = isCurrentAccount(accountId);
      if (deleted) {
        await refreshPositions();
        if (_positionSummary?.symbolName == symbolName) {
          _positionDetails = [];
          _netPositionDetails = [];
          _positionSummary = null;
          _positionDetailsError = null;
        }
      }
    } on Exception catch (error) {
      if (isCurrentAccount(accountId)) {
        _deletePositionError = 'Unable to delete trade position: $error';
      }
    } finally {
      if (isCurrentAccount(accountId)) notifyListeners();
    }

    return deleted;
  }

  void removePositionBySymbol(String symbolName) {
    synchronizeAccountScope();
    final initialLength = _positions.length;
    _positions.removeWhere((position) => position.symbolName == symbolName);
    if (_positions.length != initialLength) {
      notifyListeners();
    }
  }

  @override
  void clearAccountState() {
    _positionsRequestId++;
    _positionDetailsRequestId++;
    _positions = [];
    _positionDetails = [];
    _netPositionDetails = [];
    _positionSummary = null;
    _isLoadingPositions = false;
    _isLoadingPositionDetails = false;
    _positionsError = null;
    _positionDetailsError = null;
    _deletePositionError = null;
  }
}
