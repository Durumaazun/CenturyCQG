import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:century_cqg/app_config.dart';
import 'package:century_cqg/Network/network_manager.dart';
import 'package:century_cqg/Screens/Login/model/login_response_model.dart';
import 'package:century_cqg/Screens/Login/service/login_repository.dart';

class LoginService extends ChangeNotifier {
  final _repository = LoginRepository();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _useSandbox = false;
  bool _showPassword = false;
  String _userId = 'nerve@gmail.com';
  String _password = '';
  String? _errorMessage;
  String? _userIdError;
  String? _passwordError;

  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  bool get useSandbox => _useSandbox;
  bool get showPassword => _showPassword;
  String? get errorMessage => _errorMessage;
  String? get userIdError => _userIdError;
  String? get passwordError => _passwordError;

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void setUseSandbox(bool value) {
    _useSandbox = value;
    notifyListeners();
  }

  void setUserId(String value) {
    _userId = value;
    _userIdError = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordError = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(BuildContext context) async {
    _errorMessage = null;
    final userId = _userId.trim();

    _userIdError = userId.isEmpty ? 'User ID cannot be empty' : null;
    _passwordError =
        _password.trim().isEmpty ? 'Password cannot be empty' : null;
    if (_userIdError != null || _passwordError != null) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final rawResponse = await _repository.login(
        context,
        userId: userId,
        password: _password,
      );

      if (rawResponse == null) {
        _errorMessage =
            'Unable to sign in. Check your connection and try again.';
        return false;
      }

      if (rawResponse is NetworkResponse) {
        final response = LoginResponseModel.fromJson(
          statusCode: rawResponse.statusCode,
          body: rawResponse.body,
        );
        final serverMessage = response.message ?? response.error;
        _errorMessage =
            response.statusCode == 405
                ? 'Login endpoint rejected POST (405 Method Not Allowed). '
                    'Check that the server exposes this login route as POST.'
                : serverMessage ?? 'Login failed (${response.statusCode}).';
        return false;
      }

      final response = LoginResponseModel.fromJson(
        statusCode: 200,
        body: jsonEncode(rawResponse),
      );

      if (response.isSuccess &&
          (response.error == null || response.error!.trim().isEmpty)) {
        final accountId = response.accountId?.trim();
        if (accountId != null && accountId.isNotEmpty) {
          final saved = await AppConfig().saveAccountId(accountId);
          if (!saved) {
            _errorMessage = 'Unable to save the account ID on this device.';
            return false;
          }
        }
        return true;
      }

      _errorMessage =
          response.error ??
          response.message ??
          'Login failed (${response.statusCode}).';
    } on http.ClientException catch (error) {
      _errorMessage = 'Unable to connect to the login server: ${error.message}';
    } on TimeoutException {
      _errorMessage = 'The login request timed out. Please try again.';
    } on FormatException {
      _errorMessage = 'The login server returned an invalid response.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  void clearError() {
    _errorMessage = null;
    _userIdError = null;
    _passwordError = null;
    notifyListeners();
  }
}
