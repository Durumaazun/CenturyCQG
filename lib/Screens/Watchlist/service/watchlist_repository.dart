import 'package:flutter/material.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:century_cqg/Network/network_manager.dart';
import 'package:century_cqg/Screens/Watchlist/model/get_symbol_from_watchlist_request.dart';
import 'package:century_cqg/Screens/Watchlist/model/get_symbol_from_watchlist_response.dart';

class WatchlistRepository {
  Future<Object?> fetchWatchlists(BuildContext context) =>
      NetworkManager(context).postApi(
        apiName: APINames.getWatchlist,
        postBodyData: const <String, Object?>{},
        includeFailureResponse: true,
        sendEmptyBody: true,
      );

  Future<GetSymbolFromWatchlistResponse> getSymbolsFromWatchlist(
    String watchlistName,
  ) async {
    final normalizedName = watchlistName.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(
        watchlistName,
        'watchlistName',
        'Watchlist name must not be empty.',
      );
    }

    final request = GetSymbolFromWatchlistRequest(
      watchlistName: normalizedName,
    );
    final response = await NetworkManager().postApi(
      apiName: APINames.getSymbolFromWatchlist,
      postBodyData: request.toJson(),
      includeFailureResponse: true,
    );

    if (response is NetworkResponse) {
      throw Exception(
        'Unable to load symbols (${response.statusCode}): ${response.body}',
      );
    }
    if (response == null) {
      throw Exception('Unable to load symbols from the watchlist.');
    }
    if (response is! Map) {
      throw const FormatException('The symbols response must be an object.');
    }

    return GetSymbolFromWatchlistResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<Object?> addWatchlist(
    BuildContext context, {
    required String watchlistName,
  }) => NetworkManager(context).postApi(
    apiName: APINames.addWatchlist,
    postBodyData: {'watchlistName': watchlistName},
  );

  Future<Object?> deleteWatchlist(
    BuildContext context, {
    required String watchlistName,
  }) => NetworkManager(context).postApi(
    apiName: APINames.deleteWatchlist,
    postBodyData: {'watchlistName': watchlistName},
  );

  Future<Object?> renameWatchlist(
    BuildContext context, {
    required String oldName,
    required String newName,
  }) => NetworkManager(context).postApi(
    apiName: APINames.renameWatchlist,
    postBodyData: {'oldName': oldName, 'newName': newName},
  );
}
