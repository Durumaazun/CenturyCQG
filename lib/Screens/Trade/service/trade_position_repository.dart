import 'package:flutter/material.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:century_cqg/Network/network_manager.dart';

class TradePositionRepository {
  Future<Object?> fetchPositions(BuildContext context, {String data = 'All'}) =>
      NetworkManager(context).getApi(
        apiName: APINames.tradePositions,
        queryParameters: {'Data': data},
        includeFailureResponse: true,
      );

  Future<Object?> deletePosition(
    BuildContext context, {
    required String symbolName,
  }) => NetworkManager(context).deleteApi(
    apiName: APINames.deleteTradePosition,
    deleteBodyData: {'symbolName': symbolName},
    includeFailureResponse: true,
  );
}
