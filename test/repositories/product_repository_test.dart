import 'package:date_checker_app/api/products_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  ProductsApiClient productsApiClient;
  ProductRepository productRepository;
  AppDatabase db;
  List<Product> products;
  Product product1;
  Product product2;
  setUp(() async {
    db = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    productsApiClient = MockProductsApiClient();
    productRepository =
        ProductRepository(db: db, productsApiClient: productsApiClient);
    product1 = Product(1, 1, "Coca Cola", 30.0, "1001");
    product2 = Product(2, 2, "Pepsi", 40.0, "1002");
    products = [
      Product(3, 3, "Schweppes", 50.0, "1003"),
      Product(4, 4, "Mirinda", 45.0, "1004")
    ];
  });

  test('throws AssertionError when productsApiClient is null', () {
    expect(
      () => ProductRepository(productsApiClient: null, db: db),
      throwsAssertionError,
    );
  });
  test('throws AssertionError when db is null', () {
    expect(
      () => ProductRepository(productsApiClient: productsApiClient, db: null),
      throwsAssertionError,
    );
  });

  group('getAllProducts test', () {
    setUp(() async {
      await db.productDao.add(product1);
      await db.productDao.add(product2);
    });
    test('return 2 already saved products from the db', () async {
      List<Product> products = await productRepository.getAllProducts();
      expect(products.length, 2);
      expect(products[0].name, "Coca Cola");
    });
  });

  group('syncProducts test', () {
    test('sync products when they are synced', () async {
      await db.productDao.add(product1);
      var lastProductId = await db.productDao.getLastServerId();

      when(productsApiClient.getLatestProducts(lastProductId))
          .thenAnswer((_) => Future.value([]));
      int newProductsLength = await productRepository.syncProducts();
      expect(newProductsLength, 0);
    });

    test('sync products when they are not synced', () async {
      await db.productDao.add(product1);
      var lastProductId = await db.productDao.getLastServerId();
      when(productsApiClient.getLatestProducts(lastProductId))
          .thenAnswer((_) => Future.value(products));
      int newProductsLength = await productRepository.syncProducts();
      expect(newProductsLength, 2);
    });

    test('sync products when db is empty', () async {
      when(productsApiClient.getAllProductsFromServer())
          .thenAnswer((_) => Future.value(products));
      int newProductsLength = await productRepository.syncProducts();
      expect(newProductsLength, 2);
    });
  });

  group('saveProductsLocally test', () {
    test('saving successfully 2 new products', () async {
      await productRepository.saveProductsLocally(products);
      List<Product> productsFromDb = await db.productDao.all();
      expect(productsFromDb.length, 2);
    });
    test('saving no data', () async {
      await productRepository.saveProductsLocally([]);
      List<Product> productsFromDb = await db.productDao.all();
      expect(productsFromDb.length, 0);
    });
    test('saving data that already exists', () async {
      await productRepository.saveProductsLocally(products);
      try {
        await productRepository.saveProductsLocally(products);
        fail('Should throw');
      } catch (e) {
        expect(e.toString(),
            'Exception: Error when saving products to the database');
      }
    });
  });

  tearDown(() async {
    await db.close();
  });
}
