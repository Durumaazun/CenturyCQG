import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/ui/stock_details_page.dart';
import 'package:century_cqg/Screens/Dashboard/model/dashboard_models.dart';
import 'package:century_cqg/Helper/nerve_styles.dart';
import 'package:century_cqg/Helper/nerve_colors.dart';
import 'package:century_cqg/Screens/Dashboard/service/dasboard_service.dart';
import 'package:century_cqg/Helper/nerve_base.dart';

class DashboardBodyView extends StatelessWidget {
  const DashboardBodyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardService>(
      builder: (context, proValue, _) {
        final isDarkMode = NerveBase().isDarkMode;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            accountSumView(isDarkMode, proValue),
            SizedBox(height: 8),

            watchedListView(isDarkMode, proValue),
            SizedBox(height: 8),

            topPositionView(isDarkMode, proValue),
            SizedBox(height: 8),

            trendingView(context, isDarkMode, proValue),
            SizedBox(height: 8),

            activityFeedView(isDarkMode, proValue),
            SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget accountSumView(bool isDarkMode, DashboardService dashboardService) {
    final summary = dashboardService.accountSummary;
    String formatAmount(double amount) {
      final value = amount.toStringAsFixed(2);
      final currency = summary.currency.trim().toUpperCase();
      if (currency == 'USD') return '\$$value';
      return currency.isEmpty ? value : '$currency $value';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: NerveColors.primaryColor(isDarkMode)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Summary', style: _dashboardHeadingStyle(isDarkMode)),
            const SizedBox(height: 6),
            if (dashboardService.accountSummaryError != null)
              Text(
                dashboardService.accountSummaryError!,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildMetricColumn(
                        title: 'Cash Balance',
                        value: formatAmount(summary.cashBalance),
                        isDarkMode: isDarkMode,
                        valueSize: 20,
                        valueWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetricItem(
                            'Buying Power',
                            formatAmount(summary.buyingPower),
                            isDarkMode: isDarkMode,
                            isBoldValue: true,
                          ),
                          const SizedBox(height: 6),
                          _buildMetricItem(
                            'Unrealized P&L',
                            formatAmount(summary.unrealizedPnL),
                            isDarkMode: isDarkMode,
                            valueColor:
                                isDarkMode
                                    ? Colors.green.shade300
                                    : Colors.green.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetricItem(
                            'Margin Used',
                            formatAmount(summary.marginUsed),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 6),
                          _buildMetricItem(
                            'Realized P&L',
                            formatAmount(summary.realizedPnL),
                            isDarkMode: isDarkMode,
                            valueColor:
                                isDarkMode
                                    ? Colors.green.shade300
                                    : Colors.green.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget watchedListView(bool isDarkMode, DashboardService proValue) {
    final watchedStocks = proValue.watchedStocks;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NerveColors.primaryColor(isDarkMode),
        border: Border.all(
          color:
              isDarkMode
                  ? const Color(0xFF202220)
                  : NerveColors.containerBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Watched Recently',
                style: _dashboardHeadingStyle(isDarkMode),
              ),
              Text('Show All', style: NerveStyles.blue_bold_12(isDarkMode)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 171,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: watchedStocks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final stock = watchedStocks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailsPage.fromStock(stock),
                      ),
                    );
                  },
                  child: stockCard(stock: stock, isDarkMode: isDarkMode),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required String title,
    required String value,
    required bool isDarkMode,
    required double valueSize,
    required FontWeight valueWeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: NerveStyles.black_normal_11(isDarkMode)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: valueWeight,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  TextStyle _dashboardHeadingStyle(bool isDarkMode) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: isDarkMode ? Colors.white : Colors.black87,
    );
  }

  Widget _buildMetricItem(
    String label,
    String value, {
    required bool isDarkMode,
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: NerveStyles.black_normal_11(isDarkMode),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget stockCard({required Stock stock, required bool isDarkMode}) {
    final rawChange = stock.change.trim();
    final isNegative = rawChange.contains('-');
    final changeText =
        rawChange.isNotEmpty
            ? (rawChange.startsWith('+') || rawChange.startsWith('-')
                ? rawChange
                : '+$rawChange')
            : '+0.00%';

    final pointsText = () {
      final rawPts = stock.changePoints.trim();
      if (rawPts.isEmpty || rawPts == '--') {
        return '(-- pts)';
      }
      var pts = rawPts;
      if (!pts.startsWith('+') && !pts.startsWith('-')) {
        pts = '+$pts';
      }
      if (!pts.endsWith('pts')) {
        pts = '$pts pts';
      }
      return '($pts)';
    }();

    final changeColor =
        isNegative
            ? (isDarkMode ? Colors.red.shade300 : Colors.red.shade600)
            : (isDarkMode ? Colors.green.shade300 : Colors.green.shade600);

    final displayPrice =
        stock.price.startsWith('\$') ? stock.price : '\$${stock.price}';

    return Container(
      width: 171,
      height: 171,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1E1D) : Colors.white,
        border: Border.all(
          width: 1,
          color: isDarkMode ? const Color(0x0DFFFFFF) : const Color(0x0D000000),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode ? const Color(0x14FFFFFF) : const Color(0x29000000),
            offset: const Offset(1, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    stock.logo.isNotEmpty
                        ? stock.logo
                        : (stock.symbol.isNotEmpty ? stock.symbol[0] : ''),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    displayPrice,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  changeText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  pointsText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: changeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            height: 28,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  isNegative
                      ? (isDarkMode
                          ? const Color(0x1AFF5252)
                          : const Color(0x1AFF5252))
                      : (isDarkMode
                          ? NerveColors.chartbgGreenDark
                          : NerveColors.chartbgGreenLigth),
              borderRadius: isDarkMode ? null : BorderRadius.circular(6),
            ),
            child: CustomPaint(
              painter: SparklinePainter(
                const [
                  Offset(0.0, 0.5),
                  Offset(0.2, 0.6),
                  Offset(0.4, 0.3),
                  Offset(0.6, 0.7),
                  Offset(0.8, 0.4),
                  Offset(1.0, 0.5),
                ],
                isNegative
                    ? (isDarkMode ? Colors.red.shade300 : Colors.red)
                    : (isDarkMode ? Colors.green.shade300 : Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'B',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    stock.minPrice,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'A',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    stock.maxPrice,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget topPositionView(bool isDarkMode, DashboardService proValue) {
    final topPositions = proValue.topPositions;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NerveColors.primaryColor(isDarkMode),
        border: Border(
          top: BorderSide(
            color:
                isDarkMode
                    ? const Color(0xFF202220)
                    : NerveColors.containerBorderColor,
            width: 1,
          ),
          bottom: BorderSide(
            color:
                isDarkMode
                    ? const Color(0xFF202220)
                    : NerveColors.containerBorderColor,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Positions',
                  style: _dashboardHeadingStyle(isDarkMode),
                ),
                Text('Show All', style: NerveStyles.blue_bold_12(isDarkMode)),
              ],
            ),
            const SizedBox(height: 6),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topPositions.length,
              itemBuilder: (context, index) {
                final item = topPositions[index];
                final isNegative = item.value.contains('-');
                final valueText =
                    item.value.startsWith('+') || item.value.startsWith('-')
                        ? item.value
                        : '+ ${item.value}';
                final valueColor =
                    isNegative
                        ? (isDarkMode ? Colors.red.shade300 : Colors.red)
                        : (isDarkMode ? Colors.teal.shade200 : Colors.teal);

                return Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            isDarkMode
                                ? const Color(0xFF202220)
                                : NerveColors.containerBorderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item.symbol,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      item.type.toUpperCase() == 'SELL'
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : Colors.teal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.type,
                                  style: TextStyle(
                                    color:
                                        item.type.toUpperCase() == 'SELL'
                                            ? Colors.red
                                            : Colors.teal,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? NerveColors.chartbgGreenDark
                                      : NerveColors.chartbgGreenLigth,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: SvgPicture.asset(
                              'lib/Resources/Images/line_chart.svg',
                              width: 120,
                              height: 22,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            valueText,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: valueColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Qty: ${item.quantity}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.grey[200] : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Avg: ${item.avgPrice}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.grey[200] : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'LTP: ${item.ltp}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.grey[200] : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget trendingView(
    BuildContext context,
    bool isDarkMode,
    DashboardService proValue,
  ) {
    final List<String> trendingTabs = [
      'Trending',
      'Gainers',
      'Losers',
      'Volume Mover',
    ];

    final displayedStocks = proValue.marketUpdates;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NerveColors.primaryColor(isDarkMode),
        border: Border(
          top: BorderSide(
            color:
                isDarkMode
                    ? const Color(0xFF202220)
                    : NerveColors.containerBorderColor,
            width: 1,
          ),
          bottom: BorderSide(
            color:
                isDarkMode
                    ? const Color(0xFF202220)
                    : NerveColors.containerBorderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(trendingTabs.length, (index) {
                final isSelected = index == proValue.selectedTrendingCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      proValue.setSelectedTrendingCategory(index);
                      proValue.callMarketUpdates(
                        context,
                        category: trendingTabs[index].toLowerCase(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? NerveColors.trendingBadgeBG
                                : (isDarkMode
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFF2F2F2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        trendingTabs[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? NerveColors.trendingBadgeText
                                  : (isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          if (proValue.isMarketUpdatesLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (proValue.marketUpdatesError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                proValue.marketUpdatesError!,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            )
          else if (displayedStocks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No market updates available.',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            )
          else
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 22,
                childAspectRatio: 1.1,
              ),
              itemCount: displayedStocks.length,
              itemBuilder: (context, index) {
                final stock = displayedStocks[index];
                final isPositive = stock.percentageChange >= 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => StockDetailsPage.fromStockItem(stock),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? const Color(0xFF1C1E1D) : Colors.white,
                      border: Border.all(
                        width: 1,
                        color:
                            isDarkMode
                                ? const Color(0x0DFFFFFF)
                                : const Color(0x0D000000),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDarkMode
                                  ? const Color(0x14FFFFFF)
                                  : const Color(0x29000000),
                          offset: const Offset(1, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? const Color(0xFF2A2A2A)
                                        : const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  stock.symbol.isNotEmpty
                                      ? stock.symbol[0]
                                      : '-',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stock.symbol,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '\$${stock.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${isPositive ? '+' : ''}${stock.percentageChange.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isPositive
                                                ? (isDarkMode
                                                    ? Colors.green.shade300
                                                    : Colors.green.shade600)
                                                : (isDarkMode
                                                    ? Colors.red.shade300
                                                    : Colors.red.shade600),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '%',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isPositive
                                                ? (isDarkMode
                                                    ? Colors.green.shade300
                                                    : Colors.green.shade600)
                                                : (isDarkMode
                                                    ? Colors.red.shade300
                                                    : Colors.red.shade600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '(${isPositive ? '+' : ''}${stock.pointsChange.toStringAsFixed(2)} pts)',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      isPositive
                                          ? (isDarkMode
                                              ? Colors.green.shade300
                                              : Colors.green.shade600)
                                          : (isDarkMode
                                              ? Colors.red.shade300
                                              : Colors.red.shade600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 24,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                isPositive
                                    ? (isDarkMode
                                        ? const Color(0xFF2A3A32)
                                        : const Color(0xFFEAF7F0))
                                    : (isDarkMode
                                        ? const Color(0xFF3A2A2A)
                                        : const Color(0xFFF7EAEA)),
                            borderRadius:
                                isDarkMode ? null : BorderRadius.circular(6),
                          ),
                          child: CustomPaint(
                            painter: SparklinePainter(
                              stock.sparklinePoints,
                              isPositive
                                  ? (isDarkMode
                                      ? Colors.green.shade300
                                      : Colors.green.shade600)
                                  : (isDarkMode
                                      ? Colors.red.shade300
                                      : Colors.red.shade600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'B',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  stock.bid.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'A',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  stock.ask.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Show All',
              style: NerveStyles.blue_bold_12(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget activityFeedView(bool isDarkMode, DashboardService dashboardService) {
    final activities = dashboardService.activityFeed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NerveColors.primaryColor(isDarkMode),
        border: Border(
          top: BorderSide(
            color:
                isDarkMode
                    ? const Color(0xFF202220)
                    : NerveColors.containerBorderColor,
            width: 1,
          ),
          bottom: BorderSide(
            color:
                isDarkMode
                    ? const Color(0xFF202220)
                    : NerveColors.containerBorderColor,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Activity Feed',
                  style: NerveStyles.black_medium_14_400(isDarkMode),
                ),
                Text('Show All', style: NerveStyles.blue_bold_12(isDarkMode)),
              ],
            ),
            const SizedBox(height: 16),
            if (dashboardService.isActivityFeedLoading)
              const Center(child: CircularProgressIndicator())
            else if (dashboardService.activityFeedError != null)
              Text(
                dashboardService.activityFeedError!,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
              )
            else if (activities.isEmpty)
              Text(
                'No activity available',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: activities.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  Color badgeColor;
                  Color badgeBG;

                  switch (activity.type) {
                    case 'complete':
                      badgeColor =
                          isDarkMode
                              ? const Color(0xFF00C087)
                              : NerveColors.activityCompleteBadgeColor;
                      badgeBG =
                          isDarkMode
                              ? Colors.transparent
                              : NerveColors.activityCompleteBadgeBG;
                      break;
                    case 'alert':
                      badgeColor =
                          isDarkMode
                              ? const Color(0xFFD39A00)
                              : NerveColors.activityAlertBadgeColor;
                      badgeBG =
                          isDarkMode
                              ? Colors.transparent
                              : NerveColors.activityAlertBadgeBG;
                      break;
                    case 'system':
                      badgeColor =
                          isDarkMode
                              ? const Color(0xFF6E8096)
                              : NerveColors.activitySystemBadgeColor;
                      badgeBG =
                          isDarkMode
                              ? Colors.transparent
                              : NerveColors.activitySystemBadgeBG;
                      break;
                    default:
                      badgeColor = Colors.grey;
                      badgeBG =
                          isDarkMode
                              ? Colors.transparent
                              : Colors.grey.shade100;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 32,
                          minWidth: 68,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBG,
                          border: Border.all(color: badgeColor, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            activity.statusText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activity.title,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<Offset> points;
  final Color lineColor;

  SparklinePainter(this.points, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points[0].dx * size.width, points[0].dy * size.height);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.lineColor != lineColor;
}
