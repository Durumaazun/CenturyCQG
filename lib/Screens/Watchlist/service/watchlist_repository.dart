import 'package:flutter/material.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:century_cqg/Network/network_manager.dart';

class WatchlistRepository {
  Future<Object?> fetchWatchlists(BuildContext context) => NetworkManager(
    context,
  ).getApi(apiName: APINames.getWatchlist, includeFailureResponse: true);

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
