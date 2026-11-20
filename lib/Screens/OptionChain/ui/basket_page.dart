import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'basket_analysis_page.dart';
import 'order_pending_page.dart';

class BasketPageNotifier extends ChangeNotifier {
  bool _sameQty = false;
  final Map<int, int> _quantities;

  BasketPageNotifier(List<int> selectedRows)
    : _quantities = {for (var index in selectedRows) index: 650};

  bool get sameQty => _sameQty;
  Map<int, int> get quantities => _quantities;

  void setSameQty(bool value) {
    _sameQty = value;
    notifyListeners();
  }

  void incrementQuantity(int rowIndex) {
    final current = _quantities[rowIndex] ?? 650;
    _quantities[rowIndex] = current + 1;
    notifyListeners();
  }

  void decrementQuantity(int rowIndex) {
    final current = _quantities[rowIndex] ?? 650;
    if (current > 1) {
      _quantities[rowIndex] = current - 1;
      notifyListeners();
    }
  }
}

class BasketPage extends StatelessWidget {
  final String symbol;
  final List<int> selectedRows;
  final List<Map<String, dynamic>> optionChainData;

  const BasketPage({
    super.key,
    required this.symbol,
    required this.selectedRows,
    required this.optionChainData,
  });

  static void show(
    BuildContext context, {
    required String symbol,
    required List<int> selectedRows,
    required List<Map<String, dynamic>> optionChainData,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BasketPage(
          symbol: symbol,
          selectedRows: selectedRows,
          optionChainData: optionChainData,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BasketPageNotifier(selectedRows),
      child: Consumer<BasketPageNotifier>(
        builder: (context, basketNotifier, _) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Material(
                  color: Colors.white,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.72,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Drag Handle Bar
                        Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6E9E7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Header Title Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Text(
                                '$symbol BASKET',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stock Header
                                buildStockHeader(context),
                                const SizedBox(height: 12),

                                // Stats Section
                                buildStatsSection(),
                                const SizedBox(height: 16),

                                // Same Qty Section
                                _buildSameQtySection(basketNotifier),
                                const SizedBox(height: 16),

                                // Basket Items
                                _buildBasketItems(basketNotifier),
                              ],
                            ),
                          ),
                        ),

                        // Footer
                        _buildFooterSection(context),
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

  Widget buildStockHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.apple, size: 26, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            symbol,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          const Text(
            '+3.76%',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF1DB854),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '\$577.87',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              BasketAnalysisPage.show(context, symbol: symbol);
            },
            child: SvgPicture.asset(
              'lib/Resources/Images/ix_analyze.svg',
              width: 22,
              height: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Max Loss',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
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
            children: const [
              Text(
                'Max Profit',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
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
            children: const [
              Text(
                'POP',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
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
    );
  }

  Widget _buildSameQtySection(BasketPageNotifier basketNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Checkbox(
            value: basketNotifier.sameQty,
            onChanged: (value) {
              basketNotifier.setSameQty(value ?? false);
            },
          ),
          const Text(
            'Same Qty',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.remove, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '650',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.add, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasketItems(BasketPageNotifier basketNotifier) {
    final quantities = basketNotifier.quantities;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(selectedRows.length, (idx) {
          final rowIndex = selectedRows[idx];
          final data = optionChainData[rowIndex];
          final strikePrice = data['strikePrice'];
          final qty = quantities[rowIndex] ?? 650;
          final isBuy = idx % 2 == 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Quantity Controls Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AAPL 20 Jun $strikePrice Call',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isBuy
                                          ? const Color(
                                            0xFF06B6D4,
                                          ).withValues(alpha: 0.15)
                                          : const Color(
                                            0xFFEF4444,
                                          ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  isBuy ? 'Buy' : 'Sell',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isBuy
                                            ? const Color(0xFF06B6D4)
                                            : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isBuy ? 'Mkt \$47.21' : 'Mkt \$77.87',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2C400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              basketNotifier.decrementQuantity(rowIndex);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.remove, size: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$qty',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2C400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              basketNotifier.incrementQuantity(rowIndex);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.add, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Req Margin: \$21,345.00',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Balance: \$83,711.00',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) {
                    return OrderPendingPage(
                      symbol: '$symbol BASKET (${selectedRows.length})',
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2C400),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
