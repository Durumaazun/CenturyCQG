class AccountSummaryResponseModel {
  final String currency;
  final double cashBalance;
  final double buyingPower;
  final double unrealizedPnL;
  final double marginUsed;
  final double realizedPnL;

  const AccountSummaryResponseModel({
    this.currency = '',
    this.cashBalance = 0,
    this.buyingPower = 0,
    this.unrealizedPnL = 0,
    this.marginUsed = 0,
    this.realizedPnL = 0,
  });

  factory AccountSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map ? Map<String, dynamic>.from(rawData) : json;

    return AccountSummaryResponseModel(
      currency: data['currency']?.toString() ?? '',
      cashBalance: _parseAmount(data['cashBalance']),
      buyingPower: _parseAmount(data['buyingPower']),
      unrealizedPnL: _parseAmount(data['unrealizedPnL']),
      marginUsed: _parseAmount(data['marginUsed']),
      realizedPnL: _parseAmount(data['realizedPnL']),
    );
  }

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'cashBalance': cashBalance,
    'buyingPower': buyingPower,
    'unrealizedPnL': unrealizedPnL,
    'marginUsed': marginUsed,
    'realizedPnL': realizedPnL,
  };

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
    }
    return 0;
  }
}
