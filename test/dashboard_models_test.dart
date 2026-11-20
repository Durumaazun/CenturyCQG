import 'package:century_cqg/Screens/Dashboard/model/dashboard_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stock.listFromResponse', () {
    test('parses the backend productList response', () {
      final stocks = Stock.listFromResponse({
        'watchlistName': 'Favourites',
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

      expect(stocks, hasLength(1));
      expect(stocks.single.symbol, 'AAPL');
      expect(stocks.single.price, '577.87');
      expect(stocks.single.change, '3.76%');
      expect(stocks.single.changePoints, '46.23');
      expect(stocks.single.logo, isEmpty);
    });

    test('rejects a response without a stock list', () {
      expect(
        () => Stock.listFromResponse({'watchlistName': 'Favourites'}),
        throwsFormatException,
      );
    });
  });
}
