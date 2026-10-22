import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:century_cqg/Screens/Watchlist/model/watchlist_item.dart';
import 'package:century_cqg/Screens/Watchlist/service/watchlist_repository.dart';
import 'package:century_cqg/Network/network_manager.dart';

class WatchlistService extends ChangeNotifier {
  static const String _watchedListsKey = 'watched_lists';
  final WatchlistRepository _repository = WatchlistRepository();

  final List<String> _watchedLists = ['Favourites'];
  int _selectedTabIndex = 0;
  Future<void>? _loadFuture;

  bool _isEditing = false;
  bool _isRenamingInline = false;
  String? _editingWatchlistName;
  List<Tuple2<String, WatchlistItem>> _editableItems = [];
  Set<String> _selectedAddToWatchlistNames = {};
  String? _createWatchlistErrorText;
  String? _watchlistMutationError;
  bool _isLoadingWatchlists = false;
  String? _watchlistsError;

  final Map<String, List<WatchlistItem>> _watchlistItemsMap = {};

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

  bool get isEditing => _isEditing;
  bool get isRenamingInline => _isRenamingInline;
  String? get editingWatchlistName => _editingWatchlistName;
  List<Tuple2<String, WatchlistItem>> get editableItems =>
      List.unmodifiable(_editableItems);
  Set<String> get selectedAddToWatchlistNames => _selectedAddToWatchlistNames;
  String? get createWatchlistErrorText => _createWatchlistErrorText;
  String? get watchlistMutationError => _watchlistMutationError;
  bool get isLoadingWatchlists => _isLoadingWatchlists;
  String? get watchlistsError => _watchlistsError;

