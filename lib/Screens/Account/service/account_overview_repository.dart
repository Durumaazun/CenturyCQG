import 'package:flutter/material.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:century_cqg/Network/network_manager.dart';

class AccountOverviewRepository {
  Future<Object?> fetchOverview(BuildContext context) => NetworkManager(
    context,
  ).getApi(apiName: APINames.accountOverview, includeFailureResponse: true);

  Future<Object?> fetchAllocation(BuildContext context) => NetworkManager(
    context,
  ).getApi(apiName: APINames.accountAllocation, includeFailureResponse: true);
}
