import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:century_cqg/Screens/Watchlist/model/watchlist_item.dart';

class WatchlistService extends ChangeNotifier {
  static const String _watchedListsKey = 'watched_lists';

  final List<String> _watchedLists = ['Favourites'];
  String _dataOwnerWatchlistName = 'Favourites';
  int _selectedTabIndex = 0;
  Future<void>? _loadFuture;

  final Map<String, List<WatchlistItem>> _watchlistItemsMap = {
    'Favourites': [
      const WatchlistItem(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        price: 577.87,
        changePercent: 3.76,
      ),
      const WatchlistItem(
        symbol: 'NVDA',
        companyName: 'NVIDIA Corp.',
        price: 577.87,
        changePercent: 3.76,
      ),
      const WatchlistItem(
        symbol: 'TSLA',
        companyName: 'Tesla Inc.',
        price: 577.87,
        changePercent: 3.76,
      ),
      const WatchlistItem(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        price: 577.87,
        changePercent: 3.76,
      ),
      const WatchlistItem(
        symbol: 'NVDA',
        companyName: 'NVIDIA Corp.',
        price: 577.87,
        changePercent: 3.76,
      ),
      const WatchlistItem(
        symbol: 'TSLA',
        companyName: 'Tesla Inc.',
        price: 577.87,
        changePercent: 3.76,
      ),
    ],
  };

  List<String> get watchedLists => List.unmodifiable(_watchedLists);

  int get selectedTabIndex {
    if (_watchedLists.isEmpty) {
      return 0;
    }
    if (_selectedTabIndex >= _watchedLists.length) {
      return _watchedLists.length - 1;
    }
    return _selectedTabIndex;
  }

  List<WatchlistItem> getWatchlistItems() {
    return getWatchlistItemsFor(selectedWatchlistName);
  }

  String get selectedWatchlistName {
    if (_watchedLists.isEmpty) {
      return 'Favourites';
    }
    return _watchedLists[selectedTabIndex];
  }

  List<WatchlistItem> getWatchlistItemsFor(String watchlistName) {
    if (!_watchlistItemsMap.containsKey(watchlistName)) {
      if (watchlistName.toLowerCase() ==
          _dataOwnerWatchlistName.toLowerCase()) {
        _watchlistItemsMap[watchlistName] = [
          const WatchlistItem(
            symbol: 'AAPL',
            companyName: 'Apple Inc.',
            price: 577.87,
            changePercent: 3.76,
          ),
          const WatchlistItem(
            symbol: 'NVDA',
            companyName: 'NVIDIA Corp.',
            price: 577.87,
            changePercent: 3.76,
          ),
          const WatchlistItem(
            symbol: 'TSLA',
            companyName: 'Tesla Inc.',
            price: 577.87,
            changePercent: 3.76,
          ),
        ];
      } else {
        _watchlistItemsMap[watchlistName] = [];
      }
    }
    return List.unmodifiable(_watchlistItemsMap[watchlistName] ?? []);
  }

  void setWatchlistItemsFor(String watchlistName, List<WatchlistItem> items) {
    _watchlistItemsMap[watchlistName] = List<WatchlistItem>.from(items);
    notifyListeners();
  }

  void removeWatchlistItem(String watchlistName, int index) {
    final list = _watchlistItemsMap[watchlistName];
    if (list != null && index >= 0 && index < list.length) {
      list.removeAt(index);
      notifyListeners();
    }
  }

  void reorderWatchlistItems(String watchlistName, int oldIndex, int newIndex) {
    final list = _watchlistItemsMap[watchlistName];
    if (list != null) {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      notifyListeners();
    }
  }

  Future<void> loadWatchedLists() {
    _loadFuture ??= _loadWatchedListsInternal();
    return _loadFuture!;
  }

  Future<void> _loadWatchedListsInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_watchedListsKey);

    if (saved == null || saved.isEmpty) {
      return;
    }

    _watchedLists
      ..clear()
      ..addAll(saved);

    // Keep sample data attached to whichever list previously represented favourites.
    if (!_watchedLists.any(
      (name) => name.toLowerCase() == _dataOwnerWatchlistName.toLowerCase(),
    )) {
      _dataOwnerWatchlistName = _watchedLists.first;
    }

    if (_selectedTabIndex >= _watchedLists.length) {
      _selectedTabIndex = _watchedLists.length - 1;
    }

    notifyListeners();
  }

  Future<void> _persistWatchedLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_watchedListsKey, _watchedLists);
  }

  Future<bool> addWatchedList(String name) async {
    await loadWatchedLists();

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return false;
    }

    final alreadyExists = _watchedLists.any(
      (item) => item.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (!alreadyExists) {
      _watchedLists.add(trimmedName);
      _selectedTabIndex = _watchedLists.length - 1;
      await _persistWatchedLists();
      notifyListeners();
      return true;
    }

    return false;
  }

  void setSelectedTabIndex(int index) {
    if (index < 0 || index >= _watchedLists.length) {
      return;
    }
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void selectWatchlistByName(String name) {
    final target = name.trim().toLowerCase();
    if (target.isEmpty) {
      return;
    }

    final index = _watchedLists.indexWhere(
      (item) => item.toLowerCase() == target,
    );

    if (index != -1) {
      setSelectedTabIndex(index);
    }
  }

  Future<bool> renameSelectedWatchlist(String newName) async {
    await loadWatchedLists();

    if (_watchedLists.isEmpty) {
      return false;
    }

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return false;
    }

    final currentIndex = selectedTabIndex;
    final duplicateIndex = _watchedLists.indexWhere(
      (item) => item.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (duplicateIndex != -1 && duplicateIndex != currentIndex) {
      return false;
    }

    final oldName = _watchedLists[currentIndex];
    _watchedLists[currentIndex] = trimmedName;

    // Renaming must not change list data ownership.
    if (oldName.toLowerCase() == _dataOwnerWatchlistName.toLowerCase()) {
      _dataOwnerWatchlistName = trimmedName;
    }

    await _persistWatchedLists();
    notifyListeners();
    return true;
  }

  Future<bool> deleteSelectedWatchlist() async {
    await loadWatchedLists();

    if (_watchedLists.length <= 1) {
      return false;
    }

    final removedName = _watchedLists[selectedTabIndex];
    _watchedLists.removeAt(selectedTabIndex);

    if (_watchedLists.isNotEmpty &&
        removedName.toLowerCase() == _dataOwnerWatchlistName.toLowerCase()) {
      _dataOwnerWatchlistName = _watchedLists.first;
    }

    if (_selectedTabIndex >= _watchedLists.length) {
      _selectedTabIndex = _watchedLists.length - 1;
    }

    await _persistWatchedLists();
    notifyListeners();
    return true;
  }
}
