import 'package:century_cqg/Screens/Dashboard/service/dasboard_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_page_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Helper/nerve_styles.dart';
import 'package:century_cqg/Screens/Dashboard/ui/home_page.dart';

class OrderPendingPage extends StatelessWidget {
  final String symbol;
  final String units;
  final String amount;
  final String orderType;
  final String gtcDate;
  final String stopLoss;
  final String orderId;
  final String orderSide;
  final VoidCallback? onDone;

  const OrderPendingPage({
    super.key,
    required this.symbol,
    required this.units,
    required this.amount,
    required this.orderType,
    required this.gtcDate,
    required this.stopLoss,
    required this.orderId,
    required this.orderSide,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = NerveBase().isDarkMode;
    final sheetColor = isDarkMode ? const Color(0xFF111614) : Colors.white;
    final borderColor =
        isDarkMode ? const Color(0xFF2B302D) : const Color(0xFFE6E9E7);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF3F4348);
    final mutedColor =
        isDarkMode ? const Color(0xFF8A918D) : const Color(0xFF8A9199);
    final cardColor =
        isDarkMode ? const Color(0xFF191F1D) : const Color(0xFFF5F7FA);
    final isBuy = orderSide.toLowerCase() == 'buy';
    final sideColor = isBuy ? const Color(0xFF00C389) : const Color(0xFFDB3D52);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            color: sheetColor,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.76,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2C400),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.access_time_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Order Pending',
                      style: NerveStyles.tradeDetailsSectionTitleStyle(
                        titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Confirmation in progress',
                      style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      orderId,
                      style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: NerveStyles.tradeDetailsHeaderSymbolStyle(
                          titleColor,
                        ),
                        children: [
                          const TextSpan(text: 'You have placed a '),
                          TextSpan(
                            text: orderSide,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: sideColor,
                            ),
                          ),
                          const TextSpan(text: ' order for'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _headerText('PRODUCT', mutedColor),
                              ),
                              Expanded(
                                child: _headerText(
                                  'UNITS',
                                  mutedColor,
                                  center: true,
                                ),
                              ),
                              Expanded(
                                child: _headerText(
                                  'AMOUNT',
                                  mutedColor,
                                  right: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  symbol,
                                  style:
                                      NerveStyles.tradeDetailsHeaderSymbolStyle(
                                        titleColor,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  units,
                                  textAlign: TextAlign.center,
                                  style:
                                      NerveStyles.tradeDetailsHeaderSymbolStyle(
                                        titleColor,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  amount,
                                  textAlign: TextAlign.right,
                                  style:
                                      NerveStyles.tradeDetailsHeaderSymbolStyle(
                                        titleColor,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailRow('TYPE', orderType, mutedColor, titleColor),
                    _divider(borderColor),
                    _detailRow('GTC', gtcDate, mutedColor, titleColor),
                    _divider(borderColor),
                    _detailRow(
                      'STOP LOSS',
                      stopLoss,
                      mutedColor,
                      const Color(0xFFDB3D52),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 24),

                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? const Color(0xFF2A2A13)
                                : const Color(0xFFFFFBEA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            0xFFF2C400,
                          ).withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'lib/Resources/Images/info_img.svg',
                            width: 22,
                            height: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF364153),
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'You can track your order status in the ',
                                  ),
                                  TextSpan(
                                    text: 'Orders',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 19.5 / 12,
                                      letterSpacing: 0,
                                      color: const Color(0xFF364153),
                                    ),
                                  ),
                                  const TextSpan(text: ' tab.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '23 Sep 2022   •   3:26 PM GST',
                      style: NerveStyles.tradeDetailsOrderDateStyle(mutedColor),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          if (onDone != null) {
                            onDone!();
                            return;
                          }
                          // Set isFromDetails flag and select Trades bottom tab (index 3)
                          final dashboardService =
                              context.read<DashboardService>();
                          dashboardService.setIsFromDetails(true);
                          dashboardService.setSelectedHomeTabIndex(3);
                          try {
                            context
                                .read<TradePageService>()
                                .setSelectedTabIndex(1);
                          } catch (_) {}

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MobileHomePage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFF2C400),
                          foregroundColor: const Color(0xFF1F1F1F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerText(
    String text,
    Color color, {
    bool center = false,
    bool right = false,
  }) {
    return Text(
      text,
      textAlign:
          right
              ? TextAlign.right
              : center
              ? TextAlign.center
              : TextAlign.left,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ),
          Text(
            value,
            style: NerveStyles.tradeDetailsHeaderSymbolStyle(valueColor),
          ),
        ],
      ),
    );
  }

  Widget _divider(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(height: 1, color: color),
    );
  }
}
