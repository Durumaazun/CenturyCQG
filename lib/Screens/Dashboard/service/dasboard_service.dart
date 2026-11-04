import 'package:flutter/material.dart';
import 'package:century_cqg/Screens/Dashboard/model/dashboard_models.dart';
import 'package:century_cqg/Screens/Dashboard/model/account_summary_response_model.dart';
import 'package:century_cqg/Screens/Dashboard/model/activity_feed_item.dart';
import 'package:century_cqg/Screens/Dashboard/model/market_updates_response_model.dart';
import 'package:century_cqg/Screens/Dashboard/model/stocks_detail_model.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Screens/Dashboard/service/dashboard_repository.dart';
import 'package:century_cqg/Network/network_manager.dart';
import 'package:century_cqg/app_config.dart';

class DashboardService extends ChangeNotifier {
  final _repository = DashboardRepository();

  int _selectedHomeTabIndex = 0;
  bool _isFromDetails = false;
  int _selectedTrendingCategory = 0;

  int get selectedHomeTabIndex => _selectedHomeTabIndex;
  bool get isFromDetails => _isFromDetails;
  int get selectedTrendingCategory => _selectedTrendingCategory;

  void setSelectedHomeTabIndex(int index) {
    if (_selectedHomeTabIndex == index) {
      return;
    }
    _selectedHomeTabIndex = index;
    notifyListeners();
  }

  void setSelectedTrendingCategory(int index) {
    if (_selectedTrendingCategory == index) {
      return;
    }
    _selectedTrendingCategory = index;
    notifyListeners();
  }

  void setIsFromDetails(bool value) {
    _isFromDetails = value;
    notifyListeners();
  }

  AccountSummaryResponseModel _accountSummary =
      const AccountSummaryResponseModel();
  AccountSummaryResponseModel get accountSummary => _accountSummary;

  String? _accountSummaryError;
  String? get accountSummaryError => _accountSummaryError;

  final List<Stock> _watchedStocks = [];
  List<Stock> get watchedStocks => _watchedStocks;

  final List<Position> _topPositions = [];
  List<Position> get topPositions => _topPositions;

  final List<ActivityFeedItem> _activityFeed = [];
  List<ActivityFeedItem> get activityFeed => List.unmodifiable(_activityFeed);

  bool _isActivityFeedLoading = false;
  bool get isActivityFeedLoading => _isActivityFeedLoading;

  String? _activityFeedError;
  String? get activityFeedError => _activityFeedError;

  final List<StockItem> _marketUpdates = [];
  List<StockItem> get marketUpdates => List.unmodifiable(_marketUpdates);

  bool _isMarketUpdatesLoading = false;
  bool get isMarketUpdatesLoading => _isMarketUpdatesLoading;

  String? _marketUpdatesError;
  String? get marketUpdatesError => _marketUpdatesError;

  int _marketUpdatesRequestId = 0;

  void setDarkMode(bool value) {
    if (NerveBase().isDarkMode == value) return;
    NerveBase().isDarkMode = value;
    notifyListeners();
  }

  void toggleDarkMode() {
    setDarkMode(!NerveBase().isDarkMode);
  }

  Future<void> callAccountSummary(BuildContext context) async {
    _accountSummaryError = null;
    final response = await _repository.fetchAccountSummary(context);
    if (response == null) {
      _accountSummaryError = 'No account summary response was received.';
      notifyListeners();
      return;
    }

    if (response is NetworkResponse) {
      _accountSummaryError =
          'Unable to load account summary (${response.statusCode}).';
      notifyListeners();
      return;
    }

    Object? summaryResponse = response;
    if (response is List && response.isNotEmpty) {
      summaryResponse = response.first;
    }

    if (summaryResponse is Map) {
      final parsedResponse = AccountSummaryResponseModel.fromJson(
        Map<String, dynamic>.from(summaryResponse),
      );
      if (parsedResponse.currency.isNotEmpty) {
        _accountSummary = parsedResponse;
      } else {
        _accountSummaryError = 'Account summary response is invalid.';
      }
    } else {
      _accountSummaryError = 'No account summary data was returned.';
    }

    notifyListeners();
  }

  Future<void> callWatchedStocks(BuildContext context) async {
    final response = await _repository.fetchWatchedStocks(context);
    _watchedStocks.clear();
    if ((response != null) && (response is List)) {
      final data = response.map((e) => Stock.fromJson(e)).toList();

      _watchedStocks.addAll(data);
    }

    notifyListeners();
  }

  Future<void> callMarketUpdates(
    BuildContext context, {
    required String category,
  }) async {
    final requestId = ++_marketUpdatesRequestId;
    _isMarketUpdatesLoading = true;
    _marketUpdatesError = null;
    notifyListeners();

    try {
      final response = await _repository.fetchMarketUpdates(
        context,
        category: category,
      );
      if (requestId != _marketUpdatesRequestId) return;

      if (response is NetworkResponse) {
        _marketUpdates.clear();
        _marketUpdatesError =
            'Unable to load market movers (${response.statusCode}).';
        return;
      }

      final responseData =
          response is List
              ? response
              : response is Map && response['data'] is List
              ? response['data'] as List
              : null;
      if (responseData == null) {
        _marketUpdates.clear();
        _marketUpdatesError = 'The market mover response is invalid.';
        return;
      }

      final marketMoverResponse = MarketMoverModel.fromJson({
        'data':
            responseData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList(),
      });
      final List<StockItem> stocks =
          (marketMoverResponse.data ?? [])
              .map((item) => StockItem.fromJson(item.toJson()))
              .toList();

      _marketUpdates
        ..clear()
        ..addAll(stocks);
      _marketUpdatesError = null;
    } on FormatException {
      if (requestId == _marketUpdatesRequestId) {
        _marketUpdates.clear();
        _marketUpdatesError = 'The market mover response is invalid.';
      }
    } finally {
      if (requestId == _marketUpdatesRequestId) {
        _isMarketUpdatesLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> callTopPositions(BuildContext context) async {
    try {
      _topPositions.clear();
      final response = await _repository.fetchTopPositions(context);
      if ((response != null) && (response is List)) {
        final data = response.map((e) => Position.fromJson(e)).toList();

        _topPositions.addAll(data);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Get script exception : $e');
    }
  }

  Future<void> callActivityFeed(BuildContext context) async {
    final accountId = AppConfig().accountId?.trim();
    if (accountId == null || accountId.isEmpty) {
      _activityFeed.clear();
      _activityFeedError = 'Account ID is unavailable. Please sign in again.';
      notifyListeners();
      return;
    }

    _isActivityFeedLoading = true;
    _activityFeedError = null;
    notifyListeners();

    try {
      final response = await _repository.fetchActivityFeed(
        context,
        accountId: accountId,
      );

      if (response is NetworkResponse) {
        _activityFeedError =
            'Unable to load activity feed (${response.statusCode}).';
        _activityFeed.clear();
      } else if (response is List) {
        _activityFeed
          ..clear()
          ..addAll(
            response.whereType<Map>().map(
              (item) =>
                  ActivityFeedItem.fromJson(Map<String, dynamic>.from(item)),
            ),
          );
      } else {
        _activityFeed.clear();
        _activityFeedError = 'The activity feed response is invalid.';
      }
    } finally {
      _isActivityFeedLoading = false;
      notifyListeners();
    }
  }

  void updateTopPositions(List<Position> positions) {
    _topPositions.clear();
    for (var item in positions) {
      _topPositions.add(item);
    }
    notifyListeners();
  }
}
