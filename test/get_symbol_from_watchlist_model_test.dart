import 'package:century_cqg/Screens/Watchlist/model/get_symbol_from_watchlist_request.dart';
import 'package:century_cqg/Screens/Watchlist/model/get_symbol_from_watchlist_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('request serializes watchlistName', () {
    const request = GetSymbolFromWatchlistRequest(watchlistName: 'Favourites');

    expect(request.toJson(), {'watchlistName': 'Favourites'});
  });

  test('response parses productList into typed product items', () {
    final response = GetSymbolFromWatchlistResponse.fromJson({
      'productList': [
        {
          'symbol': 'AAPL',
          'price': 577.87,
          'percentageChange': 3.76,
          'pointsChange': 46.23,
          'bid': 1130.04,
          'ask': 1125.08,
        },
      ],
    });

    expect(response.productList, hasLength(1));
    expect(response.productList.single.symbol, 'AAPL');
    expect(response.productList.single.price, 577.87);
    expect(response.productList.single.percentageChange, 3.76);
    expect(response.productList.single.pointsChange, 46.23);
    expect(response.productList.single.bid, 1130.04);
    expect(response.productList.single.ask, 1125.08);
  });
}
