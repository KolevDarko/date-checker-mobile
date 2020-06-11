import 'dart:convert';

import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/product_batch_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  ProductBatchApiClient productBatchApiClient;
  ProductBatchRepository productBatchRepository;
  AppDatabase db;
  ProductBatch productBatch;
  ProductBatch productBatch2;
  BatchWarning batchWarning;
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
    batchWarning = BatchWarning(
        null,
        'Coca Cola',
        30,
        '2020-05-11',
        2,
        'NEW',
        'WARNING',
        40,
        40,
        DateTime.now().toString(),
        DateTime.now().toString());
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

    tearDown(() async {
      var warnings = await db.batchWarningDao.all() ?? [];
      var productbatches = await db.productBatchDao.all() ?? [];

      if (warnings.length > 0) {
        for (var warning in warnings) {
          await db.batchWarningDao.delete(warning.id);
        }
      }
      if (productbatches.length > 0) {
        for (var productBatch in productbatches) {
          await db.productBatchDao.delete(productBatch.id);
        }
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
    tearDown(() async {
      var warnings = await db.batchWarningDao.all() ?? [];
      var productbatches = await db.productBatchDao.all() ?? [];

      if (warnings.length > 0) {
        for (var warning in warnings) {
          await db.batchWarningDao.delete(warning.id);
        }
      }
      if (productbatches.length > 0) {
        for (var productBatch in productbatches) {
          await db.productBatchDao.delete(productBatch.id);
        }
      }
    });
  });

  group('getFilteredProductBatches tests', () {
    setUp(() async {
      await db.productBatchDao
          .saveProductBatches([productBatch, productBatch2]);
    });
    test('get product batch by the name of the product', () async {
      String inputString = 'Sch';
      List<ProductBatch> batches =
          await productBatchRepository.getFilteredProductBatches(inputString);
      expect(batches.length, 1);
      expect(batches[0].productName, 'Schweppes');
    });
    tearDown(() async {
      var warnings = await db.batchWarningDao.all() ?? [];
      var productbatches = await db.productBatchDao.all() ?? [];

      if (warnings.length > 0) {
        for (var warning in warnings) {
          await db.batchWarningDao.delete(warning.id);
        }
      }
      if (productbatches.length > 0) {
        for (var productBatch in productbatches) {
          await db.productBatchDao.delete(productBatch.id);
        }
      }
    });
  });

  group('orderedByExpiryDateList tests', () {
    setUp(() async {
      productBatch.expirationDate = '2020-03-11';
      productBatch2.expirationDate = '2020-02-11';
      await db.productBatchDao
          .saveProductBatches([productBatch, productBatch2]);
    });
    test('get batches ordered by expiry date', () async {
      List<ProductBatch> batches =
          await productBatchRepository.orderedByExpiryDateList();
      expect(batches.length, 2);
      expect(batches[0].productName, 'Coca Cola');
    });
    tearDown(() async {
      var warnings = await db.batchWarningDao.all() ?? [];
      var productbatches = await db.productBatchDao.all() ?? [];

      if (warnings.length > 0) {
        for (var warning in warnings) {
          await db.batchWarningDao.delete(warning.id);
        }
      }
      if (productbatches.length > 0) {
        for (var productBatch in productbatches) {
          await db.productBatchDao.delete(productBatch.id);
        }
      }
    });
  });

  group('syncProductBatchesData tests', () {
    test('initial db is empty', () async {
      when(productBatchApiClient.getAllProductBatchesFromServer())
          .thenAnswer((_) => Future.value([productBatch, productBatch2]));
      String message = await productBatchRepository.syncProductBatchesData();
      expect(message, 'Успешно ги синхронизиравте вашите податоци.');
    });
    test('there are entries in the db', () async {
      await db.productBatchDao.add(productBatch);
      String message = await productBatchRepository.syncProductBatchesData();
      expect(message, 'Вашите податоци се веќе синхронизирани.');
    });
    tearDown(() async {
      var warnings = await db.batchWarningDao.all() ?? [];
      var productbatches = await db.productBatchDao.all() ?? [];

      if (warnings.length > 0) {
        for (var warning in warnings) {
          await db.batchWarningDao.delete(warning.id);
        }
      }
      if (productbatches.length > 0) {
        for (var productBatch in productbatches) {
          await db.productBatchDao.delete(productBatch.id);
        }
      }
    });
  });

  group('closeProductBatch test', () {
    test(
        'set warning to checked and set quantity to zero of product Batch and warning',
        () async {
      int pbId = await db.productBatchDao.add(productBatch2);
      int bwId = await db.batchWarningDao.add(batchWarning);

      ProductBatch newProductBatch = await db.productBatchDao.get(pbId);
      BatchWarning newBatchWarning = await db.batchWarningDao.get(bwId);
      String message =
          await productBatchRepository.closeProductBatch(newBatchWarning);
      ProductBatch editedProductBatch = await db.productBatchDao.get(pbId);
      BatchWarning editedBatchWarning = await db.batchWarningDao.get(bwId);

      expect(editedBatchWarning.status, 'CHECKED');
      expect(editedBatchWarning.newQuantity, 0);
      expect(editedBatchWarning.oldQuantity, newBatchWarning.oldQuantity);

      expect(editedProductBatch.quantity, 0);
      expect(message,
          'Успешно ја елиминиравте пратката од базата на податоци. Ве молиме синхронизирајте со серверот!');
    });
  });

  group('uploadNewProductBatches tests', () {
    int pbId;
    ProductBatch savedProductBatch;
    ProductBatch editedProductBatch;
    setUp(() async {
      pbId = await db.productBatchDao.add(productBatch);
      savedProductBatch = await db.productBatchDao.get(pbId);
      editedProductBatch = savedProductBatch.copyWith(synced: true);
    });
    test('successfully upload new product batches', () async {
      when(productBatchApiClient
              .updatedBatchesAfterPostCall([savedProductBatch]))
          .thenAnswer((_) => Future.value([editedProductBatch]));

      String message = await productBatchRepository
          .uploadNewProductBatches([savedProductBatch]);

      ProductBatch afterUpload = await db.productBatchDao.get(pbId);
      expect(afterUpload.synced, true);
      expect(message, 'Успешна синхронизација на податоците.');
    });
    test('product batch api gave error', () async {
      when(productBatchApiClient
          .updatedBatchesAfterPostCall([savedProductBatch])).thenThrow('oops');
      try {
        String message = await productBatchRepository
            .uploadNewProductBatches([savedProductBatch]);
      } catch (e) {
        expect(e.toString(),
            'Exception: Something went wrong when tried to update product batches');
      }
    });
  });
  group('uploadEditedProductBatches test', () {
    var jsonResponse;
    ProductBatch editedProductBatch;
    ProductBatch savedProductBatch;
    int pbId;
    setUp(() async {
      jsonResponse = '{"success" : true}';
      pbId = await db.productBatchDao.add(productBatch);
      savedProductBatch = await db.productBatchDao.get(pbId);
      editedProductBatch = productBatch.copyWith(synced: false, quantity: 15);
    });

    test('successfully upload edited', () async {
      when(productBatchApiClient
              .putCallResponseBodyOfBatch([savedProductBatch]))
          .thenAnswer((_) => Future.value(json.decode(jsonResponse)));
      await productBatchRepository
          .uploadEditedProductBatches([savedProductBatch]);
      ProductBatch afterUpload = await db.productBatchDao.get(pbId);
      expect(afterUpload.synced, true);
    });
    test('product batch client throws error', () async {
      when(productBatchApiClient
              .putCallResponseBodyOfBatch([savedProductBatch]))
          .thenThrow('Error uploading edited batches.');
      try {
        await productBatchRepository
            .uploadEditedProductBatches([savedProductBatch]);
      } catch (e) {
        expect(e.toString(), 'Error uploading edited batches.');
      }
    });
    tearDown(() async {
      var warnings = await db.batchWarningDao.all() ?? [];
      var productbatches = await db.productBatchDao.all() ?? [];

      if (warnings.length > 0) {
        for (var warning in warnings) {
          await db.batchWarningDao.delete(warning.id);
        }
      }
      if (productbatches.length > 0) {
        for (var productBatch in productbatches) {
          await db.productBatchDao.delete(productBatch.id);
        }
      }
    });
  });

  group('saveProductBatchesLocally', () {
    test('success saving product batches in the db', () async {
      await productBatchRepository
          .saveProductBatchesLocally([productBatch, productBatch2]);
      List<ProductBatch> batches = await db.productBatchDao.all();
      expect(batches.length, 2);
    });
    test('exception when saving invalid data', () async {
      await productBatchRepository.saveProductBatchesLocally([productBatch]);
      ProductBatch savedPb = await db.productBatchDao.get(1);
      try {
        await productBatchRepository.saveProductBatchesLocally([savedPb]);
        fail('Should throw');
      } catch (e) {
        expect(e.toString(),
            "Exception: Error when saving product batches to the database.");
      }
    });
  });
  group('updateProductBatchesLocally tests', () {
    int pbId;
    ProductBatch savedProductBatch;
    setUp(() async {
      pbId = await db.productBatchDao.add(productBatch);
      savedProductBatch = await db.productBatchDao.get(pbId);
    });

    test('successfully update product batch in the database', () async {
      ProductBatch newProductBatch =
          savedProductBatch.copyWith(quantity: 20, synced: false);
      await productBatchRepository
          .updateProductBatchesLocally([newProductBatch]);
      ProductBatch afterUpdate = await db.productBatchDao.get(pbId);
      expect(afterUpdate.quantity, 20);
      expect(afterUpdate.synced, false);
    });

    test('throws error for invalid data', () async {
      ProductBatch newPbInvalidId = savedProductBatch.copyWith(id: 15015);
      try {
        await productBatchRepository
            .updateProductBatchesLocally([newPbInvalidId]);
      } catch (e) {
        expect(
          e.toString(),
          'Exception: Something went wrong when tried to update product batches in the database.',
        );
      }
    });
  });

  group('updateProductBatch tests', () {
    int pbId;
    ProductBatch savedProductBatch;
    int bwId;
    setUp(() async {
      pbId = await db.productBatchDao.add(productBatch2);
      bwId = await db.batchWarningDao.add(batchWarning);
      savedProductBatch = await db.productBatchDao.get(pbId);
    });

    test('successfully update single product batch', () async {
      ProductBatch editedProduct = savedProductBatch.copyWith(quantity: 10);
      await productBatchRepository.updateProductBatch(editedProduct);
      ProductBatch afterUpdate = await db.productBatchDao.get(pbId);
      BatchWarning bwAfterUpdate = await db.batchWarningDao.get(bwId);
      expect(bwAfterUpdate.newQuantity, 10);
      expect(bwAfterUpdate.status, 'CHECKED');
      expect(afterUpdate.quantity, 10);
    });

    test('invalid data update on single product batch', () async {
      ProductBatch editedProduct =
          savedProductBatch.copyWith(id: 111230, quantity: 1);
      await productBatchRepository.updateProductBatch(editedProduct);
      BatchWarning bwAfterUpdate = await db.batchWarningDao.get(bwId);

      productBatch = await db.productBatchDao.get(pbId);
      expect(productBatch.id, isNot(equals(111230)));
      expect(productBatch.quantity, isNot(equals(1)));
      expect(bwAfterUpdate.newQuantity, 40);
    });
  });
  tearDown(() async {
    await db.close();
  });
}
