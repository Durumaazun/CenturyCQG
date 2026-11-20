class AnalysisDayDetails {
  const AnalysisDayDetails({
    required this.netPnl,
    required this.tradeCount,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.trades,
  });

  final double netPnl;
  final int tradeCount;
  final int wins;
  final int losses;
  final double winRate;
  final List<AnalysisDayTrade> trades;

  factory AnalysisDayDetails.fromJson(Map<String, dynamic> json) {
    final rawTrades = json['trades'];
    if (rawTrades is! List) {
      throw const FormatException(
        'Analysis day details "trades" must be a list.',
      );
    }

    return AnalysisDayDetails(
      netPnl: _requiredDouble(json, 'net_pnl'),
      tradeCount: _requiredInt(json, 'trade_count'),
      wins: _requiredInt(json, 'wins'),
      losses: _requiredInt(json, 'losses'),
      winRate: _requiredDouble(json, 'win_rate'),
      trades:
          rawTrades.map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Analysis day trade entries must be objects.',
              );
            }
            return AnalysisDayTrade.fromJson(Map<String, dynamic>.from(item));
          }).toList(),
    );
  }
}

class AnalysisDayTrade {
  const AnalysisDayTrade({
    required this.symbol,
    required this.time,
    required this.side,
    required this.action,
    required this.netPnl,
    required this.bid,
    required this.ask,
    required this.changePercent,
    required this.changePoints,
    required this.units,
    required this.amount,
    required this.stopLoss,
    required this.takeProfit,
    required this.commission,
  });

  final String symbol;
  final String time;
  final String side;
  final String action;
  final double netPnl;
  final double bid;
  final double ask;
  final double changePercent;
  final double changePoints;
  final num units;
  final double amount;
  final double stopLoss;
  final double takeProfit;
  final double commission;

  factory AnalysisDayTrade.fromJson(Map<String, dynamic> json) {
    return AnalysisDayTrade(
      symbol: _requiredString(json, 'symbol'),
      time: _requiredString(json, 'time'),
      side: _requiredString(json, 'side'),
      action: _requiredString(json, 'action'),
      netPnl: _requiredDouble(json, 'net_pnl'),
      bid: _requiredDouble(json, 'bid'),
      ask: _requiredDouble(json, 'ask'),
      changePercent: _requiredDouble(json, 'change_percent'),
      changePoints: _requiredDouble(json, 'change_points'),
      units: _requiredNumber(json, 'units'),
      amount: _requiredDouble(json, 'amount'),
      stopLoss: _requiredDouble(json, 'stop_loss'),
      takeProfit: _requiredDouble(json, 'take_profit'),
      commission: _requiredDouble(json, 'commission'),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key]?.toString().trim();
  if (value == null || value.isEmpty) {
    throw FormatException('Analysis day trade "$key" is missing.');
  }
  return value;
}

num _requiredNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  final parsed = value is num ? value : num.tryParse('$value');
  if (parsed == null || !parsed.isFinite) {
    throw FormatException('Analysis day details "$key" is invalid.');
  }
  return parsed;
}

double _requiredDouble(Map<String, dynamic> json, String key) =>
    _requiredNumber(json, key).toDouble();

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = _requiredNumber(json, key);
  if (value % 1 != 0) {
    throw FormatException('Analysis day details "$key" must be an integer.');
  }
  return value.toInt();
}
