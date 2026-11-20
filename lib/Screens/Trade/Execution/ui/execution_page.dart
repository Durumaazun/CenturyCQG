import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Helper/nerve_styles.dart';
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/Execution/service/execution_service.dart';

class ExecutionPage extends StatelessWidget {
  const ExecutionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ExecutionService>();
    final isDarkMode = NerveBase().isDarkMode;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF444444);
    final mutedColor =
        isDarkMode ? const Color(0xFF8F9793) : const Color(0xFF7A817D);
    final dividerColor =
        isDarkMode ? const Color(0xFF2A302D) : const Color(0xFFE8ECEA);
    final positiveColor = const Color(0xFF00A879);
    final executions = service.executions;

    if (service.isLoading && executions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (service.error != null && executions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(service.error!, textAlign: TextAlign.center),
              TextButton(
                onPressed: service.fetchExecutions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (executions.isEmpty) {
      return const Center(child: Text('No executions found.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Text(
                'Execution',
                style: NerveStyles.tradeDetailsSectionTitleStyle(titleColor),
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
            itemCount: executions.length,
            separatorBuilder:
                (_, __) => Container(height: 1, color: dividerColor),
            itemBuilder: (context, index) {
              final item = executions[index];
              final dateLabel = _dateLabel(item.executedAt);
              final showDate =
                  index == 0 ||
                  dateLabel != _dateLabel(executions[index - 1].executedAt);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDate) ...[
                    if (index != 0) const SizedBox(height: 16),
                    Text(
                      dateLabel,
                      style: NerveStyles.tradeDetailsSectionTitleStyle(
                        titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _executionRow(item, titleColor, mutedColor, positiveColor),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _executionRow(
    TradeExecution item,
    Color titleColor,
    Color mutedColor,
    Color positiveColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                style: NerveStyles.tradePositionSymbolStyle(titleColor),
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
                _timeLabel(item.executedAt),
                style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnWidth = (constraints.maxWidth - 24) / 4;
              return Row(
                children: [
                  SizedBox(
                    width: columnWidth,
                    child: _metric(
                      'B/S',
                      item.side,
                      mutedColor,
                      item.side.toLowerCase() == 'buy'
                          ? positiveColor
                          : const Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: columnWidth,
                    child: _metric(
                      'Units',
                      _formatNumber(item.fillQuantity),
                      mutedColor,
                      titleColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: columnWidth,
                    child: _metric(
                      'Price',
                      _money(item.fillPrice),
                      mutedColor,
                      titleColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: columnWidth,
                    child: _metric(
                      'Amount',
                      _money(item.amount),
                      mutedColor,
                      titleColor,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metric(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    TextAlign textAlign = TextAlign.start,
  }) {
    return Column(
      crossAxisAlignment:
          textAlign == TextAlign.end
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: NerveStyles.tradePositionMetricLabelStyle(labelColor),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: textAlign,
          style: NerveStyles.tradeDetailsOrderBuyValueStyle(valueColor),
        ),
      ],
    );
  }

  String _dateLabel(DateTime? date) =>
      date == null
          ? 'Date unavailable'
          : DateFormat('dd MMM yyyy').format(date.toLocal());

  String _timeLabel(DateTime? date) =>
      date == null ? '--' : DateFormat('HH:mm').format(date.toLocal());

  String _formatNumber(num value) => NumberFormat('#,##0.##').format(value);

  String _money(num value) => '\$${NumberFormat('#,##0.00').format(value)}';
}
