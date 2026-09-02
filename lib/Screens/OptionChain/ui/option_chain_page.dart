import 'package:flutter/material.dart';
import 'basket_page.dart';

class OptionChainPage extends StatefulWidget {
  final String symbol;

  const OptionChainPage({Key? key, required this.symbol}) : super(key: key);

  @override
  State<OptionChainPage> createState() => _OptionChainPageState();
}

class _OptionChainPageState extends State<OptionChainPage> {
  String selectedExpirationDate = 'JUN 20';
  String selectedType = 'call';
  bool showCalls = true;
  bool showPuts = true;
  int? selectedRowIndex;
  Set<int> basketRows = {};
  bool basketEnabled = false;

  // Badge system: row index to badge letter mapping
  final Map<int, Map<String, dynamic>> rowBadges = {
    0: {'letter': 'A', 'color': Colors.pink},
    4: {'letter': 'B', 'color': Colors.green},
    9: {'letter': 'S', 'color': Colors.red},
    11: {'letter': 'S', 'color': Colors.red},
  };

  // Mock option chain data
  final List<Map<String, dynamic>> optionChainData = [
    {
      'strikePrice': 155,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 156,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 155,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
      'label': 'Spot Price',
      'labelColor': Colors.orange,
      'priceChange': '+20.4 (+13.4%)',
    },
    {
      'strikePrice': 155,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 164,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': true,
      'label': 'ATM',
      'labelColor': Colors.orange,
    },
    {
      'strikePrice': 155,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
      'label': 'OI Resistance',
      'labelColor': Colors.orange,
    },
    {
      'strikePrice': 175,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 176,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
    {
      'strikePrice': 175,
      'bid': 12.60,
      'ask': 12.60,
      'last': 12.60,
      'iv': 1.40,
      'volume': 12.0,
      'oi': 18.2,
      'type': 'call',
      'highlight': false,
    },
  ];

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
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock Header
                  _buildStockHeader(),
                  // Filters Row
                  _buildFiltersRow(),
                  // Option Chain Table
                  _buildOptionChainTable(),
                ],
              ),
            ),
          ),
          // Trading Summary Section
          if (selectedRowIndex != null) _buildTradingSummarySection(),
        ],
      ),
    );
  }

  Widget _buildStockHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Stock Icon
          Container(
            width: 32,
            height: 32,
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
            icon: Icon(
              Icons.shopping_cart_outlined,
              size: 20,
              color: Colors.grey[600],
            ),
            onPressed:
                basketRows.isNotEmpty
                    ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BasketPage(
                                symbol: widget.symbol,
                                selectedRows: basketRows.toList(),
                                optionChainData: optionChainData,
                              ),
                        ),
                      );
                    }
                    : null,
          ),
          Switch(
            value: basketEnabled,
            onChanged: (val) {
              setState(() {
                basketEnabled = val;
                if (!val) {
                  basketRows.clear();
                  selectedRowIndex = null;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterPill('DELTA'),
            const SizedBox(width: 8),
            _buildFilterPill('OI'),
            const SizedBox(width: 8),
            _buildFilterPill('LTP'),
            const SizedBox(width: 8),
            // Expiration Date Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC600),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<String>(
                underline: Container(),
                isDense: true,
                value: selectedExpirationDate,
                icon: const Icon(Icons.expand_more, size: 18),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                items:
                    ['JUN 20', 'JUL 20', 'AUG 20'].map((date) {
                      return DropdownMenuItem<String>(
                        value: date,
                        child: Text(date),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedExpirationDate = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            _buildFilterPill('LTP'),
            const SizedBox(width: 8),
            _buildFilterPill('OI'),
            const SizedBox(width: 8),
            _buildFilterPill('DELT'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOptionChainTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.white,
        child: DataTable(
          columnSpacing: 15,

          columns: const [
            DataColumn(
              label: Text(
                'Call Bid',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            DataColumn(
              label: Text(
                'Call Ask',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            DataColumn(
              label: Text(
                'Call Last',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            DataColumn(
              label: Text(
                'Strike',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            DataColumn(
              label: Text(
                'Put OI',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            DataColumn(
              label: Text(
                'Put IV',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            DataColumn(
              label: Text(
                'Put Vol',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
          rows: List.generate(optionChainData.length, (index) {
            final data = optionChainData[index];
            final isHighlight = data['highlight'] ?? false;
            final isSelected = selectedRowIndex == index;

            final bgColor =
                isSelected
                    ? Colors.blue.withOpacity(0.15)
                    : (isHighlight
                        ? const Color(0xFFFFC600).withOpacity(0.3)
                        : (data['label'] != null
                            ? const Color(0xFFFFC600).withOpacity(0.15)
                            : Colors.white));

            return DataRow(
              onSelectChanged:
                  basketEnabled
                      ? (selected) {
                        setState(() {
                          selectedRowIndex = selected == true ? index : null;
                          if (selected == true && !basketRows.contains(index)) {
                            basketRows.add(index);
                          }
                        });
                      }
                      : null,
              selected: isSelected,
              color: MaterialStateColor.resolveWith((states) => bgColor),
              cells: [
                DataCell(
                  Text('${data['bid']}', style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text('${data['ask']}', style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text('${data['last']}', style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${data['strikePrice']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (data['label'] != null)
                        Text(
                          data['label'],
                          style: TextStyle(
                            fontSize: 10,
                            color: data['labelColor'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (data['priceChange'] != null)
                        Text(
                          data['priceChange'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Text('${data['oi']}K', style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text('${data['iv']}', style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text(
                    '${data['volume']}.0',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTradingSummarySection() {
    final selectedData = optionChainData[selectedRowIndex!];
    final strikePrice = selectedData['strikePrice'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with badge
          Row(
            children: [
              Expanded(
                child: Text(
                  'AAPL 20 Jun $strikePrice Call',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC600),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Max Loss', '-\$21,345.00', Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Max Profit',
                  '\$113,711.00',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildStatItem('POP', '47%', Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),

          // Second row
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Req Margin', '\$21,345.00', Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Balance', '\$83,711.00', Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(child: Container()),
            ],
          ),
          const SizedBox(height: 16),

          // Execute Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  basketRows.isNotEmpty
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => BasketPage(
                                  symbol: widget.symbol,
                                  selectedRows: basketRows.toList(),
                                  optionChainData: optionChainData,
                                ),
                          ),
                        );
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC600),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Execute Basket (${basketRows.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
