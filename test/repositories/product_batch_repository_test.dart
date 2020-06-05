import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/product_batch_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  ProductBatchApiClient productBatchApiClient;
  ProductBatchRepository productBatchRepository;
  AppDatabase db;
  ProductBatch productBatch;
  ProductBatch productBatch2;
  setUp(() async {
    db = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    productBatchApiClient = MockProductBatchApiClient();
    productBatchRepository = ProductBatchRepository(
      db: db,
      productBatchApiClient: productBatchApiClient,
    );
    productBatch = ProductBatch(null, 1, '1001', 1, 30, "2020-03-11", false,
        DateTime.now().toString(), DateTime.now().toString(), 'Schweppes');
    productBatch2 = ProductBatch(null, 2, '1002', 2, 40, "2020-05-11", false,
        DateTime.now().toString(), DateTime.now().toString(), 'Coca Cola');
  });
  test('throws AssertionError when productsApiClient is null', () {
    expect(
      () => ProductBatchRepository(productBatchApiClient: null, db: db),
      throwsAssertionError,
    );
  });
  test('throws AssertionError when db is null', () {
    expect(
      () => ProductBatchRepository(
          productBatchApiClient: productBatchApiClient, db: null),
      throwsAssertionError,
    );
  });

  group('addProductBatch tests', () {
    test('add valid product batch', () async {
      await productBatchRepository.addProductBatch(productBatch);
      final batches = await db.productBatchDao.all();
      expect(batches.length, 1);
    });

    test('add already saved product product batch', () async {
      await productBatchRepository.addProductBatch(productBatch);
      productBatch.id = 1;
      try {
        await productBatchRepository.addProductBatch(productBatch);
      } catch (e) {
        expect(
            e.toString(), "Exception: Error saving product batch to database.");
      }
    });
  });

  group('allProductBatchList tests', () {
    test('get all product batch list success', () async {
      productBatch.updated = "2020-06-05 23:35:57.205937";
      await db.productBatchDao
          .saveProductBatches([productBatch, productBatch2]);

      List<ProductBatch> batches =
          await productBatchRepository.allProductBatchList();

      expect(batches.length, 2);

      // productBatch2 has newer update
      expect(batches[0].productName, productBatch2.productName);
    });
  });
}
