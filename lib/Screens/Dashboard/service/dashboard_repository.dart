import 'package:flutter/material.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:century_cqg/Network/network_manager.dart';

class DashboardRepository {
  // Account Summary
  Future<Object?> fetchAccountSummary(BuildContext context) =>
      NetworkManager(context).postApi(
        apiName: APINames.accountSummary,
        postBodyData: {"isFromDash": true},
      );

  // Watched Stocks
  Future<Object?> fetchWatchedStocks(BuildContext context) => NetworkManager(
    context,
  ).getApi(apiName: APINames.watchedStocks, includeFailureResponse: true);

  Future<Object?> fetchTopPositions(BuildContext context) => NetworkManager(
    context,
  ).getApi(apiName: APINames.topPositions, queryParameters: {'isFrom': 'Home'});

  // Market Updates
  Future<Object?> fetchMarketUpdates(
    BuildContext context, {
    required String category,
  }) => NetworkManager(context).getApi(
    apiName: APINames.marketMover,
    queryParameters: {'category': category},
    includeFailureResponse: true,
  );

  Future<Object?> fetchActivityFeed(
    BuildContext context, {
    required String accountId,
  }) => NetworkManager(context).postApi(
    apiName: APINames.activityFeed,
    postBodyData: {'accnt_id': accountId, 'isAll': true},
    includeFailureResponse: true,
  );
}
