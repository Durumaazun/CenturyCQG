class MarketMoverModel {
  List<Data>? data;

  MarketMoverModel({this.data});

  MarketMoverModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? symbol;
  String? type;
  double? price;
  double? percentageChange;
  double? pointsChange;
  double? bid;
  double? ask;

  Data({
    this.symbol,
    this.type,
    this.price,
    this.percentageChange,
    this.pointsChange,
    this.bid,
    this.ask,
  });

  Data.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol']?.toString() ?? "";
    type = json['type']?.toString() ?? "";
    price = double.parse(json['price']?.toString() ?? "0");
    percentageChange = double.parse(
      json['percentageChange']?.toString() ?? "0",
    );
    pointsChange = double.parse(json['pointsChange']?.toString() ?? "0");
    bid = double.parse(json['bid']?.toString() ?? "0");
    ask = double.parse(json['ask']?.toString() ?? "0");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbol'] = symbol;
    data['type'] = type;
    data['price'] = price;
    data['percentageChange'] = percentageChange;
    data['pointsChange'] = pointsChange;
    data['bid'] = bid;
    data['ask'] = ask;
    return data;
  }
}
