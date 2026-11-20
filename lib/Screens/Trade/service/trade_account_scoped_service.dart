import 'package:century_cqg/app_config.dart';
import 'package:flutter/foundation.dart';

abstract class TradeAccountScopedService extends ChangeNotifier {
  TradeAccountScopedService({String? Function()? accountIdProvider})
    : _accountIdProvider = accountIdProvider ?? (() => AppConfig().accountId) {
    _accountScope = currentAccountId;
  }

  final String? Function() _accountIdProvider;
  String? _accountScope;

  String? get currentAccountId {
    final value = _accountIdProvider()?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  @protected
  String? synchronizeAccountScope() {
    final accountId = currentAccountId;
    if (accountId != _accountScope) {
      _accountScope = accountId;
      clearAccountState();
    }
    return accountId;
  }

  @protected
  bool isCurrentAccount(String? accountId) =>
      accountId != null &&
      accountId == _accountScope &&
      accountId == currentAccountId;

  @protected
  void clearAccountState();
}
