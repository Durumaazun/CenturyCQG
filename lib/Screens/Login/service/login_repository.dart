import 'package:flutter/material.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:century_cqg/Network/network_manager.dart';

class LoginRepository {
  //Login
  Future<Object?> login(
    BuildContext context, {
    required String userId,
    required String password,
  }) => NetworkManager(context).postApi(
    apiName: APINames.login,
    postBodyData: {'user_name': userId, 'password': password},
    includeFailureResponse: true,
  );
}
