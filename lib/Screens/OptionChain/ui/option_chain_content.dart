import 'package:flutter/material.dart';

class OptionChainContent extends StatefulWidget {
  final String symbol;

  const OptionChainContent({Key? key, required this.symbol}) : super(key: key);

  @override
  State<OptionChainContent> createState() => _OptionChainContentState();
}

class _OptionChainContentState extends State<OptionChainContent> {
  String? selectedExpirationDate;
  String selectedType = 'call'; // 'call' or 'put'

  @override
  void initState() {
    super.initState();
    // TODO: Initialize option chain data fetching
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Filters Section
          _buildFiltersSection(),
          // Option Chain Table
          _buildOptionChainTable(),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Expiration Date Dropdown
          _buildExpirationDateDropdown(),
          const SizedBox(height: 12),
          // Option Type Toggle
          _buildOptionTypeToggle(),
        ],
      ),
    );
  }

  Widget _buildExpirationDateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expiration Date'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            underline: Container(),
            isExpanded: true,
            hint: const Text('Select Expiration Date'),
            value: selectedExpirationDate,
            onChanged: (value) {
              setState(() {
                selectedExpirationDate = value;
              });
              // TODO: Fetch options for selected expiration date
            },
            items: [
              // TODO: Add dynamic expiration dates
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Option Type'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTypeButton('call', 'Call')),
            const SizedBox(width: 12),
            Expanded(child: _buildTypeButton('put', 'Put')),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type, String label) {
    bool isSelected = selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChainTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Option Chain Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Strike')),
                DataColumn(label: Text('Bid')),
                DataColumn(label: Text('Ask')),
                DataColumn(label: Text('Last')),
                DataColumn(label: Text('IV')),
                DataColumn(label: Text('Volume')),
              ],
              rows: [
                // TODO: Add dynamic rows from option chain data
              ],
            ),
          ),
        ],
      ),
    );
  }
}
