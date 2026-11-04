import 'dart:async';

import 'package:century_cqg/Screens/Scalper/ui/scalper_page.dart';
import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:century_cqg/Helper/nerve_colors.dart';
import 'package:century_cqg/Screens/Dashboard/service/dasboard_service.dart';
import 'package:century_cqg/Screens/Watchlist/service/watchlist_service.dart';
import 'package:century_cqg/Screens/Account/ui/account_page.dart';
import 'package:century_cqg/Screens/Dashboard/ui/dashboard_body_view.dart';
import 'package:century_cqg/Screens/Dashboard/ui/dashboard_appbar.dart';
import 'package:century_cqg/Screens/Watchlist/ui/watchlist_page.dart';
import 'package:century_cqg/Screens/Watchlist/ui/watchlist_dialogs.dart';
import 'package:century_cqg/Screens/Trade/ui/positions/trade_page.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Helper/nerve_styles.dart';

enum _WatchlistMenuAction { rename, delete }

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => MobileHomePageState();
}

class MobileHomePageState extends State<MobileHomePage> {
  Timer? _watchlistTapTimer;
  int? _watchlistTapCandidateIndex;
  bool _watchlistWasSelectedAtFirstTap = false;

  final List<String> _tabNames = [
    'Home',
    'Watchlists',
    'Account',
    'Trades',
    'Scalper',
  ];

  bool _isFavouritesWatchlist(String name) {
    final normalizedName = name.trim().toLowerCase();
    return normalizedName == 'favourites' || normalizedName == 'favorites';
  }

