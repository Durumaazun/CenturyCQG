import 'dart:math';

class TradeOrderRequest {
  const TradeOrderRequest({
    required this.symbolName,
    required this.side,
    required this.quantity,
    required this.orderType,
    required this.amount,
    this.limitPrice,
    this.stopPrice,
    this.stopLoss,
    this.takeProfit,
  });

  final String symbolName;
  final String side;
  final num quantity;
  final String orderType;
  final num amount;
  final num? limitPrice;
  final num? stopPrice;
  final num? stopLoss;
  final num? takeProfit;

  Map<String, Object?> toJson() => {
    'symbolName': symbolName,
    'BS': side.toLowerCase(),
    'quantity': quantity,
    'orderType': orderType.toLowerCase(),
    'amount': amount,
    'limitPrice': limitPrice,
    'stopPrice': stopPrice,
    'stopLoss': stopLoss,
    'takeProfit': takeProfit,
  };
}

class TradeOrder {
  const TradeOrder({
    required this.orderId,
    required this.symbolName,
    required this.side,
    required this.orderType,
    required this.amount,
    required this.quantity,
    required this.filledQuantity,
    required this.remainingQuantity,
    required this.status,
    required this.limitPrice,
    required this.stopPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.createdAt,
    required this.updatedAt,
    required this.completionReported,
  });

  final String orderId;
  final String symbolName;
  final String side;
  final String orderType;
  final double amount;
  final num quantity;
  final num filledQuantity;
  final num remainingQuantity;
  final String status;
  final double? limitPrice;
  final double? stopPrice;
  final double? stopLoss;
  final double? takeProfit;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool completionReported;

  factory TradeOrder.fromJson(Map<String, dynamic> json) => TradeOrder(
    orderId: _requiredString(json, 'orderId'),
    symbolName: _requiredString(json, 'symbolName'),
    side: _requiredString(json, 'BS'),
    orderType: _requiredString(json, 'orderType'),
    amount: _number(json, 'amount').toDouble(),
    quantity: _number(json, 'quantity'),
    filledQuantity: _number(json, 'filledQuantity'),
    remainingQuantity: _number(json, 'remainingQuantity'),
    status: _requiredString(json, 'status'),
    limitPrice: _optionalNumber(json, 'limitPrice')?.toDouble(),
    stopPrice: _optionalNumber(json, 'stopPrice')?.toDouble(),
    stopLoss: _optionalNumber(json, 'stopLoss')?.toDouble(),
    takeProfit: _optionalNumber(json, 'takeProfit')?.toDouble(),
    createdAt: _optionalDate(json, 'createdAt'),
    updatedAt: _optionalDate(json, 'updatedAt'),
    completionReported: json['completionReported'] == true,
  );
}

class TradeFillRequest {
  const TradeFillRequest({
    required this.orderId,
    required this.fillId,
    required this.filledUnits,
    required this.fillPrice,
  });

  final String orderId;
  final String fillId;
  final num filledUnits;
  final double fillPrice;

  factory TradeFillRequest.create({
    required String orderId,
    required num filledUnits,
    required double fillPrice,
  }) => TradeFillRequest(
    orderId: orderId,
    fillId: _newUuidV4(),
    filledUnits: filledUnits,
    fillPrice: fillPrice,
  );

  Map<String, Object?> toJson() => {
    'orderId': orderId,
    'fillId': fillId,
    'filledUnits': filledUnits,
    'fillPrice': fillPrice,
  };
}

String _newUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

class TradeFillResult {
  const TradeFillResult({
    required this.orderId,
    required this.status,
    required this.symbolName,
    required this.side,
    required this.units,
    required this.amount,
    required this.orderType,
    required this.timeInForce,
    required this.goodTillDate,
    required this.limitPrice,
    required this.stopEntryPrice,
    required this.filledUnits,
    required this.remainingUnits,
    required this.completionReported,
  });

  final String orderId;
  final String status;
  final String symbolName;
  final String side;
  final num units;
  final double amount;
  final String orderType;
  final String timeInForce;
  final DateTime? goodTillDate;
  final double? limitPrice;
  final double? stopEntryPrice;
  final num filledUnits;
  final num remainingUnits;
  final bool completionReported;

  factory TradeFillResult.fromJson(Map<String, dynamic> json) =>
      TradeFillResult(
        orderId: _requiredString(json, 'orderId'),
        status: _requiredString(json, 'status'),
        symbolName: _requiredString(json, 'symbolName'),
        side: _requiredString(json, 'BS'),
        units: _number(json, 'units'),
        amount: _number(json, 'amount').toDouble(),
        orderType: _requiredString(json, 'orderType'),
        timeInForce: _requiredString(json, 'timeInForce'),
        goodTillDate: _optionalDate(json, 'goodTillDate'),
        limitPrice: _optionalNumber(json, 'limitPrice')?.toDouble(),
        stopEntryPrice: _optionalNumber(json, 'stopEntryPrice')?.toDouble(),
        filledUnits: _number(json, 'filledUnits'),
        remainingUnits: _number(json, 'remainingUnits'),
        completionReported: json['completionReported'] == true,
      );
}

