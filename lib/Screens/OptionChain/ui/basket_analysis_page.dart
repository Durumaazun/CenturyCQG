import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasketAnalysisNotifier extends ChangeNotifier {
  int _selectedTabIndex = 0; // 0 for Summary, 1 for Payoff Graph

  int get selectedTabIndex => _selectedTabIndex;

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
}

class BasketAnalysisPage extends StatelessWidget {
  final String symbol;

  const BasketAnalysisPage({super.key, required this.symbol});

  static void show(BuildContext context, {required String symbol}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BasketAnalysisPage(symbol: symbol);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BasketAnalysisNotifier(),
      child: Consumer<BasketAnalysisNotifier>(
        builder: (context, notifier, _) {
          final selectedTabIndex = notifier.selectedTabIndex;

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Text(
                                '$symbol BASKET ANALYSIS',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Toggle Buttons (Summary / Payoff Graph)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              _buildTabButton(notifier, 0, 'Summary'),
                              const SizedBox(width: 12),
                              _buildTabButton(notifier, 1, 'Payoff Graph'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Legend: Today (Blue) & Expiry Date (Brown/Red)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E88E5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8D2B1C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Expiry Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Main Body
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child:
                                selectedTabIndex == 0
                                    ? _buildSummaryContent()
                                    : _buildPayoffGraphContent(),
                          ),
                        ),
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

  Widget _buildTabButton(
    BasketAnalysisNotifier notifier,
    int index,
    String label,
  ) {
    final isSelected = notifier.selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        notifier.setSelectedTabIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2C400) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border:
              isSelected
                  ? null
                  : Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Column(
      children: [
        // Card 1: Max Profit | Max Loss | POP
        _buildCard(
          child: Row(
            children: [
              _buildMetricCol(
                'Max Profit',
                'Unlimited',
                const Color(0xFF1DB854),
              ),
              _buildMetricCol('Max Loss', '₹0', const Color(0xFFD32F2F)),
              _buildMetricCol('POP', '10%', const Color(0xFFD32F2F)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Card 2: You Pay (Est) | Margin reqd. | Strategy Price
        _buildCard(
          child: Row(
            children: [
              _buildMetricCol(
                'You Pay (Est)',
                'Unlimited',
                const Color(0xFF1DB854),
              ),
              _buildMetricCol('Margin reqd.', '₹0', const Color(0xFFD32F2F)),
              _buildMetricCol('Strategy Price', '10%', const Color(0xFFD32F2F)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Greeks Row 1: Delta & Gamma
        Row(
          children: [
            Expanded(
              child: _buildCard(
                child: Column(
                  children: const [
                    Text(
                      'Delta',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '0.000',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                child: Column(
                  children: const [
                    Text(
                      'Gamma',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E24AA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '0.000',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Greeks Row 2: Theta & Vega
        Row(
          children: [
            Expanded(
              child: _buildCard(
                child: Column(
                  children: const [
                    Text(
                      'Theta',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFB8C00),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '0.000',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                child: Column(
                  children: const [
                    Text(
                      'Vega',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF43A047),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '0.000',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Breakeven Card
        _buildBreakevenCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPayoffGraphContent() {
    return Column(
      children: [
        // Custom Payoff Graph
        Container(
          height: 290,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const _PayoffGraphWidget(),
        ),
        _buildBreakevenCard(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
      ),
      child: child,
    );
  }

  Widget _buildMetricCol(String title, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakevenCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
      ),
      child: Column(
        children: const [
          Text(
            'Breakeven',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '23825.05(-1.73%), 23925.55(0.73%)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PayoffGraphWidget extends StatelessWidget {
  const _PayoffGraphWidget();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 240),
          painter: _PayoffGraphPainter(),
        ),
        // LTP Badge Pill
        Positioned(
          top: 20,
          left: 140,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF2C400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LTP  24678',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
        // On expiry pill
        Positioned(
          top: 105,
          left: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 10, color: Colors.black87),
                children: [
                  TextSpan(text: 'On expiry '),
                  TextSpan(
                    text: '-1030',
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Max Profit box
        Positioned(
          top: 55,
          right: 42,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFF2C400), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Max Profit',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'UNLIMITED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Strike 36100 pill
        Positioned(
          bottom: 50,
          left: 105,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF2C400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '36100',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
        // Max Loss box
        Positioned(
          bottom: 12,
          left: 130,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFF2C400), width: 1.2),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 10, color: Colors.grey),
                children: [
                  TextSpan(text: 'Max Loss '),
                  TextSpan(
                    text: '24678',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PayoffGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final axisPaint =
        Paint()
          ..color = const Color(0xFFEEEEEE)
          ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Left Y-Axis labels & horizontal lines
    final yLabels = ['100', '50', '0', '-50', '-100'];
    final yPositions = [40.0, 90.0, 140.0, 190.0, 240.0];

    for (int i = 0; i < yLabels.length; i++) {
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(24 - textPainter.width, yPositions[i] - 6),
      );
      canvas.drawLine(
        Offset(32, yPositions[i]),
        Offset(w - 16, yPositions[i]),
        axisPaint,
      );
    }

    // Y Axis vertical title "Profit/ Loss"
    canvas.save();
    canvas.translate(10, 150);
    canvas.rotate(-1.5708);
    textPainter.text = const TextSpan(
      text: 'Profit/ Loss',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -6));
    canvas.restore();

    // Bottom X-Axis labels & vertical line
    final xLabels = ['23500', '24000', '24500', '25000', '25500'];
    final xPositions = [45.0, 95.0, 160.0, 220.0, 275.0];

    for (int i = 0; i < xLabels.length; i++) {
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xPositions[i] - textPainter.width / 2, 246),
      );
    }

    // Vertical dashed grey line at x=125 (36100 strike line)
    final dashedPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.6)
          ..strokeWidth = 1.2;
    for (double y = 40; y < 240; y += 6) {
      canvas.drawLine(Offset(125, y), Offset(125, y + 3), dashedPaint);
    }

    // Vertical teal line at x=170 (LTP center line)
    final tealPaint =
        Paint()
          ..color = const Color(0xFF00BFA5)
          ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(170, 30), const Offset(170, 240), tealPaint);

    // Blue Line: "Today"
    final bluePaint =
        Paint()
          ..color = const Color(0xFF1E88E5)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke;

    final bluePath =
        Path()
          ..moveTo(75, 70)
          ..lineTo(170, 205)
          ..lineTo(250, 90);
    canvas.drawPath(bluePath, bluePaint);

    // Brown/Red Curved Line: "Expiry Date"
    final brownPaint =
        Paint()
          ..color = const Color(0xFF8D2B1C)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke;

    final brownPath =
        Path()
          ..moveTo(95, 80)
          ..quadraticBezierTo(170, 230, 235, 90);
    canvas.drawPath(brownPath, brownPaint);

    // Dot on brown line (x=125, y=140)
    final brownDotPaint = Paint()..color = const Color(0xFF8D2B1C);
    canvas.drawCircle(const Offset(125, 140), 4, brownDotPaint);

    // Dot on blue line (x=125, y=150)
    final blueDotPaint = Paint()..color = const Color(0xFF1E88E5);
    canvas.drawCircle(const Offset(125, 150), 4, blueDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