  bool _isFavouritesWatchlist(String name) {
    final normalizedName = name.trim().toLowerCase();
    return normalizedName == 'favourites' || normalizedName == 'favorites';
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

  void startInlineRename() {
    if (_isFavouritesWatchlist(selectedWatchlistName)) {
      return;
    }
    _isRenamingInline = true;
    notifyListeners();
  }

  void stopInlineRename() {
    _isRenamingInline = false;
    notifyListeners();
  }

  Future<bool> submitInlineRename(BuildContext context, String newName) async {
    final trimmed = newName.trim();
    if (_isFavouritesWatchlist(selectedWatchlistName)) {
      _isRenamingInline = false;
      _watchlistMutationError = 'Favourites cannot be renamed.';
      notifyListeners();
      return false;
    }
    bool success = true;
    if (trimmed.isNotEmpty && trimmed != selectedWatchlistName) {
      success = await renameSelectedWatchlist(context, trimmed);
    }
    _isRenamingInline = false;
    notifyListeners();
    return success;
  }

  void enterEditMode() {
    _isEditing = true;
    _editingWatchlistName = selectedWatchlistName;
    final items = getWatchlistItemsFor(selectedWatchlistName);
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
    notifyListeners();
  }

  void removeEditableItem(int index) {
    if (index >= 0 && index < _editableItems.length) {
      _editableItems.removeAt(index);
      notifyListeners();
    }
  }

  void reorderEditableItem(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _editableItems.removeAt(oldIndex);
    _editableItems.insert(newIndex, item);
    notifyListeners();
  }

  void saveChanges() {
    if (_editingWatchlistName != null) {
      setWatchlistItemsFor(
        _editingWatchlistName!,
        _editableItems.map((e) => e.item2).toList(),
      );
    }
    _isEditing = false;
    _editingWatchlistName = null;
    _editableItems = [];
    notifyListeners();
  }

  void cancelEditMode() {
    _isEditing = false;
    _editingWatchlistName = null;
    _editableItems = [];
    notifyListeners();
  }

  void initAddToWatchlistSelection() {
    _selectedAddToWatchlistNames = {
      if (_watchedLists.isNotEmpty) _watchedLists[selectedTabIndex],
    };
    notifyListeners();
  }

  void toggleAddToWatchlistSelection(String name) {
    if (_selectedAddToWatchlistNames.contains(name)) {
      _selectedAddToWatchlistNames.remove(name);
    } else {
      _selectedAddToWatchlistNames.add(name);
    }
    notifyListeners();
  }

  void setCreateWatchlistError(String? error) {
    _createWatchlistErrorText = error;
    notifyListeners();
  }

  Future<void> loadWatchedLists() {
    _loadFuture ??= _loadWatchedListsInternal();
    return _loadFuture!;
  }

  Future<void> fetchWatchlists(BuildContext context) async {
    _isLoadingWatchlists = true;
    _watchlistsError = null;
    notifyListeners();

    try {
      final response = await _repository.fetchWatchlists(context);
      if (!context.mounted) return;

      if (response is NetworkResponse) {
        _watchlistsError = _responseError(
          response,
          'Unable to load watchlists.',
        );
        return;
      }

      final Map<String, dynamic>? responseMap =
          response is Map ? Map<String, dynamic>.from(response) : null;
      final watchlistData = responseMap?['watchlist'];
      final data =
          watchlistData is List
              ? watchlistData
              : response is List
              ? response
              : responseMap?['data'] is List
              ? responseMap!['data'] as List
              : null;
      if (data == null) {
        _watchlistsError = 'The watchlists response is invalid.';
        return;
      }

      final names = <String>[];
      for (final item in data) {
        final rawName =
            item is Map ? item['name'] ?? item['watchlistName'] : item;
        final name = rawName?.toString().trim() ?? '';
        if (name.isNotEmpty &&
            !names.any(
              (existing) => existing.toLowerCase() == name.toLowerCase(),
            )) {
          names.add(name);
        }
      }

      final itemsByWatchlist = <String, List<WatchlistItem>>{};
      if (responseMap != null) {
        for (final entry in responseMap.entries) {
          if (entry.value is! List ||
              entry.key == 'watchlist' ||
              entry.key == 'data') {
            continue;
          }

          final key = entry.key.toLowerCase();
          final watchlistName =
              key == 'fav'
                  ? names.cast<String?>().firstWhere(
                    (name) =>
                        name?.toLowerCase() == 'favourites' ||
                        name?.toLowerCase() == 'favorites',
                    orElse: () => null,
                  )
                  : names.cast<String?>().firstWhere(
                    (name) => name?.toLowerCase() == key,
                    orElse: () => null,
                  );
          if (watchlistName == null) continue;

          itemsByWatchlist[watchlistName] =
              (entry.value as List)
                  .whereType<Map>()
                  .map(
                    (item) =>
                        WatchlistItem.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList();
        }
      }

      final previousSelection = selectedWatchlistName;
      _watchedLists
        ..clear()
        ..addAll(names);
      _watchlistItemsMap
        ..clear()
        ..addAll(itemsByWatchlist);
      _selectedTabIndex = _watchedLists.indexWhere(
        (name) => name.toLowerCase() == previousSelection.toLowerCase(),
      );
      if (_selectedTabIndex < 0) {
        _selectedTabIndex = 0;
      }

      await _persistWatchedLists();
    } finally {
      _isLoadingWatchlists = false;
      notifyListeners();
    }
  }

  Future<void> _loadWatchedListsInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_watchedListsKey);

    if (saved != null && saved.isNotEmpty) {
      _watchedLists
        ..clear()
        ..addAll(saved);
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

  String _responseError(Object? response, String fallback) {
    if (response is NetworkResponse) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final message = decoded['message'] ?? decoded['error'];
          if (message != null && message.toString().trim().isNotEmpty) {
            return message.toString();
          }
        }
      } on FormatException {
        // Use the status code when the server did not return JSON.
      }
      return '$fallback (${response.statusCode})';
    }
    return fallback;
  }

  Future<bool> addWatchedList(BuildContext context, String name) async {
    await loadWatchedLists();
    if (!context.mounted) return false;

    _watchlistMutationError = null;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _watchlistMutationError = 'Watchlist name is required.';
      return false;
    }

    final alreadyExists = _watchedLists.any(
      (item) => item.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (alreadyExists) {
      _watchlistMutationError = 'Watchlist already exists.';
      return false;
    }

    final response = await _repository.addWatchlist(
      context,
      watchlistName: trimmedName,
    );
    if (response == null || response is NetworkResponse) {
      _watchlistMutationError = _responseError(
        response,
        'Unable to create watchlist.',
      );
      notifyListeners();
      return false;
    }

    _watchedLists.add(trimmedName);
    _selectedTabIndex = _watchedLists.length - 1;
    await _persistWatchedLists();
    notifyListeners();
    return true;
  }

  void setSelectedTabIndex(int index) {
    if (index < 0 || index >= _watchedLists.length) {
      return;
    }
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      _isRenamingInline = false;
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

  Future<bool> renameSelectedWatchlist(
    BuildContext context,
    String newName,
  ) async {
    await loadWatchedLists();
    if (!context.mounted) return false;
    _watchlistMutationError = null;

    if (_watchedLists.isEmpty) {
      _watchlistMutationError = 'No watchlist is selected.';
      return false;
    }

    final oldName = _watchedLists[selectedTabIndex];
    if (_isFavouritesWatchlist(oldName)) {
      _watchlistMutationError = 'Favourites cannot be renamed.';
      return false;
    }

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      _watchlistMutationError = 'Watchlist name is required.';
      return false;
    }

    final currentIndex = selectedTabIndex;
    final duplicateIndex = _watchedLists.indexWhere(
      (item) => item.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (duplicateIndex != -1 && duplicateIndex != currentIndex) {
      _watchlistMutationError = 'Watchlist already exists.';
      return false;
    }

    final response = await _repository.renameWatchlist(
      context,
      oldName: oldName,
      newName: trimmedName,
    );
    if (response == null || response is NetworkResponse) {
      _watchlistMutationError = _responseError(
        response,
        'Unable to rename watchlist.',
      );
      notifyListeners();
      return false;
    }

    _watchedLists[currentIndex] = trimmedName;
    final renamedItems = _watchlistItemsMap.remove(oldName);
    if (renamedItems != null) {
      _watchlistItemsMap[trimmedName] = renamedItems;
    }
    await _persistWatchedLists();
    notifyListeners();
    return true;
  }

  Future<bool> deleteSelectedWatchlist(BuildContext context) async {
    await loadWatchedLists();
    if (!context.mounted) return false;
    _watchlistMutationError = null;

    if (_watchedLists.length <= 1) {
      _watchlistMutationError = 'At least one watchlist is required.';
      return false;
    }

    final selectedName = _watchedLists[selectedTabIndex];
    final response = await _repository.deleteWatchlist(
      context,
      watchlistName: selectedName,
    );
    if (response == null || response is NetworkResponse) {
      _watchlistMutationError = _responseError(
        response,
        'Unable to delete watchlist.',
      );
      notifyListeners();
      return false;
    }
    final removedName = _watchedLists[selectedTabIndex];
    _watchedLists.removeAt(selectedTabIndex);
    _watchlistItemsMap.remove(removedName);

    if (_selectedTabIndex >= _watchedLists.length) {
      _selectedTabIndex = _watchedLists.length - 1;
    }
    await _persistWatchedLists();
    notifyListeners();
    return true;
  }
}
