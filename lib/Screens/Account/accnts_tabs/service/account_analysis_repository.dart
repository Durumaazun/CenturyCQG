import 'package:flutter/material.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:century_cqg/Network/network_manager.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_request_model.dart';

class AccountAnalysisRepository {
  Future<Object?> fetchPerformance(
    BuildContext context, {
    required AccountAnalysisPerformanceRequest request,
  }) => NetworkManager(context).postApi(
    apiName: APINames.accountAnalysisPerformance,
    postBodyData: request.toJson(),
    includeFailureResponse: true,
  );

  Future<Object?> fetchCalendar(
    BuildContext context, {
    required AccountAnalysisCalendarRequest request,
  }) => NetworkManager(context).postApi(
    apiName: APINames.accountAnalysisCalendar,
    postBodyData: request.toJson(),
    includeFailureResponse: true,
  );
}
