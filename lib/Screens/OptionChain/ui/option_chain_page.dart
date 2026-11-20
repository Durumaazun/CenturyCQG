import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../service/option_chain_service.dart';
import '../provider/option_chain_provider.dart';
import 'basket_page.dart';
import 'order_pending_page.dart';

class OptionChainPage extends StatefulWidget {
  final String symbol;

  const OptionChainPage({super.key, required this.symbol});

  @override
  State<OptionChainPage> createState() => _OptionChainPageState();
}

class _OptionChainPageState extends State<OptionChainPage> {
  final ScrollController _headerLeftScrollController = ScrollController();
  final ScrollController _headerRightScrollController = ScrollController();
  final ScrollController _bodyLeftScrollController = ScrollController();
  final ScrollController _bodyRightScrollController = ScrollController();
  bool _isSyncing = false;

  static const double _columnWidth = 60.0;
  static const double _strikeWidth = 80.0;
  static const double _rowHeight = 44.0;
  static const double _spotPriceHeight = 44.0;
  static const double _headerHeight = 36.0;

  @override
  void initState() {
    super.initState();
    _headerLeftScrollController.addListener(
      () => _syncFromLeft(_headerLeftScrollController),
    );
    _bodyLeftScrollController.addListener(
      () => _syncFromLeft(_bodyLeftScrollController),
    );
    _headerRightScrollController.addListener(
      () => _syncFromRight(_headerRightScrollController),
    );
    _bodyRightScrollController.addListener(
      () => _syncFromRight(_bodyRightScrollController),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_bodyLeftScrollController.hasClients &&
          _bodyLeftScrollController.position.maxScrollExtent > 0) {
        _syncFromLeft(
          _bodyLeftScrollController,
          initialOffset: _bodyLeftScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _syncFromLeft(ScrollController source, {double? initialOffset}) {
    if (_isSyncing) return;
    _isSyncing = true;
    final offset = initialOffset ?? source.offset;
    final maxLeft = source.hasClients ? source.position.maxScrollExtent : 0.0;

    if (_headerLeftScrollController.hasClients &&
        _headerLeftScrollController != source) {
      _headerLeftScrollController.jumpTo(
        offset.clamp(0.0, _headerLeftScrollController.position.maxScrollExtent),
      );
    }
    if (_bodyLeftScrollController.hasClients &&
        _bodyLeftScrollController != source) {
      _bodyLeftScrollController.jumpTo(
        offset.clamp(0.0, _bodyLeftScrollController.position.maxScrollExtent),
      );
    }

    if (maxLeft > 0) {
      if (_headerRightScrollController.hasClients) {
        final maxRight = _headerRightScrollController.position.maxScrollExtent;
        final target = (maxLeft - offset).clamp(0.0, maxRight);
        _headerRightScrollController.jumpTo(target);
      }
      if (_bodyRightScrollController.hasClients) {
        final maxRight = _bodyRightScrollController.position.maxScrollExtent;
        final target = (maxLeft - offset).clamp(0.0, maxRight);
        _bodyRightScrollController.jumpTo(target);
      }
    }
    _isSyncing = false;
  }

  void _syncFromRight(ScrollController source) {
    if (_isSyncing) return;
    _isSyncing = true;
    final offset = source.offset;
    final maxRight = source.hasClients ? source.position.maxScrollExtent : 0.0;

    if (_headerRightScrollController.hasClients &&
        _headerRightScrollController != source) {
      _headerRightScrollController.jumpTo(
        offset.clamp(
          0.0,
          _headerRightScrollController.position.maxScrollExtent,
        ),
      );
    }
    if (_bodyRightScrollController.hasClients &&
        _bodyRightScrollController != source) {
      _bodyRightScrollController.jumpTo(
        offset.clamp(0.0, _bodyRightScrollController.position.maxScrollExtent),
      );
    }

    if (maxRight > 0) {
      if (_headerLeftScrollController.hasClients) {
        final maxLeft = _headerLeftScrollController.position.maxScrollExtent;
        final target = (maxRight - offset).clamp(0.0, maxLeft);
        _headerLeftScrollController.jumpTo(target);
      }
      if (_bodyLeftScrollController.hasClients) {
        final maxLeft = _bodyLeftScrollController.position.maxScrollExtent;
        final target = (maxRight - offset).clamp(0.0, maxLeft);
        _bodyLeftScrollController.jumpTo(target);
      }
    }
    _isSyncing = false;
  }

  @override
  void dispose() {
    _headerLeftScrollController.dispose();
    _headerRightScrollController.dispose();
    _bodyLeftScrollController.dispose();
    _bodyRightScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'OPTION CHAIN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: SafeArea(
        child: Consumer<OptionChainNotifier>(
          builder: (context, notifierValue, _) {
            final state = notifierValue.state;
            final notifier = notifierValue;
            final optionChainData = OptionChainService().getOptionChainData();

            return Column(
              children: [
                const SizedBox(height: 12),
                _buildStockHeader(context, state, notifier, optionChainData),
                _buildTopSectionBanner(),
                // Pinned Fixed Header Row (Horizontal scroll only, never scrolls vertically)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _headerLeftScrollController,
                        child: SizedBox(
                          width: _columnWidth * 6,
                          child: _buildCallHeader(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _strikeWidth,
                      child: _buildStrikeHeader(state, notifier),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _headerRightScrollController,
                        child: SizedBox(
                          width: _columnWidth * 6,
                          child: _buildPutHeader(),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side: CALLS (CE) - Synchronized Horizontal Scroll
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _bodyLeftScrollController,
                            child: SizedBox(
                              width: _columnWidth * 6,
                              child: Column(
                                children: [
                                  ...List.generate(optionChainData.length, (
                                    index,
                                  ) {
                                    final data = optionChainData[index];
                                    final isSelected =
                                        state.basketEnabled
                                            ? state.basketRows.contains(index)
                                            : (state.selectedRowIndex ==
                                                    index &&
                                                state.selectedType == 'call');
                                    return Column(
                                      children: [
                                        if (data['highlight'] == true &&
                                            state.showSpotPrice)
                                          Container(
                                            height: _spotPriceHeight,
                                            color: Colors.white,
                                          ),
                                        _buildCallRow(data, isSelected, () {
                                          if (state.basketEnabled) {
                                            if (state.basketRows.contains(
                                              index,
                                            )) {
                                              notifier.removeBasketRow(index);
                                            } else {
                                              notifier.addBasketRow(index);
                                            }
                                          } else {
                                            if (state.selectedRowIndex ==
                                                    index &&
                                                state.selectedType == 'call') {
                                              notifier.clearSelection();
                                            } else {
                                              notifier.setSelectedRowAndType(
                                                index,
                                                'call',
                                              );
                                            }
                                          }
                                        }),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Center: FIXED STRIKE (Pinned - does not move horizontally)
                        SizedBox(
                          width: _strikeWidth,
                          child: Column(
                            children: [
                              ...List.generate(optionChainData.length, (index) {
                                final data = optionChainData[index];
                                final isSelected =
                                    state.basketEnabled
                                        ? state.basketRows.contains(index)
                                        : (state.selectedRowIndex == index);
                                return Column(
                                  children: [
                                    if (data['highlight'] == true &&
                                        state.showSpotPrice)
                                      _buildCenterSpotPriceCell(),
                                    _buildStrikeCell(data, isSelected, () {
                                      if (state.basketEnabled) {
                                        if (state.basketRows.contains(index)) {
                                          notifier.removeBasketRow(index);
                                        } else {
                                          notifier.addBasketRow(index);
                                        }
                                      } else {
                                        if (state.selectedRowIndex == index) {
                                          notifier.clearSelection();
                                        } else {
                                          notifier.setSelectedRowAndType(
                                            index,
                                            state.selectedType,
                                          );
                                        }
                                      }
                                    }),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        // Right Side: PUTS (PE) - Synchronized Horizontal Scroll
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _bodyRightScrollController,
                            child: SizedBox(
                              width: _columnWidth * 6,
                              child: Column(
                                children: [
                                  ...List.generate(optionChainData.length, (
                                    index,
                                  ) {
                                    final data = optionChainData[index];
                                    final isSelected =
                                        state.basketEnabled
                                            ? state.basketRows.contains(index)
                                            : (state.selectedRowIndex ==
                                                    index &&
                                                state.selectedType == 'put');
                                    return Column(
                                      children: [
                                        if (data['highlight'] == true &&
                                            state.showSpotPrice)
                                          Container(
                                            height: _spotPriceHeight,
                                            color: Colors.white,
                                          ),
                                        _buildPutRow(data, isSelected, () {
                                          if (state.basketEnabled) {
                                            if (state.basketRows.contains(
                                              index,
                                            )) {
                                              notifier.removeBasketRow(index);
                                            } else {
                                              notifier.addBasketRow(index);
                                            }
                                          } else {
                                            if (state.selectedRowIndex ==
                                                    index &&
                                                state.selectedType == 'put') {
                                              notifier.clearSelection();
                                            } else {
                                              notifier.setSelectedRowAndType(
                                                index,
                                                'put',
                                              );
                                            }
                                          }
                                        }),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.basketEnabled)
                  _buildBasketSummaryBar(
                    context,
                    state,
                    notifier,
                    optionChainData,
                    widget.symbol,
                  )
                else if (state.selectedRowIndex != null)
                  _buildSingleOptionActionBar(
                    context,
                    state,
                    notifier,
                    optionChainData,
                    widget.symbol,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopSectionBanner() {
    return Container(
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'CALLS (CE)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 14, color: Colors.grey[400]),
          const SizedBox(
            width: _strikeWidth,
            child: Center(
              child: Text(
                'STRIKE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 14, color: Colors.grey[400]),
          const Expanded(
            child: Center(
              child: Text(
                'PUTS (PE)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallHeader() {
    return Container(
      height: _headerHeight,
      color: const Color(0xFFFFF8E1),
      child: Row(
        children: const [
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'VEGA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'GAMMA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'THETA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'DELTA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'OI',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'LTP',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrikeHeader(
    OptionChainState state,
    OptionChainNotifier notifier,
  ) {
    return Container(
      height: _headerHeight,
      color: const Color(0xFFFFF8E1),
      alignment: Alignment.center,
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFC600),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: DropdownButton<String>(
          underline: Container(),
          isDense: true,
          value: state.selectedExpirationDate,
          icon: const Icon(Icons.expand_more, size: 12),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
          items:
              ['JUN 20', 'JUL 20', 'AUG 20'].map((date) {
                return DropdownMenuItem<String>(value: date, child: Text(date));
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              notifier.setSelectedExpirationDate(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPutHeader() {
    return Container(
      height: _headerHeight,
      color: const Color(0xFFFFF8E1),
      child: Row(
        children: const [
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'LTP',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'OI',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'DELTA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'THETA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'GAMMA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: _columnWidth,
            child: Center(
              child: Text(
                'VEGA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallRow(
    Map<String, dynamic> data,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _rowHeight,
        color:
            isSelected
                ? const Color(0xFFFFC600).withValues(alpha: 0.4)
                : Colors.white,
        child: Row(
          children: [
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['callVega']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['callGamma']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['callTheta']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['callDelta']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['callOI']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['callLTP']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterSpotPriceCell() {
    return Container(
      height: _spotPriceHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Spot Price 163',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Text(
              '+20.4 (+13.4%)',
              style: TextStyle(
                fontSize: 9,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrikeCell(
    Map<String, dynamic> data,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _rowHeight,
        color:
            isSelected
                ? const Color(0xFFFFC600).withValues(alpha: 0.4)
                : (data['highlight'] == true
                    ? const Color(0xFFFFF9C4)
                    : const Color(0xFFF9F9F9)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${data['strikePrice']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (data['label'] != null)
                Text(
                  data['label'],
                  style: TextStyle(
                    fontSize: 8,
                    color: data['labelColor'] ?? Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPutRow(
    Map<String, dynamic> data,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _rowHeight,
        color:
            isSelected
                ? const Color(0xFFFFC600).withValues(alpha: 0.4)
                : Colors.white,
        child: Row(
          children: [
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['putLTP']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['putOI']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['putDelta']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['putTheta']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['putGamma']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            SizedBox(
              width: _columnWidth,
              child: Center(
                child: Text(
                  '${data['putVega']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockHeader(
    BuildContext context,
    OptionChainState state,
    OptionChainNotifier notifier,
    List<Map<String, dynamic>> optionChainData,
  ) {
    return Container(
      color:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 4),
          // Stock Icon
          Container(
            width: 32,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                widget.symbol[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Stock Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '\$577.87',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '+3.76%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Icons
          IconButton(
            icon: SvgPicture.asset(
              'lib/Resources/Images/image_basket.svg',
              width: 28,
              height: 28,
            ),
            onPressed:
                state.basketRows.isNotEmpty
                    ? () {
                      BasketPage.show(
                        context,
                        symbol: widget.symbol,
                        selectedRows: state.basketRows.toList(),
                        optionChainData: optionChainData,
                      );
                    }
                    : null,
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: state.basketEnabled,
              onChanged: (val) {
                notifier.setBasketEnabled(val);
              },
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'lib/Resources/Images/boxicons_candlestick.svg',
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
            ),
            onPressed: () {
              notifier.clearSelection();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildBasketSummaryBar(
    BuildContext context,
    OptionChainState state,
    OptionChainNotifier notifier,
    List<Map<String, dynamic>> optionChainData,
    String symbol,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Max Loss',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '\$21,345.00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1DB854),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Max Profit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '\$113,711.00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1DB854),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'POP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '47%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Req Margin: \$21,345.00',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Balance: \$83,711.00',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  BasketPage.show(
                    context,
                    symbol: symbol,
                    selectedRows: state.basketRows.toList(),
                    optionChainData: optionChainData,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2C400),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: const Color(0xFFF2C400),
                  disabledForegroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Execute basket (${state.basketRows.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleOptionActionBar(
    BuildContext context,
    OptionChainState state,
    OptionChainNotifier notifier,
    List<Map<String, dynamic>> optionChainData,
    String symbol,
  ) {
    final selectedIndex = state.selectedRowIndex ?? 0;
    final selectedData =
        (selectedIndex >= 0 && selectedIndex < optionChainData.length)
            ? optionChainData[selectedIndex]
            : optionChainData.first;
    final strikePrice = selectedData['strikePrice'] ?? 550;
    final isPut = state.selectedType == 'put';
    final optionType = isPut ? 'Put' : 'Call';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Options Badge + Close Button
          Row(
            children: [
              Text(
                '$symbol 20 Jun $strikePrice $optionType',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2C400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => notifier.clearSelection(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats Row: Max Loss | Max Profit | POP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Max Loss',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '\$21,345.00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1DB854),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Max Profit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '\$113,711.00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1DB854),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'POP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '47%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  _buildMiniPayoffChart(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),

          // Margin & Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Req Margin: \$21,345.00',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const Text(
                'Balance: \$83,711.00',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons: SELL and BUY
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (sheetContext) {
                        return OrderPendingPage(
                          symbol: '$symbol 20 Jun $strikePrice $optionType',
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SELL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (sheetContext) {
                        return OrderPendingPage(
                          symbol: '$symbol 20 Jun $strikePrice $optionType',
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB854),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'BUY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPayoffChart() {
    return Container(
      width: 36,
      height: 22,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: CustomPaint(painter: _MiniPayoffPainter()),
    );
  }
}

class _MiniPayoffPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final axisPaint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.35)
          ..strokeWidth = 1.0;

    canvas.drawLine(Offset(w * 0.55, 0), Offset(w * 0.55, h), axisPaint);
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), axisPaint);

    final redAreaPaint =
        Paint()
          ..color = const Color(0xFFEF4444).withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
    final redPath =
        Path()
          ..moveTo(w * 0.1, h * 0.5)
          ..lineTo(w * 0.55, h * 0.5)
          ..lineTo(w * 0.1, h * 0.8)
          ..close();
    canvas.drawPath(redPath, redAreaPaint);

    final greenAreaPaint =
        Paint()
          ..color = const Color(0xFF1DB854).withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
    final greenPath =
        Path()
          ..moveTo(w * 0.55, h * 0.5)
          ..lineTo(w * 0.95, h * 0.5)
          ..lineTo(w * 0.95, h * 0.2)
          ..lineTo(w * 0.75, h * 0.2)
          ..close();
    canvas.drawPath(greenPath, greenAreaPaint);

    final linePaint =
        Paint()
          ..color = const Color(0xFFF2C400)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final curvePath =
        Path()
          ..moveTo(w * 0.1, h * 0.8)
          ..quadraticBezierTo(w * 0.55, h * 0.5, w * 0.75, h * 0.2)
          ..lineTo(w * 0.95, h * 0.2);

    canvas.drawPath(curvePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
