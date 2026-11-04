import 'package:flutter/material.dart';
import 'package:century_cqg/Screens/Account/model/account_model.dart';

enum TradeDayStatus { win, loss, none, future }

class AnalysisMetric {
  final String label;
  final String value;

  const AnalysisMetric({required this.label, required this.value});
}

class PerformancePoint {
  final String day;
  final double winningTrades;
  final double losingTrades;

  const PerformancePoint({
    required this.day,
    required this.winningTrades,
    required this.losingTrades,
  });
}

class StatData {
  final String label;
  final String value;
  final Color? valueColor;

  const StatData({required this.label, required this.value, this.valueColor});
}

class AnalysisPerformanceData {
  const AnalysisPerformanceData({
    required this.periodStart,
    required this.periodEnd,
    required this.metrics,
    required this.summaryCards,
    required this.stats,
    required this.chartData,
  });

  final String periodStart;
  final String periodEnd;
  final List<AnalysisMetric> metrics;
  final List<SummaryCardData> summaryCards;
  final List<StatData> stats;
  final List<PerformancePoint> chartData;

  factory AnalysisPerformanceData.fromJson(Map<String, dynamic> json) {
    return AnalysisPerformanceData(
      periodStart: _requiredString(json, 'period_start'),
      periodEnd: _requiredString(json, 'period_end'),
      metrics: _parseList(json, 'metrics', (item) {
        return AnalysisMetric(
          label: _requiredString(item, 'label'),
          value: _requiredString(item, 'value'),
        );
      }),
      summaryCards: _parseList(json, 'summary_cards', (item) {
        final tone = _requiredString(item, 'tone');
        final colors = _summaryColors(tone);
        return SummaryCardData(
          label: _requiredString(item, 'label'),
          value: _requiredString(item, 'value'),
          valueColor: colors.value,
          lightBackground: colors.light,
          darkBackground: colors.dark,
        );
      }),
      stats: _parseList(json, 'stats', (item) {
        return StatData(
          label: _requiredString(item, 'label'),
          value: _requiredString(item, 'value'),
          valueColor: _toneColor(_requiredString(item, 'tone')),
        );
      }),
      chartData: _parseList(json, 'chart_data', (item) {
        return PerformancePoint(
          day: _requiredString(item, 'day'),
          winningTrades: _requiredDouble(item, 'winning_trades'),
          losingTrades: _requiredDouble(item, 'losing_trades'),
        );
      }),
    );
  }
}

class AnalysisCalendarData {
  const AnalysisCalendarData({required this.tradeDays});

  final Map<DateTime, TradeDayStatus> tradeDays;

  factory AnalysisCalendarData.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'];
    if (rawDays is! List) {
      throw const FormatException('Analysis calendar "days" must be a list.');
    }

    final tradeDays = <DateTime, TradeDayStatus>{};
    for (final rawDay in rawDays) {
      if (rawDay is! Map) {
        throw const FormatException('Analysis calendar entries must be maps.');
      }

      final item = Map<String, dynamic>.from(rawDay);
      final date = DateTime.tryParse(_requiredString(item, 'date'));
      if (date == null) {
        throw const FormatException('Analysis calendar date is invalid.');
      }

      final statusName = _requiredString(item, 'status');
      final status = switch (statusName) {
        'win' => TradeDayStatus.win,
        'loss' => TradeDayStatus.loss,
        'none' => TradeDayStatus.none,
        _ =>
          throw FormatException(
            'Unsupported analysis calendar status: $statusName',
          ),
      };
      tradeDays[DateTime(date.year, date.month, date.day)] = status;
    }
    return AnalysisCalendarData(tradeDays: tradeDays);
  }
}

List<T> _parseList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) parseItem,
) {
  final rawList = json[key];
  if (rawList is! List) {
    throw FormatException('Analysis response "$key" must be a list.');
  }
  return rawList.map((rawItem) {
    if (rawItem is! Map) {
      throw FormatException('Analysis response "$key" entries must be maps.');
    }
    return parseItem(Map<String, dynamic>.from(rawItem));
  }).toList();
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null || value.toString().trim().isEmpty) {
    throw FormatException('Analysis response "$key" is missing.');
  }
  return value.toString();
}

double _requiredDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null || !parsed.isFinite) {
    throw FormatException('Analysis response "$key" is invalid.');
  }
  return parsed;
}

Color? _toneColor(String tone) => switch (tone) {
  'positive' => const Color(0xFF0AA66A),
  'negative' => const Color(0xFFFF4B55),
  'neutral' => null,
  _ => throw FormatException('Unsupported analysis tone: $tone'),
};

({Color value, Color light, Color dark}) _summaryColors(String tone) =>
    switch (tone) {
      'positive' => (
        value: const Color(0xFF0AA66A),
        light: const Color(0xFFEAF8F2),
        dark: const Color(0xFF112B22),
      ),
      'negative' => (
        value: const Color(0xFFFF4B55),
        light: const Color(0xFFFDEEF1),
        dark: const Color(0xFF321A1E),
      ),
      'neutral' => (
        value: const Color(0xFFC89000),
        light: const Color(0xFFFFF6DE),
        dark: const Color(0xFF332A12),
      ),
      _ => throw FormatException('Unsupported analysis tone: $tone'),
    };
