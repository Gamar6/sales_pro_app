import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_app/services/stock_service.dart';
import 'package:sales_app/services/visit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stock cache is scoped to the current user', () async {
    SharedPreferences.setMockInitialValues({
      'user_id': '10',
      'stock_cache:10': '{"total_skus":2,"low_stock_count":1,"data":[]}',
      'stock_cache:20': '{"total_skus":99,"low_stock_count":0,"data":[]}',
    });

    final cached = await StockService.getCachedStocks();

    expect(cached?['total_skus'], 2);
  });

  test('visit history cache is scoped to the current user', () async {
    SharedPreferences.setMockInitialValues({
      'user_id': '10',
      'visit_history_cache:10': '[{"visit_id":1}]',
      'visit_history_cache:20': '[{"visit_id":2}]',
    });

    final cached = await VisitService().getCachedVisitHistory();

    expect(cached, hasLength(1));
    expect(cached?.single['visit_id'], 1);
  });
}
