import 'package:century_cqg/Screens/Trade/ui/positions/position_success_img.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Helper/nerve_styles.dart';
import 'package:century_cqg/Screens/Trade/service/close_all_positions_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_page_service.dart';

class PositionSymbolDetailsPage extends StatelessWidget {
  final String symbol;
  final String avgPrice;
  final String side;
  final String netUnits;
  final String averageAmount;
  final String netPnL;
  final String badge;
  final Color badgeColor;

  const PositionSymbolDetailsPage({
    super.key,
    required this.symbol,
    required this.avgPrice,
    required this.side,
    required this.netUnits,
    required this.averageAmount,
    required this.netPnL,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = NerveBase().isDarkMode;
    final pageBg =
        isDarkMode ? const Color(0xFF0D110F) : const Color(0xFFF7F9F8);
    final cardColor = isDarkMode ? const Color(0xFF0F1412) : Colors.white;
    final borderColor =
        isDarkMode ? const Color(0xFF252A28) : const Color(0xFFE1E6E3);
    final dividerColor =
        isDarkMode ? const Color(0xFF222826) : const Color(0xFFE8ECEA);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF212826);
    final mutedColor =
        isDarkMode ? const Color(0xFF808985) : const Color(0xFF727A76);
    final positiveColor = const Color(0xFF00C389);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        surfaceTintColor: pageBg,
        titleSpacing: 0,
        title: Text(
          symbol,
          style: NerveStyles.tradeDetailsHeaderSymbolStyle(titleColor),
        ),
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: NerveStyles.tradeDetailsCardDecoration(
                  cardColor,
                  borderColor,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: badgeColor),
                          alignment: Alignment.center,
                          child: Text(
                            badge,
                            style: NerveStyles.tradePositionAvatarTextStyle(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            symbol,
                            style: NerveStyles.tradeDetailsHeaderSymbolStyle(
                              titleColor,
                            ),
                          ),
                        ),
                        Text(
                          avgPrice,
                          style: NerveStyles.tradeDetailsHeaderSymbolStyle(
                            titleColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _positionMetric(
                            'B/S',
                            side,
                            mutedColor,
                            positiveColor,
                          ),
                        ),
                        Expanded(
                          child: _positionMetric(
                            'Net Units',
                            netUnits,
                            mutedColor,
                            titleColor,
                          ),
                        ),
                        Expanded(
                          child: _positionMetric(
                            'Avg. Price',
                            averageAmount,
                            mutedColor,
                            titleColor,
                          ),
                        ),
                        Expanded(
                          child: _positionMetric(
                            'Net P&L',
                            netPnL,
                            mutedColor,
                            positiveColor,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder:
                                (_) => _CloseAllPositionsSheet(symbol: symbol),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFF2C400),
                          foregroundColor: const Color(0xFF1F1F1F),
                        ),
                        child: Consumer<TradePageService>(
                          builder:
                              (context, tradePageService, _) => Text(
                                'Close All Positions (${tradePageService.positionDetails.length})',
                                style:
                                    NerveStyles.tradeDetailsCloseAllButtonStyle(),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 250,
                ),
                padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
                decoration: NerveStyles.tradeDetailsCardDecoration(
                  cardColor,
                  borderColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Positions',
                      style: NerveStyles.tradeDetailsSectionTitleStyle(
                        titleColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Consumer<TradePageService>(
                      builder: (context, tradePageService, _) {
                        final summary = tradePageService.positionSummary;
                        final netPositions =
                            tradePageService.netPositionDetails;
                        if (summary == null && netPositions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (summary != null)
                                Text(
                                  'Market Price: \$${summary.marketPrice.toStringAsFixed(2)}  •  Position Value: \$${summary.positionValue.toStringAsFixed(2)}',
                                  style: TextStyle(color: mutedColor),
                                ),
                              for (final position in netPositions)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${position.side}  •  ${position.netUnit} units  •  Avg. \$${position.avgPrice.toStringAsFixed(2)}  •  P&L \$${position.netPnl.toStringAsFixed(2)}',
                                    style: TextStyle(color: titleColor),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    Consumer<TradePageService>(
                      builder: (context, tradePageService, _) {
                        if (tradePageService.isLoadingPositionDetails &&
                            tradePageService.positionDetails.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (tradePageService.positionDetailsError != null) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tradePageService.positionDetailsError!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    () => tradePageService.fetchPositionDetails(
                                      context,
                                      symbolName: symbol,
                                    ),
                                child: const Text('Retry'),
                              ),
                            ],
                          );
                        }

                        if (tradePageService.positionDetails.isEmpty) {
                          return const Text('No positions found.');
                        }

                        return Column(
                          children: [
                            for (final position
                                in tradePageService.positionDetails)
                              _positionDetailCard(
                                position.symbolName,
                                position.side,
                                position.netUnits,
                                position.averageAmount,
                                position.displayNetPnl,
                                position.displayPrice,
                                position.pricePercentage,
                                cardColor,
                                borderColor,
                                dividerColor,
                                titleColor,
                                mutedColor,
                                positiveColor,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _positionDetailCard(
    String positionSymbol,
    String side,
    String units,
    String averagePrice,
    String pnl,
    String price,
    double pricePercentage,
    Color cardColor,
    Color borderColor,
    Color dividerColor,
    Color titleColor,
    Color mutedColor,
    Color positiveColor,
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8, right: 16, top: 8),
      decoration: NerveStyles.tradeDetailsCardDecoration(
        cardColor,
        borderColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  positionSymbol,
                  style: NerveStyles.tradeDetailsOrderIdStyle(titleColor),
                ),
              ),
              Text(
                price,
                style: NerveStyles.tradeDetailsOrderDateStyle(titleColor),
              ),
              const SizedBox(width: 6),
              Text(
                '${pricePercentage >= 0 ? '+' : ''}${pricePercentage.toStringAsFixed(2)}%',
                style: NerveStyles.tradeDetailsOrderPnlStyle(
                  pricePercentage >= 0
                      ? positiveColor
                      : const Color(0xFFDB3D52),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _orderMetric('B/S', side, mutedColor, positiveColor),
              ),
              Expanded(
                child: _orderMetric(
                  'Units',
                  units,
                  mutedColor,
                  titleColor,
                  textAlign: TextAlign.end,
                ),
              ),
              Expanded(
                child: _orderMetric(
                  'Avg. Price',
                  averagePrice,
                  mutedColor,
                  titleColor,
                  textAlign: TextAlign.end,
                ),
              ),
              Expanded(
                child: _orderMetric(
                  'Net P&L',
                  pnl,
                  mutedColor,
                  positiveColor,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: dividerColor),
        ],
      ),
    );
  }

  Widget _positionMetric(
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
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: textAlign,
          style: NerveStyles.tradePositionMetricValueStyle(valueColor),
        ),
      ],
    );
  }

  Widget _orderMetric(
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
          style: NerveStyles.tradeDetailsOrderMetricLabelStyle(labelColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: textAlign,
          style: NerveStyles.tradeDetailsOrderBuyValueStyle(valueColor),
        ),
      ],
    );
  }
}

class _CloseAllPositionsSheet extends StatelessWidget {
  final String symbol;

  const _CloseAllPositionsSheet({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CloseAllPositionsService>(
      create: (_) => CloseAllPositionsService(),
      child: Consumer<CloseAllPositionsService>(
        builder: (context, closeService, _) {
          final isDarkMode = NerveBase().isDarkMode;
          final bgColor = isDarkMode ? const Color(0xFF111614) : Colors.white;
          final borderColor =
              isDarkMode ? const Color(0xFF2B302D) : const Color(0xFFD3D8D5);
          final titleColor =
              isDarkMode ? Colors.white : const Color(0xFF2A2A2A);
          final lineColor =
              isDarkMode ? const Color(0xFF2B302D) : const Color(0xFFE8ECEA);
          final positiveColor = const Color(0xFF00C389);
          final entries = closeService.entries;
          final selectedCount = closeService.selectedCount;

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Material(
                  color: bgColor,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(
                              color: lineColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Are you sure you want to CLOSE ALL positions of $symbol?',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.5,
                            letterSpacing: 0,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(entries.length, (index) {
                          final entry = entries[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == entries.length - 1 ? 0 : 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    closeService.toggleSelection(index);
                                  },
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2C400),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child:
                                        entry.selected
                                            ? const Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Color(0xFF1F1F1F),
                                            )
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _closePositionMetric(
                                          'Units',
                                          entry.orderId,
                                          titleColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: _closePositionMetric(
                                          'B/S',
                                          entry.side,
                                          positiveColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: _closePositionMetric(
                                          'Units',
                                          entry.units,
                                          titleColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: _closePositionMetric(
                                          'P&L',
                                          entry.pnl,
                                          positiveColor,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  foregroundColor: titleColor,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    selectedCount == 0
                                        ? null
                                        : () {
                                          Navigator.pop(context);
                                          showModalBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder:
                                                (_) => NetPosClsSuccesPage(
                                                  symbol: symbol,
                                                  unitsSold: selectedCount
                                                      .toStringAsFixed(2),
                                                ),
                                          );
                                        },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  backgroundColor: const Color(0xFFF2C400),
                                  foregroundColor: const Color(0xFF1F1F1F),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Close $selectedCount Positions'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _closePositionMetric(
    String label,
    String value,
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
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: 0,
            color: Color(0xFF8B918E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: textAlign,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1,
            letterSpacing: 0,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
