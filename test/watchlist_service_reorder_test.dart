import 'package:century_cqg/Screens/Watchlist/model/get_symbol_from_watchlist_response.dart';
import 'package:century_cqg/Screens/Watchlist/service/watchlist_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late WatchlistService service;

  setUp(() {
    service = WatchlistService();
    service.setWatchlistItemsFor('Favourites', [
      _productItem('AAPL'),
      _productItem('NVDA'),
      _productItem('TSLA'),
    ]);
    service.enterEditMode();
  });

  tearDown(() {
    service.dispose();
  });

  test('reports reordering only when current order differs from start', () {
    expect(service.hasEditableItemsReordered, isFalse);

    service.reorderEditableItem(0, 2);
    expect(service.hasEditableItemsReordered, isTrue);

    service.reorderEditableItem(1, 0);
    expect(service.hasEditableItemsReordered, isFalse);
  });

  test('does not count removing an item as reordering', () {
    service.removeEditableItem(0);

    expect(service.hasEditableItemsReordered, isFalse);
  });

  test('applies selected deletions in the current reordered order', () {
    service.reorderEditableItem(0, 2);
    service.toggleEditableItemSelection(service.editableItems[1].item1);

    service.saveChanges();

    expect(
      service
          .getWatchlistItemsFor('Favourites')
          .map((item) => item.symbol)
          .toList(),
      ['NVDA', 'TSLA'],
    );
  });
}

ProductItem _productItem(String symbol) => ProductItem(
  symbol: symbol,
  price: 1,
  percentageChange: 0,
  pointsChange: 0,
  bid: 1,
  ask: 1,
);
