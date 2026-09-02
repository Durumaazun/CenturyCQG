class OptionChainModel {
  final String symbol;
  final List<OptionData> options;
  final String? expirationDate;
  final DateTime? fetchedAt;

  OptionChainModel({
    required this.symbol,
    required this.options,
    this.expirationDate,
    this.fetchedAt,
  });

  factory OptionChainModel.fromJson(Map<String, dynamic> json) {
    return OptionChainModel(
      symbol: json['symbol'] ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => OptionData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expirationDate: json['expirationDate'],
      fetchedAt:
          json['fetchedAt'] != null
              ? DateTime.parse(json['fetchedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'options': options.map((e) => e.toJson()).toList(),
      'expirationDate': expirationDate,
      'fetchedAt': fetchedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'OptionChainModel(symbol: $symbol, options: ${options.length}, expirationDate: $expirationDate)';
}

class OptionData {
  final double strikePrice;
  final String type; // 'call' or 'put'
  final double lastPrice;
  final double bid;
  final double ask;
  final int openInterest;
  final double volume;
  final double impliedVolatility;
  final double delta;
  final double gamma;
  final double theta;
  final double vega;
  final double rho;

  OptionData({
    required this.strikePrice,
    required this.type,
    required this.lastPrice,
    required this.bid,
    required this.ask,
    required this.openInterest,
    required this.volume,
    required this.impliedVolatility,
    required this.delta,
    required this.gamma,
    required this.theta,
    required this.vega,
    required this.rho,
  });

  factory OptionData.fromJson(Map<String, dynamic> json) {
    return OptionData(
      strikePrice: (json['strikePrice'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? 'call',
      lastPrice: (json['lastPrice'] as num?)?.toDouble() ?? 0.0,
      bid: (json['bid'] as num?)?.toDouble() ?? 0.0,
      ask: (json['ask'] as num?)?.toDouble() ?? 0.0,
      openInterest: json['openInterest'] ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      impliedVolatility: (json['impliedVolatility'] as num?)?.toDouble() ?? 0.0,
      delta: (json['delta'] as num?)?.toDouble() ?? 0.0,
      gamma: (json['gamma'] as num?)?.toDouble() ?? 0.0,
      theta: (json['theta'] as num?)?.toDouble() ?? 0.0,
      vega: (json['vega'] as num?)?.toDouble() ?? 0.0,
      rho: (json['rho'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strikePrice': strikePrice,
      'type': type,
      'lastPrice': lastPrice,
      'bid': bid,
      'ask': ask,
      'openInterest': openInterest,
      'volume': volume,
      'impliedVolatility': impliedVolatility,
      'delta': delta,
      'gamma': gamma,
      'theta': theta,
      'vega': vega,
      'rho': rho,
    };
  }

  @override
  String toString() =>
      'OptionData(strike: $strikePrice, type: $type, lastPrice: $lastPrice)';
}
