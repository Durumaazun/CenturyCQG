import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Screens/Dashboard/model/stocks_detail_model.dart';
import 'package:century_cqg/Screens/Dashboard/model/dashboard_models.dart';
import 'package:century_cqg/Screens/Watchlist/model/watchlist_item.dart';
import 'package:century_cqg/Screens/OptionChain/ui/option_chain_content.dart';
import 'package:century_cqg/Screens/OptionChain/ui/option_chain_page.dart';
import 'package:century_cqg/Screens/OptionChain/provider/option_chain_provider.dart';
import 'package:century_cqg/Screens/Trade/ui/orders/modify_order.dart';

class StockDetailsProvider extends ChangeNotifier {
  int _selectedPeriodIndex = 1; // "1D" active by default
  int _selectedTabIndex = 0; // "Overview" active by default

  int get selectedPeriodIndex => _selectedPeriodIndex;
  int get selectedTabIndex => _selectedTabIndex;

  void setSelectedPeriodIndex(int index) {
    if (_selectedPeriodIndex == index) return;
    _selectedPeriodIndex = index;
    notifyListeners();
  }

  void setSelectedTabIndex(int index) {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
  }
}

class StockDetailsPage extends StatelessWidget {
  final String symbol;
  final String name;
  final double price;
  final double percentageChange;
  final double pointsChange;
  final double bid;
  final double ask;
  final List<Offset>? sparklinePoints;

  const StockDetailsPage({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.percentageChange,
    required this.pointsChange,
    required this.bid,
    required this.ask,
    this.sparklinePoints,
  });

  factory StockDetailsPage.fromStockItem(StockItem item) {
    return StockDetailsPage(
      symbol: item.symbol,
      name: item.name,
      price: item.price,
      percentageChange: item.percentageChange,
      pointsChange: item.pointsChange,
      bid: item.bid,
      ask: item.ask,
      sparklinePoints: item.sparklinePoints,
    );
  }

  factory StockDetailsPage.fromStock(Stock stock) {
    final stockPrice =
        double.tryParse(stock.price.replaceAll(RegExp(r'[^\d.]'), '')) ??
        577.87;
    final stockChange =
        double.tryParse(stock.change.replaceAll(RegExp(r'[^\d.-]'), '')) ??
        3.76;
    final stockPoints =
        double.tryParse(
          stock.changePoints.replaceAll(RegExp(r'[^\d.-]'), ''),
        ) ??
        4.89;
    final min =
        double.tryParse(stock.minPrice.replaceAll(RegExp(r'[^\d.-]'), '')) ??
        1125.08;
    final max =
        double.tryParse(stock.maxPrice.replaceAll(RegExp(r'[^\d.-]'), '')) ??
        1130.04;
    return StockDetailsPage(
      symbol: stock.symbol,
      name:
          stock.symbol == 'AAPL'
              ? 'Apple Inc.'
              : stock.symbol == 'TSLA'
              ? 'Tesla Motors'
              : stock.symbol == 'NVDA'
              ? 'NVIDIA Corp'
              : '${stock.symbol} Inc.',
      price: stockPrice,
      percentageChange: stockChange,
      pointsChange: stockPoints,
      bid: min,
      ask: max,
    );
  }

  factory StockDetailsPage.fromWatchlistItem(WatchlistItem item) {
    return StockDetailsPage(
      symbol: item.symbol,
      name: item.companyName,
      price: item.price,
      percentageChange: item.changePercent,
      pointsChange: item.price * 0.08,
      bid: item.price + 552.17,
      ask: item.price + 547.21,
    );
  }