  List<PopupMenuEntry<_WatchlistMenuAction>> _watchlistMenuItems(
    String name,
    int watchlistCount,
  ) {
    return [
      if (!_isFavouritesWatchlist(name))
        const PopupMenuItem(
          value: _WatchlistMenuAction.rename,
          child: Row(
            children: [
              Icon(Icons.drive_file_rename_outline, size: 20),
              SizedBox(width: 10),
              Text('Rename'),
            ],
          ),
        ),
      if (watchlistCount > 1)
        const PopupMenuItem(
          value: _WatchlistMenuAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Color(0xFFD32F2F), size: 20),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: Color(0xFFD32F2F))),
            ],
          ),
        ),
    ];
  }

  Future<void> _showWatchlistMenuAt(int index, Offset globalPosition) async {
    final watchlistService = context.read<WatchlistService>();
    if (index < 0 || index >= watchlistService.watchedLists.length) {
      return;
    }

    final screenSize = MediaQuery.sizeOf(context);
    final menuItems = _watchlistMenuItems(
      watchlistService.watchedLists[index],
      watchlistService.watchedLists.length,
    );
    if (menuItems.isEmpty) {
      return;
    }

    final action = await showMenu<_WatchlistMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        screenSize.width - globalPosition.dx,
        screenSize.height - globalPosition.dy,
      ),
      items: menuItems,
    );
    if (action != null && mounted) {
      await _handleWatchlistMenuAction(index, action);
    }
  }

  void _recordWatchlistTabTap(int index) {
    final watchlistService = context.read<WatchlistService>();
    if (_watchlistTapCandidateIndex != index) {
      _watchlistTapCandidateIndex = index;
      _watchlistWasSelectedAtFirstTap =
          watchlistService.selectedTabIndex == index;
    }

    _watchlistTapTimer?.cancel();
    _watchlistTapTimer = Timer(kDoubleTapTimeout, () {
      _watchlistTapCandidateIndex = null;
      _watchlistWasSelectedAtFirstTap = false;
    });
  }

  void _openWatchlistMenuOnDoubleTap(int index, Offset globalPosition) {
    final wasSelectedBeforeDoubleTap =
        _watchlistTapCandidateIndex == index && _watchlistWasSelectedAtFirstTap;
    _watchlistTapTimer?.cancel();
    _watchlistTapCandidateIndex = null;
    _watchlistWasSelectedAtFirstTap = false;

    if (wasSelectedBeforeDoubleTap &&
        context.read<WatchlistService>().selectedTabIndex == index) {
      _showWatchlistMenuAt(index, globalPosition);
    }
  }

  Future<void> _handleWatchlistMenuAction(
    int index,
    _WatchlistMenuAction action,
  ) async {
    final watchlistService = context.read<WatchlistService>();
    if (index < 0 || index >= watchlistService.watchedLists.length) {
      return;
    }

    watchlistService.setSelectedTabIndex(index);
    if (action == _WatchlistMenuAction.rename) {
      await _renameWatchlist(watchlistService);
    } else {
      await _deleteWatchlist(watchlistService);
    }
  }

  Future<void> _renameWatchlist(WatchlistService watchlistService) async {
    final controller = TextEditingController(
      text: watchlistService.selectedWatchlistName,
    );
    final newName = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Rename watchlist'),
            content: TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              textInputAction: TextInputAction.done,
              onSubmitted:
                  (value) => Navigator.of(dialogContext).pop(value.trim()),
              decoration: InputDecoration(
                labelText: 'Watchlist name',
                labelStyle: const TextStyle(color: Colors.black54),
                floatingLabelStyle: const TextStyle(color: Colors.black),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    () =>
                        Navigator.of(dialogContext).pop(controller.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC600),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Rename'),
              ),
            ],
          ),
    );
    controller.dispose();
    if (newName == null || !mounted) {
      return;
    }

    final renamed = await watchlistService.renameSelectedWatchlist(
      context,
      newName,
    );
    if (!renamed && mounted) {
      _showWatchlistError(
        watchlistService.watchlistMutationError ??
            'Unable to rename watchlist.',
      );
    }
  }

  Future<void> _deleteWatchlist(WatchlistService watchlistService) async {
    final watchlistName = watchlistService.selectedWatchlistName;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Delete $watchlistName?'),
            content: const Text('This will permanently delete this watchlist.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (shouldDelete != true || !mounted) {
      return;
    }

    final deleted = await watchlistService.deleteSelectedWatchlist(context);
    if (!deleted && mounted) {
      _showWatchlistError(
        watchlistService.watchlistMutationError ??
            'Unable to delete watchlist.',
      );
    }
  }

  void _showWatchlistError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFC600),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final dashboardService = context.read<DashboardService>();
    dashboardService.callAccountSummary(context);
    dashboardService.callWatchedStocks(context);
    dashboardService.callTopPositions(context);
    dashboardService.callActivityFeed(context);
    dashboardService.callMarketUpdates(context, category: 'trending');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWatchlistsAfterLogin();
    });
  }

  Future<void> _loadWatchlistsAfterLogin() async {
    final watchlistService = context.read<WatchlistService>();
    await watchlistService.fetchWatchlists(context);
    if (!mounted) {
      return;
    }
    if (context.read<DashboardService>().selectedHomeTabIndex == 1) {
      await watchlistService.fetchWatchlistSymbols();
    }
  }

  void _selectWatchlistTab(int index) {
    final watchlistService = context.read<WatchlistService>();
    if (watchlistService.selectedTabIndex == index) {
      return;
    }
    watchlistService.setSelectedTabIndex(index);
    watchlistService.fetchWatchlistSymbols(
      watchlistName: watchlistService.selectedWatchlistName,
    );
  }

  @override
  void dispose() {
    _watchlistTapTimer?.cancel();
    super.dispose();
  }

  Widget _buildPageContent(
    bool isDarkMode,
    int selectedIndex,
    DashboardService dashboardService,
  ) {
    if (selectedIndex == 0) {
      return DashboardBodyView();
    } else if (selectedIndex == 1) {
      return WatchlistPage();
    } else if (selectedIndex == 2) {
      return AccountPage();
    } else if (selectedIndex == 3) {
      final initialTab = dashboardService.isFromDetails ? 1 : 0;

      return TradePage(initialTabIndex: initialTab);
    } else if (selectedIndex == 4) {
      return ScalperPage();
    } else {
      return Center(
        child: Text(
          _tabNames[selectedIndex],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardService = context.watch<DashboardService>();
    final watchlistService = context.watch<WatchlistService>();
    final selectedIndex = dashboardService.selectedHomeTabIndex;

    NerveBase().getScreenSize(NerveBase().screenWidth, false);
    final isDarkMode = NerveBase().isDarkMode;
    final watchlistTabs = watchlistService.watchedLists;
    final selectedWatchlistTabIndex = watchlistService.selectedTabIndex;

    final bgColor = NerveColors.projectBackgroundColor(isDarkMode);

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: bgColor,
        appBar:
            selectedIndex == 0
                ? const DashboardAppbar()
                : selectedIndex == 1
                ? const CommonAppbar(title: 'Watched list')
                : selectedIndex == 2
                ? const CommonAppbar(title: 'Accounts')
                : selectedIndex == 3
                ? const CommonAppbar(title: 'Trades')
                : null,
        body: SafeArea(
          top: selectedIndex == 0 || selectedIndex == 4,
          child: Container(
            width: NerveBase().screenWidth,
            color: bgColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedIndex == 1)
                  Container(
                    width: double.infinity,
                    color:
                        isDarkMode
                            ? const Color(0xFF0D110F)
                            : NerveColors.solidWhiteColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(watchlistTabs.length, (
                                index,
                              ) {
                                var doubleTapPosition = Offset.zero;
                                return GestureDetector(
                                  // A tap selects the tab; double-click, holding, or right-click opens its actions.
                                  onTapDown:
                                      (_) => _recordWatchlistTabTap(index),
                                  onTapUp: (_) => _selectWatchlistTab(index),
                                  onDoubleTapDown:
                                      (details) =>
                                          doubleTapPosition =
                                              details.globalPosition,
                                  onDoubleTap:
                                      () => _openWatchlistMenuOnDoubleTap(
                                        index,
                                        doubleTapPosition,
                                      ),
                                  onLongPressEnd:
                                      (details) => _showWatchlistMenuAt(
                                        index,
                                        details.globalPosition,
                                      ),
                                  onSecondaryTapUp:
                                      (details) => _showWatchlistMenuAt(
                                        index,
                                        details.globalPosition,
                                      ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          watchlistTabs[index],
                                          style:
                                              selectedWatchlistTabIndex == index
                                                  ? NerveStyles.black_medium_14_400(
                                                    isDarkMode,
                                                  )
                                                  : NerveStyles.grey_medium_14(
                                                    isDarkMode,
                                                  ),
                                        ),
                                      ),
                                      if (selectedWatchlistTabIndex == index)
                                        Container(
                                          height: 3,
                                          width: 78,
                                          color: NerveColors.selectedNavColor,
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final watchlistProvider =
                                context.read<WatchlistService>();
                            final createdName = await showCreateWatchlistDialog(
                              context,
                              watchlistProvider,
                            );

                            if (!context.mounted || createdName == null) {
                              return;
                            }
                            watchlistProvider.selectWatchlistByName(
                              createdName,
                            );
                            watchlistProvider.fetchWatchlistSymbols(
                              watchlistName: createdName,
                            );
                          },
                          icon: Icon(
                            Icons.add,
                            size: 24,
                            color: NerveStyles.iconColor(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (selectedIndex == 1)
                  Container(
                    height: 1,
                    color:
                        isDarkMode ? const Color(0xFF282D2A) : Colors.grey[300],
                  ),
                if (selectedIndex != 1 &&
                    selectedIndex != 2 &&
                    selectedIndex != 3)
                  Container(height: 8, color: bgColor),
                Expanded(
                  child:
                      selectedIndex == 0
                          ? SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(height: 2, color: bgColor),
                                DashboardBodyView(),
                              ],
                            ),
                          )
                          : selectedIndex == 1
                          ? Column(
                            children: [
                              const Expanded(child: WatchlistPage()),
                              Container(height: 8, color: bgColor),
                            ],
                          )
                          : _buildPageContent(
                            isDarkMode,
                            selectedIndex,
                            dashboardService,
                          ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color:
                    NerveBase().isDarkMode
                        ? const Color(0xFF282D2A)
                        : Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            backgroundColor:
                NerveBase().isDarkMode ? const Color(0xFF0D110F) : Colors.white,
            selectedItemColor: NerveColors.selectedNavColor,

            unselectedItemColor:
                NerveBase().isDarkMode ? Colors.grey[600] : Colors.grey[400],
            elevation: 0,
            enableFeedback: false,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'lib/Resources/Images/x home icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 0
                        ? NerveColors.selectedNavColor
                        : (NerveBase().isDarkMode
                            ? Colors.grey[600]!
                            : Colors.grey[400]!),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'lib/Resources/Images/x Watchlist Icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 1
                        ? NerveColors.selectedNavColor
                        : (NerveBase().isDarkMode
                            ? Colors.grey[600]!
                            : Colors.grey[400]!),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Watchlists',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'lib/Resources/Images/Group 876.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 2
                        ? NerveColors.selectedNavColor
                        : (NerveBase().isDarkMode
                            ? Colors.grey[600]!
                            : Colors.grey[400]!),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Account',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'lib/Resources/Images/x trades icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 3
                        ? NerveColors.selectedNavColor
                        : (NerveBase().isDarkMode
                            ? Colors.grey[600]!
                            : Colors.grey[400]!),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Trades',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'lib/Resources/Images/Group 877.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 4
                        ? NerveColors.selectedNavColor
                        : (NerveBase().isDarkMode
                            ? Colors.grey[600]!
                            : Colors.grey[400]!),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Scalper',
              ),
            ],
            onTap: (index) {
              context.read<DashboardService>().setSelectedHomeTabIndex(index);
              if (index == 1) {
                context.read<WatchlistService>().fetchWatchlistSymbols();
              }
            },
          ),
        ),
      ),
    );
  }
}