class TradeExecution {
  const TradeExecution({
    required this.executionId,
    required this.orderId,
    required this.symbolName,
    required this.side,
    required this.fillQuantity,
    required this.fillPrice,
    required this.amount,
    required this.executedAt,
  });

  final String executionId;
  final String orderId;
  final String symbolName;
  final String side;
  final num fillQuantity;
  final double fillPrice;
  final double amount;
  final DateTime? executedAt;

  factory TradeExecution.fromJson(Map<String, dynamic> json) => TradeExecution(
    executionId: _requiredString(json, 'executionId'),
    orderId: _requiredString(json, 'orderId'),
    symbolName: _requiredString(json, 'symbolName'),
    side: _requiredString(json, 'BS'),
    fillQuantity: _number(json, 'fillQuantity'),
    fillPrice: _number(json, 'fillPrice').toDouble(),
    amount: _number(json, 'amount').toDouble(),
    executedAt: _optionalDate(json, 'executedAt'),
  );
}

class TradeHistoryItem {
  const TradeHistoryItem({
    required this.orderId,
    required this.symbolName,
    required this.side,
    required this.status,
    required this.filledQuantity,
    required this.amount,
    required this.price,
    required this.realizedPnl,
    required this.stopLoss,
    required this.takeProfit,
    required this.updatedAt,
  });

  final String orderId;
  final String symbolName;
  final String side;
  final String status;
  final num filledQuantity;
  final double amount;
  final double price;
  final double realizedPnl;
  final double? stopLoss;
  final double? takeProfit;
  final DateTime? updatedAt;

  factory TradeHistoryItem.fromJson(Map<String, dynamic> json) =>
      TradeHistoryItem(
        orderId: _requiredString(json, 'orderId'),
        symbolName: _requiredString(json, 'symbolName'),
        side: _requiredString(json, 'BS'),
        status: _requiredString(json, 'status'),
        filledQuantity: _number(json, 'filledQuantity'),
        amount: _number(json, 'amount').toDouble(),
        price: _number(json, 'price').toDouble(),
        realizedPnl: _number(json, 'realizedPnl').toDouble(),
        stopLoss: _optionalNumber(json, 'stopLoss')?.toDouble(),
        takeProfit: _optionalNumber(json, 'takeProfit')?.toDouble(),
        updatedAt: _optionalDate(json, 'updatedAt'),
      );
}

class NetPositionDetail {
  const NetPositionDetail({
    required this.side,
    required this.netUnit,
    required this.avgPrice,
    required this.netPnl,
  });

  final String side;
  final num netUnit;
  final double avgPrice;
  final double netPnl;

  factory NetPositionDetail.fromJson(Map<String, dynamic> json) =>
      NetPositionDetail(
        side: _requiredString(json, 'b_s'),
        netUnit: _number(json, 'netUnit'),
        avgPrice: _number(json, 'avgPrice').toDouble(),
        netPnl: _number(json, 'netPnl').toDouble(),
      );
}

class TradePositionSummary {
  const TradePositionSummary({
    required this.symbolName,
    required this.side,
    required this.netUnit,
    required this.avgPrice,
    required this.netPnl,
    required this.marketPrice,
    required this.positionValue,
  });

  final String symbolName;
  final String side;
  final num netUnit;
  final double avgPrice;
  final double netPnl;
  final double marketPrice;
  final double positionValue;

  factory TradePositionSummary.fromJson(Map<String, dynamic> json) =>
      TradePositionSummary(
        symbolName: _requiredString(json, 'symbolName'),
        side: _requiredString(json, 'b_s'),
        netUnit: _number(json, 'netUnit'),
        avgPrice: _number(json, 'avgPrice').toDouble(),
        netPnl: _number(json, 'netPnl').toDouble(),
        marketPrice: _number(json, 'marketPrice').toDouble(),
        positionValue: _number(json, 'positionValue').toDouble(),
      );
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key]?.toString().trim();
  if (value == null || value.isEmpty) {
    throw FormatException('Trade response "$key" is missing.');
  }
  return value;
}

num _number(Map<String, dynamic> json, String key) {
  final value = json[key];
  final parsed = value is num ? value : num.tryParse('$value');
  if (parsed == null || !parsed.isFinite) {
    throw FormatException('Trade response "$key" is invalid.');
  }
  return parsed;
}

num? _optionalNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  final parsed = value is num ? value : num.tryParse('$value');
  if (parsed == null || !parsed.isFinite) {
    throw FormatException('Trade response "$key" is invalid.');
  }
  return parsed;
}

DateTime? _optionalDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null || value.toString().trim().isEmpty) return null;
  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) {
    throw FormatException('Trade response "$key" is invalid.');
  }
  return parsed;
}