  static const List<String> _periods = [
    "1H",
    "1D",
    "5D",
    "1M",
    "1Y",
    "5Y",
    "MAX",
  ];
  static const List<String> _tabs = [
    "Overview",
    "Market Depth",
    "Details",
    "Option Chain",
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StockDetailsProvider>(
      create: (_) => StockDetailsProvider(),
      child: Consumer<StockDetailsProvider>(
        builder: (context, provider, _) {
          final isDarkMode = NerveBase().isDarkMode;
          final isPositive = percentageChange >= 0;
          final themeColor =
              isPositive
                  ? (isDarkMode
                      ? Colors.green.shade300
                      : const Color(0xFF27A374))
                  : (isDarkMode
                      ? Colors.red.shade300
                      : const Color(0xFFDB3D52));
          final sectionSeparatorColor =
              isDarkMode ? const Color(0xFF1E2421) : const Color(0xFFF6F6F6);
          final borderColor =
              isDarkMode ? const Color(0xFF202220) : const Color(0xFFEEEEEE);

          return Scaffold(
            backgroundColor:
                isDarkMode ? const Color(0xFF0D110F) : Colors.white,
            appBar: AppBar(
              backgroundColor:
                  isDarkMode ? const Color(0xFF0D110F) : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDarkMode ? Colors.white : const Color(0xB2000000),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                symbol,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xB2000000),
                ),
              ),
              centerTitle: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(8),
                child: Container(height: 8, color: sectionSeparatorColor),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stock Header Info Card
                          _buildStockHeaderInfoCard(
                            context: context,
                            isDarkMode: isDarkMode,
                            themeColor: themeColor,
                          ),

                          const SizedBox(height: 16),

                          // Interactive fl_chart Chart Section
                          Container(
                            height: 184,
                            width: double.infinity,
                            padding: const EdgeInsets.only(right: 16, left: 16),
                            child: _buildFlChart(
                              themeColor: themeColor,
                              isDarkMode: isDarkMode,
                              selectedPeriodIndex: provider.selectedPeriodIndex,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Time period selectors row
                          _buildTimePeriodSelector(provider, isDarkMode),

                          const SizedBox(height: 16),

                          // Section Separator (Divider Bar)
                          Container(height: 8, color: sectionSeparatorColor),

                          // Net Positions Section
                          _buildNetPositionsSection(isDarkMode),

                          // Section Separator (Divider Bar)
                          Container(height: 16, color: sectionSeparatorColor),

                          // Custom Tabs Row: Overview, Market Depth, Details
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(_tabs.length, (index) {
                                final tab = _tabs[index];
                                final isSelected =
                                    index == provider.selectedTabIndex;
                                return GestureDetector(
                                  onTap: () {
                                    if (index == 3) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => OptionChainPage(
                                                symbol: symbol,
                                              ),
                                        ),
                                      );
                                    } else {
                                      provider.setSelectedTabIndex(index);
                                    }
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          tab,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? (isDarkMode
                                                        ? Colors.white
                                                        : const Color(
                                                          0xFF222222,
                                                        ))
                                                    : (isDarkMode
                                                        ? Colors.white38
                                                        : const Color(
                                                          0xFF888888,
                                                        )),
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 3,
                                        width: 80,
                                        color:
                                            isSelected
                                                ? const Color(0xFFFFC600)
                                                : Colors.transparent,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tab View Content (Depending on selected tab index, default shows Overview)
                          if (provider.selectedTabIndex == 0)
                            _buildOverviewTabContent(isDarkMode)
                          else if (provider.selectedTabIndex == 1)
                            _buildMarketDepthContent(isDarkMode)
                          else if (provider.selectedTabIndex == 2)
                            _buildDetailsTabContent(isDarkMode)
                          else if (provider.selectedTabIndex == 3)
                            _buildOptionChainContent(isDarkMode),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  if (provider.selectedTabIndex != 3) ...[
                    // Fixed Pinned Action Buttons: SELL and BUY at bottom
                    Container(height: 1, color: sectionSeparatorColor),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? const Color(0xFF0D110F) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDB3D52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'SELL',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '\$184.0',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ModifyOrderPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF27A374),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'BUY',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '\$184.0',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStockHeaderInfoCard({
    required BuildContext context,
    required bool isDarkMode,
    required Color themeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                symbol.isNotEmpty ? symbol[0] : '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xB2000000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            symbol,
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xB2000000),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xB2000000),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(2)}%',
            style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider<OptionChainNotifier>(
                            create: (_) => OptionChainNotifier(),
                          ),
                          Provider<OptionChainState>(
                            create: (_) => OptionChainState(),
                          ),
                        ],
                        child: OptionChainPage(symbol: symbol),
                      ),
                ),
              );
            },
            child: Transform.rotate(
              angle: 4.712389, // 270 degrees
              child: Icon(
                Icons.link,
                size: 24,
                color: isDarkMode ? Colors.white70 : const Color(0xB2000000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector(
    StockDetailsProvider provider,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_periods.length, (index) {
                final period = _periods[index];
                final isSelected = index == provider.selectedPeriodIndex;
                return GestureDetector(
                  onTap: () {
                    provider.setSelectedPeriodIndex(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFFFC600)
                              : (isDarkMode
                                  ? const Color(0xFF1E2421)
                                  : const Color(0xFFF2F2F2)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        color:
                            isSelected
                                ? const Color(0xB2000000)
                                : (isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF666666)),
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.open_in_full,
            size: 16,
            color: isDarkMode ? Colors.white70 : const Color(0xB2000000),
          ),
        ],
      ),
    );
  }

  Widget _buildFlChart({
    required Color themeColor,
    required bool isDarkMode,
    required int selectedPeriodIndex,
  }) {
    final spots = _getDummySpotsForPeriod(selectedPeriodIndex);
    final bottomTitles = _getBottomTitlesForPeriod(selectedPeriodIndex);

    return LineChart(
      LineChartData(
        minY: 0.718,
        maxY: 0.782,
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 0.015,
              getTitlesWidget: (value, meta) {
                if (value < 0.719 || value > 0.781) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isDarkMode ? Colors.white38 : const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (spots.length - 1) / (bottomTitles.length - 1),
              getTitlesWidget: (value, meta) {
                final step = (spots.length - 1) / (bottomTitles.length - 1);
                final index = (value / step).round();
                if (index < 0 || index >= bottomTitles.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    bottomTitles[index],
                    style: TextStyle(
                      fontSize: 9,
                      color:
                          isDarkMode ? Colors.white38 : const Color(0xFF9E9E9E),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor:
                (touchedSpot) =>
                    isDarkMode ? const Color(0xFF1E2421) : Colors.white,
            tooltipBorder: BorderSide(
              color:
                  isDarkMode ? const Color(0xFF202220) : Colors.grey.shade300,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final ratio = spot.y / 0.75;
                final computedPrice = price * ratio;
                return LineTooltipItem(
                  '\$${computedPrice.toStringAsFixed(2)}',
                  TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xB2000000),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: themeColor,
            barWidth: 2.2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  themeColor.withValues(alpha: 0.22),
                  themeColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getDummySpotsForPeriod(int periodIndex) {
    // Default 1D curve matching screenshot wave
    const default1D = [
      FlSpot(0, 0.725),
      FlSpot(1, 0.748),
      FlSpot(2, 0.752),
      FlSpot(3, 0.742),
      FlSpot(4, 0.746),
      FlSpot(5, 0.736),
      FlSpot(6, 0.742),
      FlSpot(7, 0.754),
      FlSpot(8, 0.748),
      FlSpot(9, 0.756),
      FlSpot(10, 0.750),
      FlSpot(11, 0.744),
      FlSpot(12, 0.746),
      FlSpot(13, 0.735),
      FlSpot(14, 0.748),
      FlSpot(15, 0.755),
      FlSpot(16, 0.750),
      FlSpot(17, 0.754),
      FlSpot(18, 0.748),
      FlSpot(19, 0.750),
      FlSpot(20, 0.745),
      FlSpot(21, 0.762),
      FlSpot(22, 0.768),
      FlSpot(23, 0.761),
      FlSpot(24, 0.751),
      FlSpot(25, 0.750),
      FlSpot(26, 0.742),
      FlSpot(27, 0.749),
      FlSpot(28, 0.752),
      FlSpot(29, 0.741),
    ];

    switch (periodIndex) {
      case 0: // 1H
        return const [
          FlSpot(0, 0.745),
          FlSpot(1, 0.748),
          FlSpot(2, 0.742),
          FlSpot(3, 0.750),
          FlSpot(4, 0.755),
          FlSpot(5, 0.751),
          FlSpot(6, 0.758),
          FlSpot(7, 0.752),
          FlSpot(8, 0.760),
          FlSpot(9, 0.756),
        ];
      case 1: // 1D
        return default1D;
      case 2: // 5D
        return const [
          FlSpot(0, 0.730),
          FlSpot(1, 0.738),
          FlSpot(2, 0.745),
          FlSpot(3, 0.740),
          FlSpot(4, 0.752),
          FlSpot(5, 0.758),
          FlSpot(6, 0.754),
          FlSpot(7, 0.762),
          FlSpot(8, 0.766),
          FlSpot(9, 0.759),
        ];
      case 3: // 1M
        return const [
          FlSpot(0, 0.722),
          FlSpot(1, 0.730),
          FlSpot(2, 0.728),
          FlSpot(3, 0.740),
          FlSpot(4, 0.746),
          FlSpot(5, 0.742),
          FlSpot(6, 0.755),
          FlSpot(7, 0.760),
          FlSpot(8, 0.754),
          FlSpot(9, 0.765),
        ];
      case 4: // 1Y
        return const [
          FlSpot(0, 0.720),
          FlSpot(1, 0.728),
          FlSpot(2, 0.735),
          FlSpot(3, 0.745),
          FlSpot(4, 0.742),
          FlSpot(5, 0.756),
          FlSpot(6, 0.762),
          FlSpot(7, 0.758),
          FlSpot(8, 0.770),
          FlSpot(9, 0.764),
        ];
      case 5: // 5Y
        return const [
          FlSpot(0, 0.724),
          FlSpot(1, 0.732),
          FlSpot(2, 0.740),
          FlSpot(3, 0.738),
          FlSpot(4, 0.750),
          FlSpot(5, 0.755),
          FlSpot(6, 0.765),
          FlSpot(7, 0.772),
          FlSpot(8, 0.768),
          FlSpot(9, 0.775),
        ];
      default: // MAX
        return default1D;
    }
  }

  List<String> _getBottomTitlesForPeriod(int periodIndex) {
    switch (periodIndex) {
      case 0: // 1H
        return ["9:30", "10:00", "10:30", "11:00", "11:30"];
      case 1: // 1D
        return [
          "Sep 1",
          "Nov 1",
          "Nov 1",
          "Jan 1",
          "Mar 1",
          "Mar 1",
          "May 1",
          "May 1",
        ];
      case 2: // 5D
        return ["Mon", "Tue", "Wed", "Thu", "Fri"];
      case 3: // 1M
        return ["W1", "W2", "W3", "W4"];
      case 4: // 1Y
        return ["Q1", "Q2", "Q3", "Q4"];
      case 5: // 5Y
        return ["2022", "2023", "2024", "2025", "2026"];
      default:
        return [
          "Sep 1",
          "Nov 1",
          "Nov 1",
          "Jan 1",
          "Mar 1",
          "Mar 1",
          "May 1",
          "May 1",
        ];
    }
  }

  Widget _buildNetPositionsSection(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$symbol Net Positions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF222222),
                ),
              ),
              Text(
                'View All',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF155DFC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Net Positions Rows with individual headers matching design
          _buildPositionRow(
            "Buy",
            "20,000",
            "66,000.66",
            "+13,000.40",
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildPositionRow(
            "Buy",
            "20,000",
            "66,000.66",
            "+13,000.40",
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildPositionHeaderLabel(String label, bool isDarkMode) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: isDarkMode ? Colors.white38 : const Color(0x80000000),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildPositionRow(
    String bs,
    String units,
    String avgPrice,
    String pnl,
    bool isDarkMode,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPositionHeaderLabel("B/S", isDarkMode),
              const SizedBox(height: 4),
              Text(
                bs,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF27A374),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPositionHeaderLabel("Net Units", isDarkMode),
              const SizedBox(height: 4),
              Text(
                units,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xB2000000),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPositionHeaderLabel("Avg. Price", isDarkMode),
              const SizedBox(height: 4),
              Text(
                avgPrice,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPositionHeaderLabel("Net P&L", isDarkMode),
              const SizedBox(height: 4),
              Text(
                pnl,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF27A374),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTabContent(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About $name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xB2000000),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewMetaColumn("Description", name, isDarkMode),
              _buildOverviewMetaColumn("Type", "Shares", isDarkMode),
              _buildOverviewMetaColumn("Country", "USA", isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetaColumn(String label, String value, bool isDarkMode) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? Colors.white38 : const Color(0x80000000),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? Colors.white70 : const Color(0xB2000000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketDepthContent(bool isDarkMode) {
    final bidData = [
      {'price': '164.60', 'qty': '3.2K', 'total': '2.9K'},
      {'price': '164.55', 'qty': '5.1K', 'total': '4.6K'},
      {'price': '164.50', 'qty': '8.7K', 'total': '7.2K'},
      {'price': '164.45', 'qty': '2.4K', 'total': '3.8K'},
      {'price': '164.40', 'qty': '6.1K', 'total': '5.5K'},
    ];

    final askData = [
      {'price': '164.70', 'qty': '3.2K', 'total': '2.9K'},
      {'price': '164.75', 'qty': '5.1K', 'total': '4.6K'},
      {'price': '164.80', 'qty': '8.7K', 'total': '7.2K'},
      {'price': '164.85', 'qty': '2.4K', 'total': '3.8K'},
      {'price': '164.90', 'qty': '6.1K', 'total': '5.5K'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Depth',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xB2000000),
            ),
          ),
          const SizedBox(height: 16),

          // Column Headers
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'BID PRICE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color:
                          isDarkMode ? Colors.white38 : const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'QTY • TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color:
                            isDarkMode
                                ? Colors.white38
                                : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'TOTAL • QTY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color:
                            isDarkMode
                                ? Colors.white38
                                : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ASK PRICE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color:
                            isDarkMode
                                ? Colors.white38
                                : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Market Depth Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bidData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final bid = bidData[index];
              final ask = askData[index];

              return Row(
                children: [
                  // BID PRICE - Green background
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? const Color(0xFF1A3D2D)
                                : const Color(0xFFE8F5E9),
                      ),
                      child: Text(
                        bid['price']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF27A374),
                        ),
                      ),
                    ),
                  ),
                  // QTY • TOTAL - Green background
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? const Color(0xFF1A3D2D)
                                : const Color(0xFFE8F5E9),
                      ),
                      child: Center(
                        child: Text(
                          '${bid['qty']!} • ${bid['total']!}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color:
                                isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // TOTAL • QTY - Red background
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? const Color(0xFF3D1A2D)
                                : const Color(0xFFFEE0E6),
                      ),
                      child: Center(
                        child: Text(
                          '${ask['total']!} • ${ask['qty']!}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color:
                                isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ASK PRICE - Red background
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? const Color(0xFF3D1A2D)
                                : const Color(0xFFFEE0E6),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          ask['price']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFDB3D52),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Spread Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SPREAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        isDarkMode ? Colors.white38 : const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$0.10',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF222222),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(0.06%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color:
                        isDarkMode ? Colors.white38 : const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Total Volume Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BID VOLUME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color:
                            isDarkMode
                                ? Colors.white38
                                : const Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '25,500',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF27A374),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$4.20M',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color:
                            isDarkMode
                                ? Colors.white38
                                : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL ASK VOLUME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color:
                            isDarkMode
                                ? Colors.white38
                                : const Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '24,000',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFDB3D52),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$3.96M',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color:
                            isDarkMode
                                ? Colors.white38
                                : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Order Flow Pressure Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER FLOW PRESSURE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white38 : const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 54,
                      child: Container(color: const Color(0xFF27A374)),
                    ),
                    Expanded(
                      flex: 46,
                      child: Container(color: const Color(0xFFDB3D52)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF27A374),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '54% Buy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF27A374),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDB3D52),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '46% Sell',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFDB3D52),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTabContent(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trading / Position Limits Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trading / Position Limits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xB2000000),
                  ),
                ),
                Icon(
                  Icons.expand_less,
                  color: isDarkMode ? Colors.white70 : const Color(0xB2000000),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ORDER TYPE Section
          Text(
            'ORDER TYPE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 16 / 14,
              letterSpacing: 0,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Limit
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC600),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Limit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isDarkMode ? Colors.white : const Color(0xB2000000),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              // Market
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC600),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Market',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isDarkMode ? Colors.white : const Color(0xB2000000),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              // Stop
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC600),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stop',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isDarkMode ? Colors.white : const Color(0xB2000000),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // POSITION LIMITS Section
          Text(
            'POSITION LIMITS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 16 / 14,
              letterSpacing: 0,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          // Trade Quantity
          _buildDetailsRow('Trade Quantity', '0.1 - 984.0 Units', isDarkMode),
          const SizedBox(height: 16),

          // Max Position Limit
          _buildDetailsRow('Max Position Limit*', '44,288.0 Units', isDarkMode),
          const SizedBox(height: 16),

          // Limit and Stop Level
          _buildDetailsRow('Limit and Stop Level', '20 Points', isDarkMode),
          const SizedBox(height: 16),

          // Commission
          _buildDetailsRow(
            'Commission',
            '0.32% per unit (10 USD min)',
            isDarkMode,
          ),
          const SizedBox(height: 16),

          // Trading Hours
          _buildDetailsRow(
            'Trading Hours',
            '11:03AM - 7:00PM (Mon, Tue, Fri)',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.0,
            letterSpacing: 0,
            color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.0,
            letterSpacing: 0,
            color: isDarkMode ? Colors.white : const Color(0xB2000000),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChainContent(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      child: OptionChainContent(symbol: symbol),
    );
  }
}
