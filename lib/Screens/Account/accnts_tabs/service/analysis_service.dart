import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:century_cqg/Network/network_manager.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_day_details_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_request_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/service/account_analysis_repository.dart';
import 'package:century_cqg/Screens/Account/model/account_model.dart';
import 'package:century_cqg/app_config.dart';

class AnalysisService extends ChangeNotifier {
  AnalysisService({AccountAnalysisRepository? repository})
    : _repository = repository ?? AccountAnalysisRepository();

  final AccountAnalysisRepository _repository;

  static final DateTime firstCalendarMonth = DateTime(2020, 1, 1);
  static final DateTime lastCalendarMonth = DateTime(2030, 12, 1);
  static const List<String> _periodKeys = [
    'yesterday',
    'last_week',
    'last_month',
    'last_quarter',
    'last_year',
    'custom',
  ];
  static const List<String> _marketImpactKeys = ['all', 'winning', 'losing'];

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

  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, 1);
  PerformanceStatsResponse? _performanceStats;
  PerformanceChartResponse? _performanceChart;
  Map<DateTime, TradeDayStatus> _tradeDays = {};
  bool _statsLoading = false;
  bool _chartLoading = false;
  bool _isCalendarLoading = false;
  String? _statsError;
  String? _chartError;
  String? _calendarError;
  AnalysisDayDetails? _dayDetails;
  bool _isDayDetailsLoading = false;
  String? _dayDetailsError;
  String? _customRange;
  String? _performanceRequestError;
  int _statsRequestId = 0;
  int _chartRequestId = 0;
  int _calendarRequestId = 0;
  int _dayDetailsRequestId = 0;
  int _selectedMarketImpact = 0;
  int _selectedTime = 4;
  int _dialogSelectedMonth = DateTime.now().month;
  int _dialogSelectedYear = DateTime.now().year;

  DateTime get focusedDay => _focusedDay;
  bool get statsLoading => _statsLoading;
  bool get chartLoading => _chartLoading;
  bool get isCalendarLoading => _isCalendarLoading;
  String? get statsError => _statsError;
  String? get chartError => _chartError;
  String? get calendarError => _calendarError;
  AnalysisDayDetails? get dayDetails => _dayDetails;
  bool get isDayDetailsLoading => _isDayDetailsLoading;
  String? get dayDetailsError => _dayDetailsError;
  String? get customRange => _customRange;
  int get selectedMarketImpact => _selectedMarketImpact;
  int get selectedTime => _selectedTime;
  int get dialogSelectedMonth => _dialogSelectedMonth;
  int get dialogSelectedYear => _dialogSelectedYear;

  String get performancePeriodLabel {
    final data = _performanceStats;
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
    if (customRange != null) _customRange = customRange.trim();
    await Future.wait<void>([
      fetchPerformanceStats(context),
      fetchPerformanceChart(context),
    ]);
  }

  Future<void> fetchPerformanceStats(BuildContext context) async {
    final requestId = ++_statsRequestId;
    _performanceStats = null;
    _statsError = null;
    _statsLoading = true;
    final request = _buildPerformanceRequest();
    if (request == null) {
      _statsError = _performanceRequestError;
      _statsLoading = false;
      notifyListeners();
      return;
    }
    notifyListeners();

    try {
      final response = await _repository.fetchPerformanceStats(
        context,
        request: request,
      );
      if (requestId != _statsRequestId) return;
      if (response is NetworkResponse) {
        _statsError =
            'Unable to load performance stats (${response.statusCode}).';
      } else if (response is! Map) {
        _statsError = 'The performance stats response is invalid.';
      } else {
        _performanceStats = PerformanceStatsResponse.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } on FormatException catch (exception) {
      _statsError = exception.message;
    } catch (_) {
      _statsError = 'Unable to load performance stats.';
    } finally {
      if (requestId == _statsRequestId) {
        _statsLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchPerformanceChart(BuildContext context) async {
    final requestId = ++_chartRequestId;
    _performanceChart = null;
    _chartError = null;
    _chartLoading = true;
    final request = _buildPerformanceRequest();
    if (request == null) {
      _chartError = _performanceRequestError;
      _chartLoading = false;
      notifyListeners();
      return;
    }
    notifyListeners();

    try {
      final response = await _repository.fetchPerformanceChart(
        context,
        request: request,
      );
      if (requestId != _chartRequestId) return;
      if (response is NetworkResponse) {
        _chartError =
            'Unable to load performance chart (${response.statusCode}).';
      } else if (response is! Map) {
        _chartError = 'The performance chart response is invalid.';
      } else {
        _performanceChart = PerformanceChartResponse.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } on FormatException catch (exception) {
      _chartError = exception.message;
    } catch (_) {
      _chartError = 'Unable to load performance chart.';
    } finally {
      if (requestId == _chartRequestId) {
        _chartLoading = false;
        notifyListeners();
      }
    }
  }

  AccountAnalysisPerformanceRequest? _buildPerformanceRequest() {
    final accountId = AppConfig().accountId?.trim();
    if (accountId == null || accountId.isEmpty) {
      _performanceRequestError =
          'Account ID is unavailable. Please sign in again.';
      return null;
    }

    final period = _periodKeys[_selectedTime];
    final normalizedCustomRange = _customRange?.trim();
    if (period == 'custom' &&
        (normalizedCustomRange == null ||
            !RegExp(
              r'^\d{4}-\d{2}-\d{2}\.\.\d{4}-\d{2}-\d{2}$',
            ).hasMatch(normalizedCustomRange))) {
      _performanceRequestError =
          'Enter a custom range as YYYY-MM-DD..YYYY-MM-DD.';
      return null;
    }

    _performanceRequestError = null;
    return AccountAnalysisPerformanceRequest(
      accountId: accountId,
      period: period,
      marketImpact: _marketImpactKeys[_selectedMarketImpact],
      customRange: period == 'custom' ? normalizedCustomRange : null,
    );
  }

  Future<void> fetchCalendar(BuildContext context) async {
    final requestId = ++_calendarRequestId;
    _tradeDays.clear();
    _calendarError = null;
    _isCalendarLoading = true;
    notifyListeners();

    final accountId = AppConfig().accountId?.trim();
    if (accountId == null || accountId.isEmpty) {
      _calendarError = 'Account ID is unavailable. Please sign in again.';
      _isCalendarLoading = false;
      notifyListeners();
      return;
    }

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

  Future<void> fetchDayDetails(BuildContext context, DateTime date) async {
    final requestId = ++_dayDetailsRequestId;
    _dayDetails = null;
    _dayDetailsError = null;
    _isDayDetailsLoading = true;
    notifyListeners();

    final accountId = AppConfig().accountId?.trim();
    if (accountId == null || accountId.isEmpty) {
      _dayDetailsError = 'Account ID is unavailable. Please sign in again.';
      _isDayDetailsLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await _repository.fetchCalendarDayDetails(
        context,
        request: AccountAnalysisDayDetailsRequest(
          accountId: accountId,
          date: _formatDate(date),
        ),
      );
      if (requestId != _dayDetailsRequestId) return;

      if (response is NetworkResponse) {
        _dayDetailsError = _dayDetailsResponseError(response);
      } else if (response is! Map) {
        _dayDetailsError = 'The trade details response is invalid.';
      } else {
        _dayDetails = AnalysisDayDetails.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } on FormatException catch (error) {
      _dayDetailsError = error.message;
    } on Exception catch (error) {
      _dayDetailsError = 'Unable to load trade details: $error';
    } finally {
      if (requestId == _dayDetailsRequestId) {
        _isDayDetailsLoading = false;
        notifyListeners();
      }
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _dayDetailsResponseError(NetworkResponse response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final message = decoded['message'] ?? decoded['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      } else if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    } on FormatException {
      if (response.body.trim().isNotEmpty) return response.body.trim();
    }
    return 'Unable to load trade details (${response.statusCode}).';
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

  void setSelectedMarketImpact(int index) {
    if (index < 0 || index >= _marketImpactKeys.length) return;
    _selectedMarketImpact = index;
    notifyListeners();
  }

  void setSelectedTime(int index) {
    if (index < 0 || index >= _periodKeys.length) return;
    _selectedTime = index;
    notifyListeners();
  }

  void setDialogSelectedMonth(int month) {
    _dialogSelectedMonth = month;
    notifyListeners();
  }

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

  String monthName(int month) => monthNames[month - 1];

  bool isAfterToday(DateTime day) {
    final today = DateTime.now();
    return day.isAfter(DateTime(today.year, today.month, today.day));
  }

  TradeDayStatus statusForDay(DateTime day) {
    if (isAfterToday(day)) return TradeDayStatus.future;
    return _tradeDays[DateTime(day.year, day.month, day.day)] ??
        TradeDayStatus.none;
  }

  List<AnalysisMetric> getMetrics() => _performanceStats?.metrics ?? const [];

  List<SummaryCardData> getSummaryCards() =>
      _performanceStats?.summaryCards ?? const [];

  List<StatData> getPerformanceStats() => _performanceStats?.stats ?? const [];

  List<PerformancePoint> getPerformanceChartData() =>
      _performanceChart?.chartData ?? const [];
}
