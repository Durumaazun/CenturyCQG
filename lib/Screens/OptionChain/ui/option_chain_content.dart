import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/option_chain_provider.dart';

class OptionChainContent extends StatelessWidget {
  final String symbol;

  const OptionChainContent({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Consumer<OptionChainNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Filters Section
              _buildFiltersSection(context, state, notifier),
              // Option Chain Table
              _buildOptionChainTable(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersSection(
    BuildContext context,
    OptionChainState state,
    OptionChainNotifier notifier,
  ) {
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
          _buildExpirationDateDropdown(state, notifier),
          const SizedBox(height: 12),
          // Option Type Toggle
          _buildOptionTypeToggle(state, notifier),
        ],
      ),
    );
  }

  Widget _buildExpirationDateDropdown(
    OptionChainState state,
    OptionChainNotifier notifier,
  ) {
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
            value: state.selectedExpirationDate,
            onChanged: (value) {
              if (value != null) {
                notifier.setSelectedExpirationDate(value);
              }
            },
            items: const [
              DropdownMenuItem(value: 'JUN 20', child: Text('JUN 20')),
              DropdownMenuItem(value: 'JUL 20', child: Text('JUL 20')),
              DropdownMenuItem(value: 'AUG 20', child: Text('AUG 20')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTypeToggle(
    OptionChainState state,
    OptionChainNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Option Type'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTypeButton('call', 'Call', state, notifier)),
            const SizedBox(width: 12),
            Expanded(child: _buildTypeButton('put', 'Put', state, notifier)),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    String type,
    String label,
    OptionChainState state,
    OptionChainNotifier notifier,
  ) {
    final bool isSelected = state.selectedType == type;
    return GestureDetector(
      onTap: () {
        notifier.setSelectedType(type);
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
              rows: const [],
            ),
          ),
        ],
      ),
    );
  }
}
