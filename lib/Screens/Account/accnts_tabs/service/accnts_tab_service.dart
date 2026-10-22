import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:century_cqg/Screens/Account/model/account_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_model.dart';
import 'package:century_cqg/Screens/Dashboard/model/top_view_stocks.dart';

class AccntsTabService extends ChangeNotifier {
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

  DateTime get focusedDay => _focusedDay;

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

  int _selectedTime = 5;
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

    final seed = day.year * 10000 + day.month * 100 + day.day;
    switch (seed % 3) {
      case 0:
        return TradeDayStatus.win;
      case 1:
        return TradeDayStatus.loss;
      default:
        return TradeDayStatus.none;
    }
  }

  List<AnalysisMetric> getMetrics() {
    return const [
      AnalysisMetric(label: 'Winning Trades', value: '24'),
      AnalysisMetric(label: 'Losing Trades', value: '11'),
      AnalysisMetric(label: 'Win Rate', value: '68%'),
    ];
  }

  List<SummaryCardData> getSummaryCards() {
    return const [
      SummaryCardData(
        label: 'WINS',
        value: '14',
        valueColor: Color(0xFF0AA66A),
        lightBackground: Color(0xFFEAF8F2),
        darkBackground: Color(0xFF112B22),
      ),
      SummaryCardData(
        label: 'LOSSES',
        value: '5',
        valueColor: Color(0xFFFF4B55),
        lightBackground: Color(0xFFFDEEF1),
        darkBackground: Color(0xFF321A1E),
      ),
      SummaryCardData(
        label: 'NET P&L',
        value: '+6,200',
        valueColor: Color(0xFFC89000),
        lightBackground: Color(0xFFFFF6DE),
        darkBackground: Color(0xFF332A12),
      ),
    ];
  }

  List<StatData> getPerformanceStats() {
    return const [
      StatData(
        label: 'Net Profit',
        value: '6,200.83',
        valueColor: Color(0xFF0AA66A),
      ),
      StatData(label: 'Profit Factor', value: '1.67'),
      StatData(label: 'Max Balance Drawdown', value: '20.92%'),
      StatData(
        label: 'Commission',
        value: '-13.74',
        valueColor: Color(0xFFFF4B55),
      ),
      StatData(label: 'Total Trades', value: '19'),
      StatData(label: 'Average Trade', value: '326.36'),
      StatData(
        label: 'Largest Winning Trade',
        value: '6,551.00',
        valueColor: Color(0xFF0AA66A),
      ),
      StatData(
        label: 'Winning Trades',
        value: '14',
        valueColor: Color(0xFF0AA66A),
      ),
      StatData(
        label: 'Losing Trades',
        value: '5',
        valueColor: Color(0xFFFF4B55),
      ),
      StatData(
        label: 'Largest Losing Trade',
        value: '-3,576.00',
        valueColor: Color(0xFFFF4B55),
      ),
      StatData(label: 'Total Pips Won', value: '893.18'),
      StatData(label: 'Avg. Pips Won per Trade', value: '47.01'),
      StatData(label: 'Avg. Trade Duration', value: '2h 6m 45s'),
      StatData(label: 'USD Volume Traded', value: '16m'),
    ];
  }

  List<PerformancePoint> getPerformanceChartData() {
    return const [
      PerformancePoint(day: 'Mon', winningTrades: 5, losingTrades: 5),
      PerformancePoint(day: 'Tue', winningTrades: 7, losingTrades: 7),
      PerformancePoint(day: 'Wed', winningTrades: 16, losingTrades: 16),
      PerformancePoint(day: 'Thu', winningTrades: 7, losingTrades: 7),
      PerformancePoint(day: 'Fri', winningTrades: 5, losingTrades: 5),
    ];
  }
}
