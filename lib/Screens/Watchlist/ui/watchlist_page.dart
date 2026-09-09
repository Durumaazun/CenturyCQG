import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Helper/nerve_colors.dart';
import 'package:century_cqg/Helper/nerve_styles.dart';
import 'package:century_cqg/Screens/Watchlist/model/watchlist_item.dart';
import 'package:century_cqg/Screens/Watchlist/service/watchlist_service.dart';
import 'package:century_cqg/Screens/Watchlist/ui/create_watchlist_page.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  bool _isEditing = false;
  bool _isRenamingInline = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _renameFocusNode = FocusNode();
  List<Tuple2<String, WatchlistItem>> _editableItems = [];
  String? _editingWatchlistName;

  @override
  void dispose() {
    _nameController.dispose();
    _renameFocusNode.dispose();
    super.dispose();
  }

  void _startInlineRename(WatchlistService watchlistService) {
    setState(() {
      _nameController.text = watchlistService.selectedWatchlistName;
      _isRenamingInline = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renameFocusNode.requestFocus();
    });
  }

  void _submitInlineRename(WatchlistService watchlistService) async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty &&
        newName != watchlistService.selectedWatchlistName) {
      final renamed = await watchlistService.renameSelectedWatchlist(newName);
      if (!renamed && mounted) {
        _showYellowErrorSnackBar(context, 'Unable to rename watchlist');
      }
    }
    if (mounted) {
      setState(() {
        _isRenamingInline = false;
      });
    }
  }

  void _enterEditMode(WatchlistService watchlistService) {
    final selectedWatchlistName = watchlistService.selectedWatchlistName;
    final items = watchlistService.getWatchlistItemsFor(selectedWatchlistName);
    setState(() {
      _isEditing = true;
      _editingWatchlistName = selectedWatchlistName;
      _nameController.text = selectedWatchlistName;
      _editableItems =
          items
              .asMap()
              .entries
              .map(
                (e) => Tuple2<String, WatchlistItem>(
                  '${e.key}_${e.value.symbol}_${DateTime.now().millisecondsSinceEpoch}',
                  e.value,
                ),
              )
              .toList();
    });
  }

  void _saveChanges(WatchlistService watchlistService) async {
    final newName = _nameController.text.trim();
    if (_editingWatchlistName != null) {
      if (newName.isNotEmpty && newName != _editingWatchlistName) {
        await watchlistService.renameSelectedWatchlist(newName);
      }
      watchlistService.setWatchlistItemsFor(
        newName.isNotEmpty ? newName : _editingWatchlistName!,
        _editableItems.map((e) => e.item2).toList(),
      );
    }
    setState(() {
      _isEditing = false;
      _editingWatchlistName = null;
      _editableItems = [];
    });
  }

  void _cancelEditMode() {
    setState(() {
      _isEditing = false;
      _editingWatchlistName = null;
      _editableItems = [];
    });
  }

  void _showYellowErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFC600),
      ),
    );
  }

  Future<void> _showAddToWatchlistBottomSheet(
    BuildContext context,
    WatchlistService watchlistService,
  ) async {
    final watchlistNames = List<String>.from(watchlistService.watchedLists);
    final selectedNames = <String>{
      watchlistService.watchedLists[watchlistService.selectedTabIndex],
    };

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDarkMode = NerveBase().isDarkMode;
        final panelColor = isDarkMode ? const Color(0xFF0D110F) : Colors.white;
        final borderColor =
            isDarkMode ? const Color(0xFF484E4B) : const Color(0xFFD8DDE3);
        final titleColor = isDarkMode ? Colors.white : const Color(0xFF2A2A2A);
        final subtitleColor =
            isDarkMode ? const Color(0xFF8C9390) : const Color(0xFF6D726F);

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) return;
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: StatefulBuilder(
            builder: (stfContext, setModalState) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(stfContext).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 24,
                        bottom: 24,
                      ),
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Add to Watchlist',
                                  style: NerveStyles.black_medium_16(
                                    isDarkMode,
                                  ).copyWith(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    () => Navigator.of(sheetContext).pop(),
                                tooltip: 'Cancel',
                                icon: Icon(
                                  Icons.close,
                                  color: titleColor,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select or create a watchlist where you\'ll like to add this product',
                            style: NerveStyles.grey_medium_14(
                              isDarkMode,
                            ).copyWith(height: 1.3, color: subtitleColor),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 140,
                            child: SingleChildScrollView(
                              child: Column(
                                children:
                                    watchlistNames
                                        .map(
                                          (name) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: Checkbox(
                                                    value: selectedNames
                                                        .contains(name),
                                                    activeColor: const Color(
                                                      0xFFFFC600,
                                                    ),
                                                    checkColor: Colors.black,
                                                    side: BorderSide(
                                                      color:
                                                          isDarkMode
                                                              ? const Color(
                                                                0xFF7D8481,
                                                              )
                                                              : const Color(
                                                                0xFFB0B7B3,
                                                              ),
                                                    ),
                                                    onChanged: (value) {
                                                      setModalState(() {
                                                        if (value ?? false) {
                                                          selectedNames.add(
                                                            name,
                                                          );
                                                        } else {
                                                          selectedNames.remove(
                                                            name,
                                                          );
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style:
                                                        NerveStyles.black_medium_14_500(
                                                          isDarkMode,
                                                        ).copyWith(
                                                          color: titleColor,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    Navigator.of(sheetContext).pop();
                                    final createdName = await Navigator.of(
                                      context,
                                    ).push<String>(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const CreateWatchlistPage(),
                                      ),
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    if (createdName != null) {
                                      watchlistService.selectWatchlistByName(
                                        createdName,
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: borderColor),
                                    foregroundColor: titleColor,
                                    minimumSize: const Size.fromHeight(44),
                                  ),
                                  child: const Text('Create New'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    for (final name
                                        in watchlistService.watchedLists) {
                                      if (selectedNames.contains(name)) {
                                        watchlistService.selectWatchlistByName(
                                          name,
                                        );
                                        break;
                                      }
                                    }
                                    Navigator.of(sheetContext).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC600),
                                    foregroundColor: Colors.black,
                                    minimumSize: const Size.fromHeight(44),
                                  ),
                                  child: const Text('Done'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _avatarColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'AAPL':
        return const Color(0xFF111111);
      case 'NVDA':
        return const Color(0xFF76B900);
      case 'TSLA':
        return const Color(0xFFE82127);
      default:
        return const Color(0xFF4A90E2);
    }
  }

  Widget _buildCompanyLogo(String symbol) {
    final upper = symbol.toUpperCase();
    if (upper == 'AAPL') {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.apple, color: Colors.white, size: 22),
      );
    } else if (upper == 'NVDA') {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
        ),
        padding: const EdgeInsets.all(2),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.remove_red_eye_rounded,
              color: Color(0xFF76B900),
              size: 14,
            ),
            Text(
              'NVIDIA',
              style: TextStyle(
                fontSize: 6,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );
    } else if (upper == 'TSLA') {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE82127),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Text(
          'T',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'serif',
          ),
        ),
      );
    } else {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _avatarColor(symbol),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          symbol.isNotEmpty ? symbol.substring(0, 1) : '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  Future<void> _deleteSelectedWatchlist(
    BuildContext context,
    WatchlistService watchlistService,
  ) async {
    if (watchlistService.watchedLists.length > 1) {
      final watchlistName =
          watchlistService.watchedLists[watchlistService.selectedTabIndex];

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final isDarkMode = NerveBase().isDarkMode;
          final panelColor =
              isDarkMode ? const Color(0xFF0D110F) : Colors.white;
          final borderColor =
              isDarkMode ? const Color(0xFF484E4B) : const Color(0xFFD8DDE3);
          final titleColor =
              isDarkMode ? Colors.white : const Color(0xFF2A2A2A);

          return SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete $watchlistName',
                      style: NerveStyles.black_medium_16(
                        isDarkMode,
                      ).copyWith(color: titleColor),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: borderColor),
                              foregroundColor:
                                  isDarkMode
                                      ? const Color(0xFFB6BAB8)
                                      : const Color(0xFF5F6368),
                              minimumSize: const Size.fromHeight(44),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final deleted =
                                  await watchlistService
                                      .deleteSelectedWatchlist();
                              if (!sheetContext.mounted) {
                                return;
                              }

                              Navigator.of(sheetContext).pop();

                              if (!deleted && context.mounted) {
                                _showYellowErrorSnackBar(
                                  context,
                                  'At least one watchlist is required',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE03A55),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(44),
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    final deleted = await watchlistService.deleteSelectedWatchlist();
    if (!context.mounted) {
      return;
    }

    if (!deleted) {
      _showYellowErrorSnackBar(context, 'At least one watchlist is required');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = NerveBase().isDarkMode;
    final watchlistService = context.watch<WatchlistService>();
    final selectedWatchlistName = watchlistService.selectedWatchlistName;
    final List<WatchlistItem> items = watchlistService.getWatchlistItemsFor(
      selectedWatchlistName,
    );

    // If active watchlist changed externally while editing, exit edit mode
    if (_isEditing && _editingWatchlistName != selectedWatchlistName) {
      _isEditing = false;
      _editingWatchlistName = null;
      _editableItems = [];
    }

    final backgroundColor =
        isDarkMode ? const Color(0xFF0D110F) : const Color(0xFFFFFFFF);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF2A2A2A);

    if (_isEditing) {
      return Container(
        width: double.infinity,
        color: backgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: IntrinsicWidth(
                            child: TextField(
                              controller: _nameController,
                              style: NerveStyles.black_medium_16(
                                isDarkMode,
                              ).copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 2,
                                ),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFF2C400),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        isDarkMode
                                            ? Colors.white24
                                            : const Color(0xFFD8DDE3),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFF2C400),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.drive_file_rename_outline,
                          size: 18,
                          color:
                              isDarkMode
                                  ? const Color(0xFF9AA0A6)
                                  : const Color(0xFF5F6368),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFD32F2F),
                      size: 22,
                    ),
                    tooltip: 'Delete Watchlist',
                    onPressed:
                        () =>
                            _deleteSelectedWatchlist(context, watchlistService),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child:
                  _editableItems.isEmpty
                      ? Center(
                        child: Text(
                          'No items in watchlist',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      )
                      : Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          itemCount: _editableItems.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = _editableItems.removeAt(oldIndex);
                              _editableItems.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            final tuple = _editableItems[index];
                            final item = tuple.item2;
                            final isPositive = item.changePercent >= 0;

                            return Container(
                              key: ValueKey(tuple.item1),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                        isDarkMode
                                            ? const Color(0xFF1C211E)
                                            : const Color(0xFFF5F5F5),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12,
                                        left: 4,
                                      ),
                                      child: Icon(
                                        Icons.menu,
                                        color:
                                            isDarkMode
                                                ? Colors.grey[600]
                                                : const Color(0xFFB0B7B3),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  _buildCompanyLogo(item.symbol),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.symbol,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                isDarkMode
                                                    ? Colors.grey[400]
                                                    : const Color(0xFF6E7471),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isDarkMode
                                                  ? NerveColors.chartbgGreenDark
                                                  : NerveColors
                                                      .chartbgGreenLigth,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          'lib/Resources/Images/line_chart.svg',
                                          width: 62,
                                          height: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${isPositive ? '+' : ''}${item.changePercent.toStringAsFixed(2)}% (+4.89 pts)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF27B67A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _editableItems.removeAt(index);
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.close,
                                        color:
                                            isDarkMode
                                                ? Colors.grey[400]
                                                : const Color(0xFF9E9E9E),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color:
                        isDarkMode
                            ? const Color(0xFF1C211E)
                            : const Color(0xFFEEEEEE),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: _cancelEditMode,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          foregroundColor:
                              isDarkMode ? Colors.white70 : Colors.black87,
                          side: BorderSide(
                            color:
                                isDarkMode ? Colors.white24 : Colors.grey[300]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => _saveChanges(watchlistService),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          backgroundColor: const Color(0xFFF2C400),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? const Color(0xFF1C211E) : Colors.transparent,
            width: isDarkMode ? 1 : 0,
          ),
          bottom: BorderSide(
            color: isDarkMode ? const Color(0xFF1C211E) : Colors.transparent,
            width: isDarkMode ? 1 : 0,
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isRenamingInline)
                      Flexible(
                        child: IntrinsicWidth(
                          child: TextField(
                            focusNode: _renameFocusNode,
                            controller: _nameController,
                            style: NerveStyles.black_medium_16(
                              isDarkMode,
                            ).copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 2,
                              ),
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF2C400),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      isDarkMode
                                          ? Colors.white24
                                          : const Color(0xFFD8DDE3),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF2C400),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onSubmitted:
                                (_) => _submitInlineRename(watchlistService),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: Text(
                          selectedWatchlistName,
                          overflow: TextOverflow.ellipsis,
                          style: NerveStyles.black_medium_16(
                            isDarkMode,
                          ).copyWith(height: 1.0),
                        ),
                      ),
                    const SizedBox(width: 6),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      tooltip:
                          _isRenamingInline
                              ? 'Save Name'
                              : 'Edit WatchedList Name',
                      onPressed: () {
                        if (_isRenamingInline) {
                          _submitInlineRename(watchlistService);
                        } else {
                          _startInlineRename(watchlistService);
                        }
                      },
                      icon: Icon(
                        _isRenamingInline
                            ? Icons.check
                            : Icons.drive_file_rename_outline,
                        size: 18,
                        color:
                            _isRenamingInline
                                ? const Color(0xFF1DB854)
                                : (isDarkMode
                                    ? const Color(0xFF9AA0A6)
                                    : const Color(0xFF5F6368)),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isRenamingInline) ...[
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  tooltip: 'Add to Watchlist',
                  onPressed:
                      () => _showAddToWatchlistBottomSheet(
                        context,
                        watchlistService,
                      ),
                  icon: Icon(
                    Icons.add,
                    size: 22,
                    color:
                        isDarkMode
                            ? const Color(0xFF9AA0A6)
                            : const Color(0xFF5F6368),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  tooltip: 'Edit Watchlist',
                  onPressed: () => _enterEditMode(watchlistService),
                  icon: const Icon(
                    Icons.edit_square,
                    size: 18,
                    color: Color(0xFF1E55CF),
                  ),
                ),
              ],
            ],
          ),
          (items.isEmpty)
              ? Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC600),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 22,
                    onPressed:
                        () => _showAddToWatchlistBottomSheet(
                          context,
                          watchlistService,
                        ),
                    icon: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
              )
              : const SizedBox(height: 2),
          ...items.map((item) {
            final isPositive = item.changePercent >= 0;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: NerveStyles.rowBorderColor(isDarkMode),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildCompanyLogo(item.symbol),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.symbol,
                          style: NerveStyles.black_bold_16(isDarkMode),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: NerveStyles.grey_medium_13(isDarkMode),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? NerveColors.chartbgGreenDark
                                  : NerveColors.chartbgGreenLigth,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: SvgPicture.asset(
                          'lib/Resources/Images/line_chart.svg',
                          width: 74,
                          height: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        children: [
                          Text(
                            '${isPositive ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                            style: NerveStyles.green_medium_14(
                              isDarkMode,
                            ).copyWith(color: const Color(0xFF27B67A)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${(item.price * 0.08).toStringAsFixed(2)} pts)',
                            style: NerveStyles.green_medium_12_400(
                              isDarkMode,
                            ).copyWith(color: const Color(0xFF27B67A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'B ${(item.price + 552.17).toStringAsFixed(2)}',
                        style: NerveStyles.grey_medium_13(isDarkMode),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A ${(item.price + 547.21).toStringAsFixed(2)}',
                        style: NerveStyles.grey_medium_13(isDarkMode),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
