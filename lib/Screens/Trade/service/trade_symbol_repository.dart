import 'package:flutter/material.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:century_cqg/Network/network_manager.dart';

class TradeSymbolRepository {
  Future<Object?> fetchSymbolDetails(
    BuildContext context, {
    required String symbolName,
  }) => NetworkManager(context).getApi(
    apiName: APINames.tradeSymbolDetails,
    queryParameters: {'symbolName': symbolName},
    includeFailureResponse: true,
  );
}
