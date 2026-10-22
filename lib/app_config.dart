import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:century_cqg/Helper/nerve_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _accountIdPreferenceKey = 'account_id';

  static AppConfig? _singleton;
  AppPlatform currentPlatform = AppPlatform.web;
  String? _accountId;

  factory AppConfig() {
    //return _singleton;

    if (_singleton == null) {
      _singleton = AppConfig._internal();

      return _singleton!;
    } else {
      return _singleton!;
    }
  }

  AppConfig._internal() {
    if (kIsWeb) {
      currentPlatform = AppPlatform.web;
    } else {
      if ((Platform.isIOS) || (Platform.isAndroid)) {
        currentPlatform = AppPlatform.mobile;
      }
    }
  }

  String? get accountId => _accountId;

  Future<void> loadAccountId() async {
    final preferences = await SharedPreferences.getInstance();
    _accountId = preferences.getString(_accountIdPreferenceKey);
  }

  Future<bool> saveAccountId(String accountId) async {
    final normalizedAccountId = accountId.trim();
    if (normalizedAccountId.isEmpty) {
      return false;
    }

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _accountIdPreferenceKey,
      normalizedAccountId,
    );
    if (saved) {
      _accountId = normalizedAccountId;
    }
    return saved;
  }
}
