import 'dart:async';

import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Helper/nerve_navigation.dart';
import 'package:century_cqg/Screens/Account/service/account_service.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/service/accnts_tab_service.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/service/analysis_service.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/ui/stock_details_page.dart';
import 'package:century_cqg/Screens/Dashboard/service/dasboard_service.dart';
import 'package:century_cqg/Screens/Login/service/login_service.dart';
import 'package:century_cqg/Screens/Watchlist/service/watchlist_service.dart';
import 'package:century_cqg/Screens/Search/service/search_service.dart';
import 'package:century_cqg/Screens/Trade/History/service/history_service.dart';
import 'package:century_cqg/Screens/Trade/Execution/service/execution_service.dart';
import 'package:century_cqg/Screens/Trade/Holdings/service/holding_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_page_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_service.dart';
import 'package:century_cqg/Screens/Trade/service/modify_order_service.dart';
import 'package:century_cqg/Screens/Trade/service/trade_repository.dart';
import 'package:century_cqg/Screens/Trade/service/trade_use_cases.dart';
import 'package:century_cqg/Screens/Trade/service/trade_orders_service.dart';
import 'package:century_cqg/Screens/OptionChain/provider/option_chain_provider.dart';
import 'package:century_cqg/app_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig().loadAccountId();
  customClearCache();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardService>(
          create: (_) => DashboardService(),
        ),
        ChangeNotifierProvider<WatchlistService>(
          create: (_) => WatchlistService(),
        ),
        ChangeNotifierProvider<AccountService>(create: (_) => AccountService()),
        ChangeNotifierProvider<AccntsTabService>(
          create: (_) => AccntsTabService(),
        ),
        ChangeNotifierProvider<AnalysisService>(
          create: (_) => AnalysisService(),
        ),
        Provider<TradeRepository>(
          create: (_) => TradeRepository(),
          dispose: (_, repository) => repository.close(),
        ),
        Provider<TradeUseCases>(
          create: (context) => TradeUseCases(context.read<TradeRepository>()),
        ),
        ChangeNotifierProvider<StockDetailsProvider>(
          create:
              (context) => StockDetailsProvider(
                useCases: context.read<TradeUseCases>(),
              ),
        ),
        ChangeNotifierProvider<SearchService>(create: (_) => SearchService()),
        ChangeNotifierProvider<LoginService>(create: (_) => LoginService()),
        ChangeNotifierProvider<TradeService>(create: (_) => TradeService()),
        ChangeNotifierProvider<TradePageService>(
          create:
              (context) =>
                  TradePageService(useCases: context.read<TradeUseCases>()),
        ),
        ChangeNotifierProvider<ModifyOrderService>(
          create:
              (context) =>
                  ModifyOrderService(useCases: context.read<TradeUseCases>()),
        ),
        ChangeNotifierProvider<HoldingService>(create: (_) => HoldingService()),
        ChangeNotifierProvider<HistoryService>(
          create:
              (context) =>
                  HistoryService(useCases: context.read<TradeUseCases>()),
        ),
        ChangeNotifierProvider<ExecutionService>(
          create:
              (context) =>
                  ExecutionService(useCases: context.read<TradeUseCases>()),
        ),
        ChangeNotifierProvider<TradeOrdersService>(
          create:
              (context) => TradeOrdersService(
                useCases: context.read<TradeUseCases>(),
                onFillApplied: (fill) async {
                  final tradePageService = context.read<TradePageService>();
                  await Future.wait([
                    context.read<ExecutionService>().fetchExecutions(),
                    context.read<HistoryService>().fetchHistory(),
                    tradePageService.refreshPositions(),
                    tradePageService.refreshPositionDetails(
                      symbolName: fill.symbolName,
                    ),
                  ]);
                },
                onOrderCompleted: () {
                  unawaited(
                    context.read<TradePageService>().fetchPositions(context),
                  );
                },
                onOrderUpdated: () {
                  unawaited(context.read<ExecutionService>().fetchExecutions());
                  unawaited(context.read<HistoryService>().fetchHistory());
                },
              ),
        ),
        ChangeNotifierProvider<OptionChainNotifier>(
          create: (_) => OptionChainNotifier(),
        ),
        Provider<OptionChainState>(create: (_) => OptionChainState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardService>(
      builder: (context, dashboardService, _) {
        final isDarkMode = NerveBase().isDarkMode;

        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF6F6F6),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: NerveScreensNames.splash,
          routes: NerveNavigator.appRoutes,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

void customClearCache() {
  NerveBase().clearImageCache();
}

