import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_day_details_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/service/analysis_service.dart';

class TradeDayDetailsPage extends StatelessWidget {
  const TradeDayDetailsPage({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = NerveBase().isDarkMode;
    final backgroundColor = isDarkMode ? const Color(0xFF0D110F) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF303236);
    final mutedColor =
        isDarkMode ? const Color(0xFF8F9693) : const Color(0xFF999B9F);
    final dividerColor =
        isDarkMode ? const Color(0xFF292E2B) : const Color(0xFFECEDEF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('d MMM, yyyy').format(date),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          isDarkMode
                              ? const Color(0xFF242926)
                              : const Color(0xFFF3F4F6),
                    ),
                    icon: Icon(Icons.close, size: 18, color: mutedColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AnalysisService>(
                builder: (context, service, _) {
                  if (service.isDayDetailsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (service.dayDetailsError != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              service.dayDetailsError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed:
                                  () => unawaited(
                                    service.fetchDayDetails(context, date),
                                  ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final details = service.dayDetails;
                  if (details == null) {
                    return Center(
                      child: Text(
                        'No trade details available.',
                        style: TextStyle(color: mutedColor),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                    children: [
                      _summaryCard(
                        details: details,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        dividerColor: dividerColor,
                      ),
                      const SizedBox(height: 12),
                      if (details.trades.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: Text(
                              'No trades for this date.',
                              style: TextStyle(color: mutedColor),
                            ),
                          ),
                        )
                      else
                        for (
                          var index = 0;
                          index < details.trades.length;
                          index++
                        ) ...[
                          _tradeCard(
                            trade: details.trades[index],
                            textColor: textColor,
                            mutedColor: mutedColor,
                            dividerColor: dividerColor,
                            isDarkMode: isDarkMode,
                          ),
                          if (index != details.trades.length - 1)
                            Divider(height: 1, color: dividerColor),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required AnalysisDayDetails details,
    required Color textColor,
    required Color mutedColor,
    required Color dividerColor,
  }) {
    final pnlColor =
        details.netPnl < 0 ? const Color(0xFFFF3548) : const Color(0xFF00A86B);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        border: Border.all(color: dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'NET P&L',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                _formatSignedAmount(details.netPnl),
                style: TextStyle(
                  color: pnlColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryMetric(
                'TRADES',
                '${details.tradeCount}',
                mutedColor,
                textColor,
              ),
              _summaryDivider(dividerColor),
              _summaryMetric(
                'WINS',
                '${details.wins}',
                mutedColor,
                const Color(0xFF00A86B),
              ),
              _summaryDivider(dividerColor),
              _summaryMetric(
                'LOSSES',
                '${details.losses}',
                mutedColor,
                const Color(0xFFFF3548),
              ),
              _summaryDivider(dividerColor),
              _summaryMetric(
                'WIN RATE',
                '${_formatNumber(details.winRate)}%',
                mutedColor,
                textColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(
    String label,
    String value,
    Color mutedColor,
    Color valueColor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: mutedColor,
              fontSize: 9,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider(Color color) => Container(
    width: 1,
    height: 24,
    color: color,
    margin: const EdgeInsets.symmetric(horizontal: 2),
  );

  Widget _tradeCard({
    required AnalysisDayTrade trade,
    required Color textColor,
    required Color mutedColor,
    required Color dividerColor,
    required bool isDarkMode,
  }) {
    final pnlColor =
        trade.netPnl < 0 ? const Color(0xFFFF3548) : const Color(0xFF00A86B);
    final changeColor =
        trade.changePercent < 0
            ? const Color(0xFFFF3548)
            : const Color(0xFF00A86B);
    final softChangeColor =
        trade.changePercent < 0
            ? const Color(0xFFFFEFF1)
            : const Color(0xFFE9F8F1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              _symbolIcon(trade.symbol, isDarkMode),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.symbol,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${_titleCase(trade.side)} – ',
                            style: TextStyle(
                              color: _sideColor(trade.side),
                              fontSize: 10,
                            ),
                          ),
                          TextSpan(
                            text: _titleCase(trade.action),
                            style: TextStyle(color: mutedColor, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '◷ ${trade.time}',
                    style: TextStyle(color: mutedColor, fontSize: 10),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatSignedAmount(trade.netPnl),
                    style: TextStyle(
                      color: pnlColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('B ', style: TextStyle(color: mutedColor, fontSize: 11)),
              Text(
                _formatNumber(trade.bid),
                style: TextStyle(color: textColor, fontSize: 11),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(width: 1, height: 12, color: dividerColor),
              ),
              Text('A ', style: TextStyle(color: mutedColor, fontSize: 11)),
              Text(
                _formatNumber(trade.ask),
                style: TextStyle(color: textColor, fontSize: 11),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: softChangeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_formatSignedPercent(trade.changePercent)} (${_formatSignedPoints(trade.changePoints)} pts)',
                  style: TextStyle(color: changeColor, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _tradeValue('Type', _tradeType(trade), mutedColor, textColor),
              _tradeValue(
                'Units',
                _formatNumber(trade.units),
                mutedColor,
                textColor,
              ),
              _tradeValue(
                'Amount',
                '\$${_formatNumber(trade.amount)}',
                mutedColor,
                textColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _tradeValue(
                'Stop Loss',
                _formatNumber(trade.stopLoss),
                mutedColor,
                textColor,
              ),
              _tradeValue(
                'Take Profit',
                _formatNumber(trade.takeProfit),
                mutedColor,
                textColor,
              ),
              _tradeValue(
                'Commission',
                '\$${_formatNumber(trade.commission)}',
                mutedColor,
                textColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _symbolIcon(String symbol, bool isDarkMode) {
    final color = switch (symbol.toUpperCase()) {
      'NVDA' => const Color(0xFF76B900),
      'TSLA' => const Color(0xFFE82127),
      _ => const Color(0xFF171717),
    };
    final isTesla = symbol.toUpperCase() == 'TSLA';
    final backgroundColor =
        isTesla
            ? color
            : (isDarkMode ? const Color(0xFF252A33) : const Color(0xFFF1F2F4));

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        symbol.isEmpty ? '' : symbol[0],
        style: TextStyle(
          color: isTesla ? Colors.white : color,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _tradeValue(
    String label,
    String value,
    Color mutedColor,
    Color textColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: mutedColor, fontSize: 10)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: textColor, fontSize: 12)),
        ],
      ),
    );
  }

  String _tradeType(AnalysisDayTrade trade) =>
      '${_titleCase(trade.side)} – ${_titleCase(trade.action)}';

  Color _sideColor(String side) =>
      side.toLowerCase() == 'buy'
          ? const Color(0xFF00A86B)
          : const Color(0xFFFF3548);

  String _titleCase(String value) =>
      value.isEmpty
          ? value
          : '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';

  String _formatSignedAmount(double amount) {
    final formatted = NumberFormat('#,##0.00').format(amount.abs());
    return '${amount < 0 ? '-' : '+'}$formatted';
  }

  String _formatNumber(num value) => NumberFormat('#,##0.##').format(value);

  String _formatSignedPercent(double percent) =>
      '${percent < 0 ? '' : '+'}${percent.toStringAsFixed(2)}%';

  String _formatSignedPoints(double points) =>
      '${points < 0 ? '' : '+'}${points.toStringAsFixed(2)}';
}
