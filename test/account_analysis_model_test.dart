import 'package:flutter_test/flutter_test.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_request_model.dart';

void main() {
  group('Account analysis requests', () {
    test('serializes the performance filters using backend field names', () {
      const request = AccountAnalysisPerformanceRequest(
        accountId: 'account-1',
        period: 'custom',
        marketImpact: 'winning',
        customRange: '2026-01-01..2026-01-31',
      );

      expect(request.toJson(), {
        'accnt_id': 'account-1',
        'period': 'custom',
        'market_impact': 'winning',
        'custom_range': '2026-01-01..2026-01-31',
      });
    });

    test('serializes the calendar month using backend field names', () {
      const request = AccountAnalysisCalendarRequest(
        accountId: 'account-1',
        year: 2026,
        month: 11,
      );

      expect(request.toJson(), {
        'accnt_id': 'account-1',
        'year': 2026,
        'month': 11,
      });
    });
  });

  group('Analysis response parsing', () {
    test('parses performance data and presentation tones', () {
      final response = AnalysisPerformanceData.fromJson({
        'period_start': '2026-01-01',
        'period_end': '2026-01-31',
        'metrics': [
          {'label': 'Winning Trades', 'value': '14'},
        ],
        'summary_cards': [
          {'label': 'WINS', 'value': '14', 'tone': 'positive'},
        ],
        'stats': [
          {'label': 'Net Profit', 'value': '6200.83', 'tone': 'positive'},
        ],
        'chart_data': [
          {'day': 'Mon', 'winning_trades': 5, 'losing_trades': 2},
        ],
      });

      expect(response.periodStart, '2026-01-01');
      expect(response.metrics.single.value, '14');
      expect(response.summaryCards.single.label, 'WINS');
      expect(response.stats.single.value, '6200.83');
      expect(response.chartData.single.winningTrades, 5);
    });

    test('parses the daily calendar statuses', () {
      final response = AnalysisCalendarData.fromJson({
        'days': [
          {'date': '2026-11-02', 'status': 'win'},
          {'date': '2026-11-03', 'status': 'loss'},
        ],
      });

      expect(response.tradeDays[DateTime(2026, 11, 2)], TradeDayStatus.win);
      expect(response.tradeDays[DateTime(2026, 11, 3)], TradeDayStatus.loss);
    });
  });
}
