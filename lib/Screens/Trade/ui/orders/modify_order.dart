import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Helper/nerve_styles.dart';
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/service/modify_order_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_orders_service.dart';
import 'package:century_cqg/Screens/Trade/ui/orders/order_pending_page.dart';

class ModifyOrderPage extends StatefulWidget {
  final String symbolName;
  final String side;

  const ModifyOrderPage({
    super.key,
    required this.symbolName,
    required this.side,
  });

  @override
  State<ModifyOrderPage> createState() => _ModifyOrderPageState();
}

class _ModifyOrderPageState extends State<ModifyOrderPage> {
  late String _selectedSide;

  @override
  void initState() {
    super.initState();
    _selectedSide = widget.side.toLowerCase();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final service = context.read<ModifyOrderService>();
      service.resetOrderForm();
      service.fetchSymbolDetails(symbolName: widget.symbolName, period: '1D');
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ModifyOrderService>();
    final ordersService = context.watch<TradeOrdersService>();
    final symbolDetails = service.symbolDetails;
    final isDarkMode = NerveBase().isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF0D110F) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF161B19) : Colors.white;
    final borderColor =
        isDarkMode ? const Color(0xFF2D3431) : const Color(0xFFE5E9E7);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF4A4F53);
    final mutedColor =
        isDarkMode ? const Color(0xFF8A918D) : const Color(0xFF8B9198);
    final positiveColor = const Color(0xFF00C389);
    final pricePercentage = symbolDetails?.pricePercentage;
    final priceChangeColor =
        pricePercentage == null
            ? mutedColor
            : pricePercentage >= 0
            ? positiveColor
            : const Color(0xFFF6465D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        surfaceTintColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: titleColor),
          tooltip: 'Cancel order',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          'MODIFY ORDER',
          style: NerveStyles.tradeDetailsSectionTitleStyle(titleColor),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buySellToggle(borderColor),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF111111),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.symbolName.isEmpty
                                ? ''
                                : widget.symbolName[0].toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              symbolDetails?.symbolName ?? widget.symbolName,
                              style: NerveStyles.tradePositionSymbolStyle(
                                titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  symbolDetails == null
                                      ? '--'
                                      : '\$${symbolDetails.price.toStringAsFixed(2)}',
                                  style:
                                      NerveStyles.tradeDetailsSectionTitleStyle(
                                        titleColor,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  pricePercentage == null
                                      ? '--'
                                      : '${pricePercentage >= 0 ? '+' : ''}${pricePercentage.toStringAsFixed(2)}%',
                                  style: NerveStyles.tradeDetailsOrderPnlStyle(
                                    priceChangeColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _marketLine(
                              'B',
                              symbolDetails?.bid.toStringAsFixed(2) ?? '--',
                              'A',
                              symbolDetails?.ask.toStringAsFixed(2) ?? '--',
                              mutedColor,
                            ),
                            const SizedBox(height: 4),
                            _marketLine(
                              'L',
                              symbolDetails?.low.toStringAsFixed(2) ?? '--',
                              'H',
                              symbolDetails?.high.toStringAsFixed(2) ?? '--',
                              mutedColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _unitsField(
                            borderColor,
                            titleColor,
                            mutedColor,
                            service,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _amountField(borderColor, mutedColor, service),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Order Type',
                      style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _orderTypeButton(
                            'Market',
                            borderColor,
                            titleColor,
                            service,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _orderTypeButton(
                            'Limit',
                            borderColor,
                            titleColor,
                            service,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _orderTypeButton(
                            'Stop Entry',
                            borderColor,
                            titleColor,
                            service,
                          ),
                        ),
                      ],
                    ),
                    if (service.selectedOrderType == 'Limit') ...[
                      const SizedBox(height: 14),
                      _priceField(
                        'Limit Price',
                        service.limitPriceController,
                        borderColor,
                        mutedColor,
                      ),
                    ],
                    if (service.selectedOrderType == 'Stop Entry' ||
                        service.selectedOrderType == 'Stop') ...[
                      const SizedBox(height: 14),
                      _priceField(
                        'Stop Entry',
                        service.stopPriceController,
                        borderColor,
                        mutedColor,
                      ),
                    ],
                    if (ordersService.submitError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          ordersService.submitError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        side: BorderSide(color: borderColor),
                        foregroundColor: titleColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel order',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          ordersService.isSubmitting
                              ? null
                              : () => _submitOrder(context, service),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        backgroundColor: const Color(0xFFF2C400),
                        foregroundColor: const Color(0xFF1F1F1F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          ordersService.isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buySellToggle(Color borderColor) {
    final isBuy = _selectedSide == 'buy';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedSide = 'buy'),
                child: Container(
                  decoration: BoxDecoration(
                    color: isBuy ? const Color(0xFFF2C400) : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Buy'),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedSide = 'sell'),
                child: Container(
                  decoration: BoxDecoration(
                    color: isBuy ? Colors.transparent : const Color(0xFFF2C400),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(12),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Sell'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marketLine(
    String l1,
    String v1,
    String l2,
    String v2,
    Color mutedColor,
  ) {
    return Text(
      '$l1 $v1   $l2 $v2',
      style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
    );
  }

  Widget _unitsField(
    Color borderColor,
    Color titleColor,
    Color mutedColor,
    ModifyOrderService service,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Units',
          style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
        ),
        const SizedBox(height: 6),
        Container(
          height: 38,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _pmButton('-', borderColor, () {
                service.decrementUnits();
              }),
              Expanded(
                child: TextField(
                  controller: service.quantityController,
                  onChanged: service.updateUnits,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: NerveStyles.tradeDetailsHeaderSymbolStyle(titleColor),
                  onSubmitted: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) service.setUnits(parsed);
                  },
                ),
              ),
              _pmButton('+', borderColor, () {
                service.incrementUnits();
              }),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Max: 250',
          style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
        ),
      ],
    );
  }

  Widget _priceField(
    String label,
    TextEditingController controller,
    Color borderColor,
    Color mutedColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountField(
    Color borderColor,
    Color mutedColor,
    ModifyOrderService service,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (USD)',
          style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: service.amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Avail: 27,416.57',
          style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
        ),
      ],
    );
  }

  Widget _pmButton(String text, Color borderColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            right:
                text == '-' ? BorderSide(color: borderColor) : BorderSide.none,
            left:
                text == '+' ? BorderSide(color: borderColor) : BorderSide.none,
          ),
        ),
        alignment: Alignment.center,
        child: Text(text),
      ),
    );
  }

  Widget _orderTypeButton(
    String type,
    Color borderColor,
    Color titleColor,
    ModifyOrderService service,
  ) {
    final selected = service.selectedOrderType == type;
    return OutlinedButton(
      onPressed: () {
        service.setOrderType(type);
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(36),
        backgroundColor:
            selected ? const Color(0xFFFFF8E1) : Colors.transparent,
        side: BorderSide(
          color: selected ? const Color(0xFFF2C400) : borderColor,
        ),
        foregroundColor: selected ? const Color(0xFFB38D00) : titleColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        type,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 10,
          height: 1,
          letterSpacing: 0,
          color: selected ? const Color(0xFFB38D00) : titleColor,
        ),
      ),
    );
  }

  Future<void> _submitOrder(
    BuildContext context,
    ModifyOrderService service,
  ) async {
    if (service.units == null || service.units! <= 0) {
      return;
    }

    late final TradeOrderRequest request;
    try {
      request = service.buildOrderRequest(
        symbolName: widget.symbolName,
        side: _selectedSide,
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }

    final order = await context.read<TradeOrdersService>().submitOrder(request);
    if (!context.mounted) return;
    if (order == null) {
      final message =
          context.read<TradeOrdersService>().submitError ??
          'Unable to submit order.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderPendingPage(order: order),
    );
  }
}
