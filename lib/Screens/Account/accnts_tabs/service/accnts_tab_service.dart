import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:century_cqg/Network/network_manager.dart';
import 'package:century_cqg/Screens/Account/model/account_model.dart';
import 'package:century_cqg/Screens/Account/service/account_overview_repository.dart';
import 'package:century_cqg/Screens/Dashboard/model/top_view_stocks.dart';

class AccntsTabService extends ChangeNotifier {
  AccntsTabService({
    AccountOverviewRepository? overviewRepository,
  }) : _overviewRepository = overviewRepository ?? AccountOverviewRepository();

  final AccountOverviewRepository _overviewRepository;

  // ---------------------------------------------------------------------------
  // Overview Tab Data & Logic
  // ---------------------------------------------------------------------------

  Object? _accountOverview;
  Object? get accountOverview => _accountOverview;

  Object? _accountAllocation;
  Object? get accountAllocation => _accountAllocation;

  String? _accountOverviewError;
  String? get accountOverviewError => _accountOverviewError;

  String? _accountAllocationError;
  String? get accountAllocationError => _accountAllocationError;

  Future<void> loadAccountOverview(BuildContext context) async {
    await Future.wait<void>([
      fetchAccountOverview(context),
      fetchAccountAllocation(context),
    ]);
  }

  Future<void> fetchAccountOverview(BuildContext context) async {
    final response = await _overviewRepository.fetchOverview(context);
    if (response is NetworkResponse) {
      _accountOverviewError =
          'Unable to load account overview (${response.statusCode}).';
    } else if (response == null) {
      _accountOverviewError = 'No account overview response was received.';
    } else {
      _accountOverview = response;
      _accountOverviewError = null;
    }
    notifyListeners();
  }

  Future<void> fetchAccountAllocation(BuildContext context) async {
    final response = await _overviewRepository.fetchAllocation(context);
    if (response is NetworkResponse) {
      _accountAllocationError =
          'Unable to load account allocation (${response.statusCode}).';
    } else if (response == null) {
      _accountAllocationError = 'No account allocation response was received.';
    } else {
      _accountAllocation = response;
      _accountAllocationError = null;
    }
    notifyListeners();
  }

  final List<StockPosition> positions = [
    StockPosition(
      ticker: 'AAPL',
      type: 'BUY',
      qty: 1000,
      profit: 3000.00,
      avgPrice: 0.0,
      ltp: 0000.00,
    ),
    StockPosition(
      ticker: 'TSLA',
      type: 'BUY',
      qty: 100,
      profit: 3000.00,
      avgPrice: 00000.0,
      ltp: 0000.0,
    ),
    StockPosition(
      ticker: 'NVDA',
      type: 'BUY',
      qty: 100,
      profit: 3000.00,
      avgPrice: 0.0,
      ltp: 0000.0,
    ),
  ];

  final List<AccountAllocationItem> allocations = const [
    AccountAllocationItem(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      changePercent: 15.41,
      allocationPercent: 42,
      amountInMillions: 28.4,
      color: Color(0xFF35B67A),
    ),
    AccountAllocationItem(
      symbol: 'US100',
      name: 'S&P 100',
      changePercent: -8.20,
      allocationPercent: 33,
      amountInMillions: 15.6,
      color: Color(0xFFF24861),
    ),
    AccountAllocationItem(
      symbol: 'US500',
      name: 'S&P 500',
      changePercent: 12.88,
      allocationPercent: 18,
      amountInMillions: 12.2,
      color: Color(0xFF6B5CF5),
    ),
    AccountAllocationItem(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      changePercent: -2.10,
      allocationPercent: 7,
      amountInMillions: 4.7,
      color: Color(0xFF7B8291),
    ),
  ];

  String get allocationTotalValue => '\$67,700,000';

  static const List<String> portfolioPeriods = ['1D', '1W', '1M', '3M', '1Y'];

  static const List<FlSpot> portfolioChartSpots = [
    FlSpot(0, 39),
    FlSpot(1, 45),
    FlSpot(2, 43),
    FlSpot(3, 49),
    FlSpot(4, 47),
    FlSpot(5, 52),
    FlSpot(6, 50),
  ];

}
