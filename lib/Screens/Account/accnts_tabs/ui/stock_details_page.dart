import 'dart:async';
import 'dart:math' as math;

import 'package:intl/intl.dart';
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
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/model/trade_symbol_details_model.dart';
import 'package:century_cqg/Screens/Trade/service/trade_repository.dart';
import 'package:century_cqg/Screens/Trade/service/trade_use_cases.dart';
import 'package:century_cqg/Screens/Trade/ui/orders/modify_order.dart';

class StockDetailsProvider extends ChangeNotifier {
  StockDetailsProvider({TradeUseCases? useCases})
    : _useCases = useCases ?? TradeUseCases(TradeRepository());

  static const List<String> periods = [
    '1H',
    '1D',
    '5D',
    '1M',
    '1Y',
    '5Y',
    'MAX',
  ];

  final TradeUseCases _useCases;
  int _selectedPeriodIndex = 1; // "1D" active by default
  int _selectedTabIndex = 0; // "Overview" active by default
  String? _symbolName;
  TradeSymbolDetails? _symbolDetails;
  List<NetPositionDetail> _netPositionDetails = [];
  bool _isLoadingSymbolDetails = false;
  bool _isLoadingNetPositionDetails = false;
  String? _symbolDetailsError;
  String? _netPositionDetailsError;
  int _symbolRequestId = 0;
  int _netPositionRequestId = 0;

  int get selectedPeriodIndex => _selectedPeriodIndex;
  int get selectedTabIndex => _selectedTabIndex;
  String get selectedPeriod => periods[_selectedPeriodIndex];
  TradeSymbolDetails? get symbolDetails => _symbolDetails;
  List<NetPositionDetail> get netPositionDetails =>
      List.unmodifiable(_netPositionDetails);
  bool get isLoadingSymbolDetails => _isLoadingSymbolDetails;
  bool get isLoadingNetPositionDetails => _isLoadingNetPositionDetails;
  String? get symbolDetailsError => _symbolDetailsError;
  String? get netPositionDetailsError => _netPositionDetailsError;

  void loadSymbol(String symbolName) {
    if (_symbolName == symbolName) return;
    _symbolName = symbolName;
    unawaited(fetchSymbolDetails());
    unawaited(fetchNetPositionDetails());
  }

  void setSelectedPeriodIndex(int index) {
    if (index < 0 || index >= periods.length || _selectedPeriodIndex == index) {
      return;
    }
    _selectedPeriodIndex = index;
    notifyListeners();
    unawaited(fetchSymbolDetails());
  }

