import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:century_cqg/Helper/nerve_styles.dart';
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/History/service/history_service.dart';

class HistoryList extends StatelessWidget {
  final Color mutedColor;
  final Color textColor;

  const HistoryList({
    super.key,
    required this.mutedColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HistoryService>();
    final history = service.history;
    if (service.isLoading && history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (service.error != null && history.isEmpty) {
      return _loadError(service.error!, service.fetchHistory);
    }
    if (history.isEmpty) {
      return const Center(child: Text('No trade history found.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              Text(
                'History',
                style: NerveStyles.tradeDetailsSectionTitleStyle(textColor),
              ),
              const Spacer(),
              Icon(Icons.sort, size: 18, color: mutedColor),
              const SizedBox(width: 10),
              Icon(Icons.filter_alt_outlined, size: 18, color: mutedColor),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = history[index];
              final dateLabel = _dateLabel(item.updatedAt);
              final showDate =
                  index == 0 ||
                  dateLabel != _dateLabel(history[index - 1].updatedAt);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDate) ...[
                    if (index != 0) const SizedBox(height: 16),
                    Text(
                      dateLabel,
                      style: NerveStyles.tradeDetailsSectionTitleStyle(
                        textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _historyRow(item, textColor, mutedColor),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _historyRow(TradeHistoryItem item, Color textColor, Color mutedColor) {
    const sellColor = Color(0xFFE53935);
    const takeProfitColor = Color(0xFF00A879);
    final time = item.updatedAt?.toLocal();
    final sideColor =
        item.side.toLowerCase() == 'buy' ? takeProfitColor : sellColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E8E93),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.symbolName.isEmpty
                      ? ''
                      : item.symbolName[0].toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.symbolName,
                style: NerveStyles.tradePositionSymbolStyle(textColor),
              ),
              const Spacer(),
              Text(
                item.orderId,
                style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
              ),
              const SizedBox(width: 8),
              Icon(Icons.access_time, size: 13, color: mutedColor),
              const SizedBox(width: 4),
              Text(
                time == null ? '--' : DateFormat('HH:mm').format(time),
                style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'Type',
                  '${item.side} ${item.status}',
                  sideColor,
                  mutedColor,
                ),
              ),
              Expanded(
                child: _metric(
                  'Units',
                  _formatNumber(item.filledQuantity),
                  textColor,
                  mutedColor,
                ),
              ),
              Expanded(
                child: _metric(
                  'Price',
                  _money(item.price),
                  textColor,
                  mutedColor,
                ),
              ),
              Expanded(
                child: _slTpMetric(
                  item,
                  sellColor,
                  takeProfitColor,
                  mutedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(
    String label,
    String value,
    Color valueColor,
    Color labelColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: NerveStyles.tradePositionMetricLabelStyle(labelColor),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: NerveStyles.tradeDetailsOrderBuyValueStyle(valueColor),
        ),
      ],
    );
  }

  Widget _slTpMetric(
    TradeHistoryItem item,
    Color stopLossColor,
    Color takeProfitColor,
    Color labelColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SL / TP',
          style: NerveStyles.tradePositionMetricLabelStyle(labelColor),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: NerveStyles.tradeDetailsOrderBuyValueStyle(stopLossColor),
            children: [
              TextSpan(text: '${_optionalMoney(item.stopLoss)} / '),
              TextSpan(
                text: _optionalMoney(item.takeProfit),
                style: NerveStyles.tradeDetailsOrderBuyValueStyle(
                  takeProfitColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loadError(String message, Future<void> Function() retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            TextButton(onPressed: retry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  String _formatNumber(num value) => NumberFormat('#,##0.##').format(value);

  String _money(num value) => '\$${NumberFormat('#,##0.00').format(value)}';

  String _optionalMoney(num? value) =>
      value == null ? '--' : NumberFormat('#,##0.00').format(value);

  String _dateLabel(DateTime? date) =>
      date == null
          ? 'Date unavailable'
          : DateFormat('dd MMM yyyy').format(date.toLocal());
}
