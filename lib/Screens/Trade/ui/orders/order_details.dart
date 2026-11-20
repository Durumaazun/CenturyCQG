import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Helper/nerve_styles.dart';
import 'package:century_cqg/Screens/Trade/History/service/history_service.dart';
import 'package:century_cqg/Screens/Trade/model/trade_api_models.dart';
import 'package:century_cqg/Screens/Trade/service/trade_orders_service.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TradeOrdersService>();
    final isDarkMode = NerveBase().isDarkMode;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF2A2A2A);
    final mutedColor =
        isDarkMode ? const Color(0xFF8F9793) : const Color(0xFF7A817D);
    final borderColor =
        isDarkMode ? const Color(0xFF2A302D) : const Color(0xFFE8ECEA);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Text(
                'Orders',
                style: NerveStyles.tradeDetailsSectionTitleStyle(titleColor),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh orders',
                onPressed: service.isLoading ? null : service.fetchOrders,
                icon: Icon(Icons.refresh, size: 20, color: mutedColor),
              ),
            ],
          ),
        ),
        if (service.isLoading && service.orders.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (service.error != null && service.orders.isEmpty)
          Expanded(
            child: _messageState(
              service.error!,
              actionLabel: 'Retry',
              onAction: service.fetchOrders,
            ),
          )
        else if (service.orders.isEmpty)
          const Expanded(child: Center(child: Text('No orders found.')))
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: service.fetchOrders,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: service.orders.length,
                separatorBuilder: (_, __) => Divider(color: borderColor),
                itemBuilder: (context, index) {
                  final order = service.orders[index];
                  return _orderCard(
                    context,
                    order,
                    service,
                    titleColor,
                    mutedColor,
                    isDarkMode,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _orderCard(
    BuildContext context,
    TradeOrder order,
    TradeOrdersService service,
    Color titleColor,
    Color mutedColor,
    bool isDarkMode,
  ) {
    final isBuy = order.side.toLowerCase() == 'buy';
    final sideColor = isBuy ? const Color(0xFF00C389) : const Color(0xFFE53935);
    final canCancel =
        (order.status.toLowerCase() == 'pending' ||
            order.status.toLowerCase() == 'partial') &&
        order.remainingQuantity > 0;
    final date = order.createdAt?.toLocal();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderId,
                  style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
                ),
              ),
              _statusBadge(order.status, isDarkMode),
              if (canCancel)
                IconButton(
                  tooltip: 'Cancel order',
                  onPressed:
                      service.isCanceling(order.orderId)
                          ? null
                          : () => _confirmCancel(context, order, service),
                  icon:
                      service.isCanceling(order.orderId)
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(Icons.close, size: 18, color: mutedColor),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E8E93),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  order.symbolName.isEmpty
                      ? ''
                      : order.symbolName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.symbolName,
                  style: NerveStyles.tradePositionSymbolStyle(titleColor),
                ),
              ),
              Text(
                date == null ? '--' : DateFormat('dd MMM HH:mm').format(date),
                style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'B/S · TYPE',
                  '${order.side} · ${order.orderType}',
                  mutedColor,
                  sideColor,
                ),
              ),
              Expanded(
                child: _metric(
                  'QUANTITY · FILLED',
                  '${_number(order.quantity)} · ${_number(order.filledQuantity)}',
                  mutedColor,
                  titleColor,
                ),
              ),
              Expanded(
                child: _metric(
                  'AMOUNT',
                  '\$${NumberFormat('#,##0.00').format(order.amount)}',
                  mutedColor,
                  titleColor,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          if (service.cancelError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                service.cancelError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, bool isDarkMode) {
    final normalizedStatus = status.toLowerCase();
    final color =
        normalizedStatus == 'filled'
            ? const Color(0xFF00A879)
            : normalizedStatus == 'canceled' || normalizedStatus == 'expired'
            ? const Color(0xFFE53935)
            : const Color(0xFFB38D00);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _metric(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: NerveStyles.tradePositionMetricLabelStyle(labelColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: NerveStyles.tradeDetailsOrderBuyValueStyle(valueColor),
        ),
      ],
    );
  }

  Widget _messageState(
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    ),
  );

  Future<void> _confirmCancel(
    BuildContext context,
    TradeOrder order,
    TradeOrdersService service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Cancel order?'),
            content: Text('Cancel order ${order.orderId}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep order'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Cancel order'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;

    final canceled = await service.cancelOrder(order.orderId);
    if (!context.mounted) return;
    if (canceled) {
      await context.read<HistoryService>().fetchHistory();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order canceled.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(service.cancelError ?? 'Unable to cancel order.'),
        ),
      );
    }
  }

  String _number(num value) => NumberFormat('#,##0.##').format(value);
}
