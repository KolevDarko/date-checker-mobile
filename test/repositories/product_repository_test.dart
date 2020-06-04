import 'package:date_checker_app/api/products_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class MockProductClientApi extends ProductsApiClient {
  @override
  Future<List<Product>> getAllProducts() {
    return Future.value([
      Product(1, 1, 'Coca Cola', 30.0, "1001"),
      Product(2, 2, 'Schweppes', 50.0, "2001"),
      Product(3, 3, 'Mirinda', 100.0, "3001"),
    ]);
  }
}

void main() {
  group('ProductRepository', () {
    AppDatabase db;
    ProductsApiClient productsAPI;
    ProductRepository productRepository;

    setUp(() async {
      db = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
      productsAPI = MockProductClientApi();
      productRepository =
          ProductRepository(db: db, productsApiClient: productsAPI);
    });

    tearDown(() async {
      await db.close();
    });

    test('throws AssertionError when httpClient is null', () {});
  });
}