  void setSelectedTabIndex(int index) {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchSymbolDetails() async {
    final symbolName = _symbolName;
    if (symbolName == null || symbolName.isEmpty) return;
    final requestId = ++_symbolRequestId;
    _isLoadingSymbolDetails = true;
    _symbolDetailsError = null;
    notifyListeners();
    try {
      final details = await _useCases.fetchSymbolDetails(
        symbolName,
        period: selectedPeriod,
      );
      if (requestId == _symbolRequestId) _symbolDetails = details;
    } on Exception catch (error) {
      if (requestId == _symbolRequestId) _symbolDetailsError = error.toString();
    } finally {
      if (requestId == _symbolRequestId) {
        _isLoadingSymbolDetails = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchNetPositionDetails() async {
    final symbolName = _symbolName;
    if (symbolName == null || symbolName.isEmpty) return;
    final requestId = ++_netPositionRequestId;
    _isLoadingNetPositionDetails = true;
    _netPositionDetailsError = null;
    notifyListeners();
    try {
      final details = await _useCases.fetchNetPositionDetails(symbolName);
      if (requestId == _netPositionRequestId) {
        _netPositionDetails = details;
      }
    } on Exception catch (error) {
      if (requestId == _netPositionRequestId) {
        _netPositionDetailsError = error.toString();
      }
    } finally {
      if (requestId == _netPositionRequestId) {
        _isLoadingNetPositionDetails = false;
        notifyListeners();
      }
    }
  }
}

class StockDetailsPage extends StatefulWidget {
  final String symbol;
  final String name;

  const StockDetailsPage({
    super.key,
    required this.symbol,
    required this.name,
  });

  factory StockDetailsPage.fromStockItem(StockItem item) {
    return StockDetailsPage(
      symbol: item.symbol,
      name: item.name,
    );
  }

  factory StockDetailsPage.fromStock(Stock stock) {
    return StockDetailsPage(
      symbol: stock.symbol,
      name: stock.symbol,
    );
  }

  factory StockDetailsPage.fromWatchlistItem(WatchlistItem item) {
    return StockDetailsPage(
      symbol: item.symbol,
      name: item.companyName,
    );
  }

  @override
  State<StockDetailsPage> createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  static const List<String> _tabs = [
    'Overview',
    'Market Depth',
    'Details',
    'Option Chain',
  ];

  String get symbol => widget.symbol;
  String get name => widget.name;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StockDetailsProvider>().loadSymbol(symbol);
    });
  }

  @override
  void didUpdateWidget(covariant StockDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<StockDetailsProvider>().loadSymbol(symbol);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockDetailsProvider>(
      builder: (context, provider, _) {
        final isDarkMode = NerveBase().isDarkMode;
        final quote = provider.symbolDetails;
        final currentPrice = quote?.price;
        final currentPercentage = quote?.pricePercentage;
        final isPositive = (currentPercentage ?? 0) >= 0;
        final themeColor =
            isPositive
                ? (isDarkMode ? Colors.green.shade300 : const Color(0xFF27A374))
                : (isDarkMode ? Colors.red.shade300 : const Color(0xFFDB3D52));
        final sectionSeparatorColor =
            isDarkMode ? const Color(0xFF1E2421) : const Color(0xFFF6F6F6);
        final borderColor =
            isDarkMode ? const Color(0xFF202220) : const Color(0xFFEEEEEE);

        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF0D110F) : Colors.white,
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
                          currentPrice: currentPrice,
                          currentPercentage: currentPercentage,
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
                            provider: provider,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Time period selectors row
                        _buildTimePeriodSelector(provider, isDarkMode),

                        const SizedBox(height: 16),

                        // Section Separator (Divider Bar)
                        Container(height: 8, color: sectionSeparatorColor),

                        // Net Positions Section
                        _buildNetPositionsSection(provider, isDarkMode),

                        // Section Separator (Divider Bar)
                        Container(height: 16, color: sectionSeparatorColor),

                        // Custom Tabs Row: Overview, Market Depth, Details
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: borderColor, width: 1),
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
                                            (context) =>
                                                OptionChainPage(symbol: symbol),
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
                                                      : const Color(0xFF222222))
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
                          _buildMarketDepthContent(isDarkMode, provider)
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
                              onPressed:
                                  quote == null
                                      ? null
                                      : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ModifyOrderPage(
                                          symbolName: symbol,
                                          side: 'sell',
                                        ),
                                  ),
                                );
                              },
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
                                    Text(
                                      '\$${quote?.bid.toStringAsFixed(2) ?? '--'}',
                                      style: const TextStyle(
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
                              onPressed:
                                  quote == null
                                      ? null
                                      : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ModifyOrderPage(
                                          symbolName: symbol,
                                          side: 'buy',
                                        ),
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
                                    Text(
                                      '\$${quote?.ask.toStringAsFixed(2) ?? '--'}',
                                      style: const TextStyle(
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
    );
  }

  Widget _buildStockHeaderInfoCard({
    required BuildContext context,
    required bool isDarkMode,
    required Color themeColor,
    required double? currentPrice,
    required double? currentPercentage,
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
            currentPrice == null
                ? '--'
                : '\$${currentPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xB2000000),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            currentPercentage == null
                ? '--'
                : '${currentPercentage >= 0 ? '+' : ''}${currentPercentage.toStringAsFixed(2)}%',
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
              children: List.generate(
                StockDetailsProvider.periods.length,
                (index) {
                final period = StockDetailsProvider.periods[index];
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
    required StockDetailsProvider provider,
  }) {
    final points = provider.symbolDetails?.chartPoints ?? const [];
    if (provider.isLoadingSymbolDetails && points.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.symbolDetailsError != null && points.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.symbolDetailsError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
              ),
            ),
            TextButton(
              onPressed: provider.fetchSymbolDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (points.isEmpty) {
      return Center(
        child: Text(
          'No chart data available.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
          ),
        ),
      );
    }

    final spots = List<FlSpot>.generate(
      points.length,
      (index) => FlSpot(index.toDouble(), points[index].price),
      growable: false,
    );
    final minPrice = points.map((point) => point.price).reduce(math.min);
    final maxPrice = points.map((point) => point.price).reduce(math.max);
    final priceRange = maxPrice - minPrice;
    final padding =
        priceRange > 0
            ? priceRange * 0.1
            : math.max(minPrice.abs() * 0.005, 0.01);
    final minY = minPrice - padding;
    final maxY = maxPrice + padding;
    final interval = (maxY - minY) / 4;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
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
              interval: interval,
              getTitlesWidget: (value, meta) {
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    points[index].displayDate,
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
                return LineTooltipItem(
                  '\$${spot.y.toStringAsFixed(2)}',
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
            isCurved: false,
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

  Widget _buildNetPositionsSection(
    StockDetailsProvider provider,
    bool isDarkMode,
  ) {
    final numberFormat = NumberFormat('#,##0.##');
    final priceFormat = NumberFormat('#,##0.00');
    final pnlFormat = NumberFormat('#,##0.00;-#,##0.00');
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
          if (provider.isLoadingNetPositionDetails &&
              provider.netPositionDetails.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (provider.netPositionDetailsError != null &&
              provider.netPositionDetails.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.netPositionDetailsError!,
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.white70
                            : const Color(0xFF666666),
                  ),
                ),
                TextButton(
                  onPressed: provider.fetchNetPositionDetails,
                  child: const Text('Retry'),
                ),
              ],
            )
          else if (provider.netPositionDetails.isEmpty)
            Text(
              'No open positions for $symbol.',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
              ),
            )
          else
            ...provider.netPositionDetails.map((position) {
              final pnl =
                  '${position.netPnl >= 0 ? '+' : ''}${pnlFormat.format(position.netPnl)}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPositionRow(
                  position.side,
                  numberFormat.format(position.netUnit),
                  priceFormat.format(position.avgPrice),
                  pnl,
                  isDarkMode,
                ),
              );
            }),
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
    final sideColor =
        bs.toLowerCase() == 'buy'
            ? const Color(0xFF27A374)
            : const Color(0xFFDB3D52);
    final pnlColor =
        pnl.startsWith('-')
            ? const Color(0xFFDB3D52)
            : const Color(0xFF27A374);
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: sideColor,
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: pnlColor,
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

  Widget _buildMarketDepthContent(
    bool isDarkMode,
    StockDetailsProvider provider,
  ) {
    final quote = provider.symbolDetails;
    final bidData = [
      {
        'price': quote == null ? '--' : quote.bid.toStringAsFixed(2),
        'qty': '--',
        'total': '--',
      },
    ];
    final askData = [
      {
        'price': quote == null ? '--' : quote.ask.toStringAsFixed(2),
        'qty': '--',
        'total': '--',
      },
    ];
    final spread = quote == null ? null : quote.ask - quote.bid;
    final spreadPercentage =
        quote == null || quote.price == 0
            ? null
            : ((quote.ask - quote.bid) / quote.price) * 100;

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
                  spread == null ? '--' : '\$${spread.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF222222),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  spreadPercentage == null
                      ? ''
                      : '(${spreadPercentage.toStringAsFixed(2)}%)',
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
                      '--',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF27A374),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '--',
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
                      '--',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFDB3D52),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '--',
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
