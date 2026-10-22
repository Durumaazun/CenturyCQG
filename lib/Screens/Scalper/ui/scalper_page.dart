import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chart_package/flutter_chart_package.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Screens/Dashboard/service/dasboard_service.dart';

class ScalperPage extends StatefulWidget {
  const ScalperPage({super.key});

  @override
  State<ScalperPage> createState() => _ScalperPageState();
}

class _ScalperPageState extends State<ScalperPage> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    context.watch<DashboardService>();
    final isDarkMode = NerveBase().isDarkMode;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF0D110F) : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Chart Section
              Expanded(
                child:
                    isDarkMode
                        ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            // Converts white chart background to black theme and icons to white,
                            // while strictly preserving green and red candlestick bar colors
                            0.0, -0.90, -0.10, 0.0, 255.0,
                            -0.90, 0.0, -0.10, 0.0, 255.0,
                            -0.80, -0.80, 0.60, 0.0, 255.0,
                            0.0, 0.0, 0.0, 1.0, 0.0,
                          ]),
                          child: Navigator(
                            key: _navigatorKey,
                            onGenerateRoute:
                                (settings) => MaterialPageRoute(
                                  builder: (_) => const InitialPage(),
                                ),
                          ),
                        )
                        : Navigator(
                          key: _navigatorKey,
                          onGenerateRoute:
                              (settings) => MaterialPageRoute(
                                builder: (_) => const InitialPage(),
                              ),
                        ),
              ),
            ],
          ),
        ),

        /// Use bottomNavigationBar to ensure it stays at the bottom and doesn't get pushed by Inner Scaffolds
        bottomNavigationBar: isLandscape ? null : const ScalperControls(),
      ),
    );
  }
}

class ScalperControlsProvider extends ChangeNotifier {
  String _selectedTab = '';

  String get selectedTab => _selectedTab;

  void setSelectedTab(String tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }
}

class ScalperControls extends StatelessWidget {
  const ScalperControls({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScalperControlsProvider(),
      child: const _ScalperControlsBody(),
    );
  }
}

class _ScalperControlsBody extends StatelessWidget {
  const _ScalperControlsBody();

  @override
  Widget build(BuildContext context) {
    context.watch<DashboardService>();
    final isDarkMode = NerveBase().isDarkMode;
    final selectedTab = context.watch<ScalperControlsProvider>().selectedTab;

    final bgColor =
        isDarkMode ? const Color(0xFF0D110F) : const Color(0xFFFFFFFF);
    final borderColor =
        isDarkMode ? const Color(0xFF282D2A) : const Color(0xFFEAEAEA);
    final primaryTextColor =
        isDarkMode ? Colors.white : const Color(0xB2000000);
    final secondaryTextColor =
        isDarkMode ? Colors.white : const Color(0x80000000);
    final iconColor = isDarkMode ? Colors.white : Colors.grey.shade700;

    return Material(
      elevation: 8,
      color: bgColor,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Navigation Tabs
              _buildTabs(context, selectedTab, isDarkMode),

              const SizedBox(height: 12),
              // Symbol and Exit Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'APPL 2050 : CALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: iconColor,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Exit',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Values Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildValueWithRefresh('\$1,959', secondaryTextColor),
                  Text(
                    'QTY (1 LOT)',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  _buildValueWithRefresh('\$207,065', secondaryTextColor),
                ],
              ),

              const SizedBox(height: 12),

              // Buttons and Quantity Row
              _buildBuySellButton(primaryTextColor),

              const SizedBox(height: 12),

              // Footer Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total P&L: \$21,345.00',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Balance: \$83,711.00',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, String selectedTab, bool isDarkMode) {
    return Row(
      children: [
        _buildTabChip(
          title: 'Option Chain',
          isSelected: selectedTab == 'Option Chain',
          isDarkMode: isDarkMode,
          onTap: () {
            context.read<ScalperControlsProvider>().setSelectedTab(
              'Option Chain',
            );
            // TODO: Navigate to Option Chain Screen
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Option Chain clicked'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildTabChip(
          title: 'Positions',
          isSelected: selectedTab == 'Positions',
          isDarkMode: isDarkMode,
          onTap: () {
            context.read<ScalperControlsProvider>().setSelectedTab('Positions');
            // TODO: Navigate to Positions Screen
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Positions clicked'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildTabChip(
          title: 'Orders',
          isSelected: selectedTab == 'Orders',
          isDarkMode: isDarkMode,
          onTap: () {
            context.read<ScalperControlsProvider>().setSelectedTab('Orders');
            // TODO: Navigate to Orders Screen
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Orders clicked'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  _buildBuySellButton(Color quantityTextColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB3D52),
              foregroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'SELL CE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 15),
        _buildQuantitySelector(quantityTextColor),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27A374),
              foregroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'BUY CE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabChip({
    required String title,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final chipBg =
        isSelected
            ? const Color(0xFFF2C400)
            : (isDarkMode ? const Color(0xFF1D2321) : const Color(0xFFFFFFFF));
    final chipBorder =
        isSelected
            ? const Color(0xFFF2C400)
            : (isDarkMode ? const Color(0xFF282D2A) : const Color(0xFFEAEAEA));
    final textColor =
        isSelected
            ? const Color(0xFF2A2A2A)
            : (isDarkMode ? Colors.white : const Color(0xB2000000));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chipBorder, width: 1),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildValueWithRefresh(String value, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.refresh, color: Color(0xFFF2C400), size: 15),
      ],
    );
  }

  Widget _buildQuantitySelector(Color quantityTextColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepButton(Icons.remove),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Text(
            '65',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: quantityTextColor,
            ),
          ),
        ),
        _buildStepButton(Icons.add),
      ],
    );
  }

  Widget _buildStepButton(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF2C400),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: Icon(icon, color: Colors.black, size: 18)),
    );
  }
}
