import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:century_cqg/Network/network_manager.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_request_model.dart';
import 'package:century_cqg/Screens/Account/model/account_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/service/account_analysis_repository.dart';
import 'package:century_cqg/Screens/Dashboard/model/top_view_stocks.dart';
import 'package:century_cqg/app_config.dart';

class AccntsTabService extends ChangeNotifier {
  final _repository = AccountAnalysisRepository();

  // ---------------------------------------------------------------------------
  // Overview Tab Data & Logic
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Analysis Tab Data & Logic
  // ---------------------------------------------------------------------------

  static final DateTime firstCalendarMonth = DateTime(2020, 1, 1);
  static final DateTime lastCalendarMonth = DateTime(2030, 12, 1);
  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, 1);
  AnalysisPerformanceData? _performanceData;
  Map<DateTime, TradeDayStatus> _tradeDays = {};
  bool _isPerformanceLoading = false;
  bool _isCalendarLoading = false;
  String? _performanceError;
  String? _calendarError;
  int _performanceRequestId = 0;
  int _calendarRequestId = 0;

  static const List<String> _periodKeys = [
    'yesterday',
    'last_week',
    'last_month',
    'last_quarter',
    'last_year',
    'custom',
  ];
  static const List<String> _marketImpactKeys = ['all', 'winning', 'losing'];

  DateTime get focusedDay => _focusedDay;
  bool get isPerformanceLoading => _isPerformanceLoading;
  bool get isCalendarLoading => _isCalendarLoading;
  String? get performanceError => _performanceError;
  String? get calendarError => _calendarError;
  String get performancePeriodLabel {
    final data = _performanceData;
    return data == null ? '' : '${data.periodStart} - ${data.periodEnd}';
  }

  Future<void> loadAnalysis(BuildContext context) async {
    await Future.wait<void>([
      fetchPerformance(context),
      fetchCalendar(context),
    ]);
  }

  Future<void> fetchPerformance(
    BuildContext context, {
    String? customRange,
  }) async {
    final requestId = ++_performanceRequestId;
    final accountId = AppConfig().accountId?.trim();
    if (accountId == null || accountId.isEmpty) {
      _performanceError = 'Account ID is unavailable. Please sign in again.';
      _isPerformanceLoading = false;
      notifyListeners();
      return;
    }

    final period = _periodKeys[_selectedTime];
    final normalizedCustomRange = customRange?.trim();
    if (period == 'custom' &&
        (normalizedCustomRange == null ||
            !RegExp(
              r'^\d{4}-\d{2}-\d{2}\.\.\d{4}-\d{2}-\d{2}$',
            ).hasMatch(normalizedCustomRange))) {
      _performanceError = 'Enter a custom range as YYYY-MM-DD..YYYY-MM-DD.';
      _isPerformanceLoading = false;
      notifyListeners();
      return;
    }

    _isPerformanceLoading = true;
    _performanceError = null;
    notifyListeners();

    final response = await _repository.fetchPerformance(
      context,
      request: AccountAnalysisPerformanceRequest(
        accountId: accountId,
        period: period,
        marketImpact: _marketImpactKeys[_selectedMarketImpact],
        customRange: period == 'custom' ? normalizedCustomRange : null,
      ),
    );
    if (requestId != _performanceRequestId) return;

    if (response is NetworkResponse) {
      _performanceError =
          'Unable to load account analysis (${response.statusCode}).';
    } else if (response is! Map) {
      _performanceError = 'The account analysis response is invalid.';
    } else {
      try {
        _performanceData = AnalysisPerformanceData.fromJson(
          Map<String, dynamic>.from(response),
        );
        _performanceError = null;
      } on FormatException catch (exception) {
        _performanceError = exception.message;
      }
    }

    _isPerformanceLoading = false;
    notifyListeners();
  }

  Future<void> fetchCalendar(BuildContext context) async {
    final requestId = ++_calendarRequestId;
    final accountId = AppConfig().accountId?.trim();
    if (accountId == null || accountId.isEmpty) {
      _calendarError = 'Account ID is unavailable. Please sign in again.';
      _isCalendarLoading = false;
      notifyListeners();
      return;
    }

    _isCalendarLoading = true;
    _calendarError = null;
    notifyListeners();

    final response = await _repository.fetchCalendar(
      context,
      request: AccountAnalysisCalendarRequest(
        accountId: accountId,
        year: _focusedDay.year,
        month: _focusedDay.month,
      ),
    );
    if (requestId != _calendarRequestId) return;

    if (response is NetworkResponse) {
      _calendarError =
          'Unable to load the trades calendar (${response.statusCode}).';
    } else if (response is! Map) {
      _calendarError = 'The trades calendar response is invalid.';
    } else {
      try {
        _tradeDays =
            AnalysisCalendarData.fromJson(
              Map<String, dynamic>.from(response),
            ).tradeDays;
        _calendarError = null;
      } on FormatException catch (exception) {
        _calendarError = exception.message;
      }
    }

    _isCalendarLoading = false;
    notifyListeners();
  }

  set focusedDay(DateTime value) {
    _focusedDay = value;
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void previousMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    notifyListeners();
  }

  int _selectedMarketImpact = 0;
  int get selectedMarketImpact => _selectedMarketImpact;
  void setSelectedMarketImpact(int index) {
    _selectedMarketImpact = index;
    notifyListeners();
  }

  int _selectedTime = 4;
  int get selectedTime => _selectedTime;
  void setSelectedTime(int index) {
    _selectedTime = index;
    notifyListeners();
  }

  int _dialogSelectedMonth = DateTime.now().month;
  int get dialogSelectedMonth => _dialogSelectedMonth;
  void setDialogSelectedMonth(int month) {
    _dialogSelectedMonth = month;
    notifyListeners();
  }

  int _dialogSelectedYear = DateTime.now().year;
  int get dialogSelectedYear => _dialogSelectedYear;
  void setDialogSelectedYear(int year) {
    _dialogSelectedYear = year;
    notifyListeners();
  }

  void initDialogMonthYear() {
    _dialogSelectedMonth = _focusedDay.month;
    _dialogSelectedYear = _focusedDay.year;
    notifyListeners();
  }

  void applyDialogMonthYear() {
    _focusedDay = DateTime(_dialogSelectedYear, _dialogSelectedMonth, 1);
    notifyListeners();
  }

  static const List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static const List<String> marketImpactOptions = [
    'All Trades',
    'Winning Trades',
    'Loosing Trades',
  ];

  static const List<String> timeOptions = [
    'Yesterday',
    'Last Week',
    'Last Month',
    'Last Quarter',
    'Last Year',
    'Custom',
  ];

  static const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String monthName(int month) {
    return monthNames[month - 1];
  }

  bool isAfterToday(DateTime day) {
    final today = DateTime.now();
    return day.isAfter(DateTime(today.year, today.month, today.day));
  }

  TradeDayStatus statusForDay(DateTime day) {
    if (isAfterToday(day)) {
      return TradeDayStatus.future;
    }

    return _tradeDays[DateTime(day.year, day.month, day.day)] ??
        TradeDayStatus.none;
  }

  List<AnalysisMetric> getMetrics() {
    return _performanceData?.metrics ?? const [];
  }

  List<SummaryCardData> getSummaryCards() {
    return _performanceData?.summaryCards ?? const [];
  }

  List<StatData> getPerformanceStats() {
    return _performanceData?.stats ?? const [];
  }

  List<PerformancePoint> getPerformanceChartData() {
    return _performanceData?.chartData ?? const [];
  }
}
