import 'dart:convert';

import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/batch_warning_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  BatchWarningApiClient batchWarningApiClient;
  BatchWarningRepository batchWarningRepository;
  BatchWarning bw1;
  BatchWarning bw2;
  AppDatabase db;
  ProductBatch productBatch;
  setUp(() async {
    db = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    batchWarningApiClient = MockBatchWarningApiClient();
    batchWarningRepository = BatchWarningRepository(
      batchWarningApi: batchWarningApiClient,
      db: db,
    );
    bw1 = BatchWarning(null, 'Coca Cola', 30, '2020-05-11', 1, 'NEW', 'WARNING',
        30, 30, DateTime.now().toString(), DateTime.now().toString());
    bw2 = BatchWarning(null, 'Schweppes', 10, '2020-02-21', 2, 'NEW', 'WARNING',
        50, 50, DateTime.now().toString(), DateTime.now().toString());
    productBatch = ProductBatch(null, 1, '1001', 1, 30, "2020-03-11", false,
        DateTime.now().toString(), DateTime.now().toString(), 'Schweppes');
  });

  test('throws AssertionError when batchWarningApi is null', () {
    expect(
      () => BatchWarningRepository(batchWarningApi: null, db: db),
      throwsAssertionError,
    );
  });
  test('throws AssertionError when db is null', () {
    expect(
      () => BatchWarningRepository(
          batchWarningApi: batchWarningApiClient, db: null),
      throwsAssertionError,
    );
  });

  group('warnings tests', () {
    setUp(() async {
      bw1.updated = '2020-06-06 14:31:29';
      bw2.updated = '2020-06-06 14:35:29';

      await db.batchWarningDao.add(bw1);
      await db.batchWarningDao.add(bw2);
    });
    test('fetch all warnings ordered by recently updated', () async {
      List<BatchWarning> warnings = await batchWarningRepository.warnings();
      expect(warnings[0].productName, 'Schweppes');
      expect(warnings.length, 2);
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

  group('updateQuantity tests', () {
    int bwId;
    int pbId;
    setUp(() async {
      bwId = await db.batchWarningDao.add(bw1);
      pbId = await db.productBatchDao.add(productBatch);
    });

    test('successfull update on batch warning', () async {
      BatchWarning bw = await db.batchWarningDao.get(bwId);
      ProductBatch pb = await db.productBatchDao.get(pbId);
      await batchWarningRepository.updateQuantity(10, bw);
      bw = await db.batchWarningDao.get(bwId);
      pb = await db.productBatchDao.get(pbId);
      expect(bw.newQuantity, 10);
      expect(bw.oldQuantity, 30);
      expect(bw.status, 'CHECKED');
      expect(pb.quantity, 10);
      expect(pb.synced, false);
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

  group('uploadEditedWarnings tests', () {
    int bwId;
    int pbId;
    BatchWarning savedWarning;
    ProductBatch newProductBatch;
    setUp(() async {
      bwId = await db.batchWarningDao.add(bw1);
      pbId = await db.productBatchDao.add(productBatch);
      savedWarning = await db.batchWarningDao.get(bwId);
      newProductBatch = await db.productBatchDao.get(pbId);
    });

    test('success uploading edited warnings', () async {
      when(batchWarningApiClient.updateWarnings([savedWarning]))
          .thenAnswer((_) => Future.value(json.decode('{"success": true}')));
      await batchWarningRepository.uploadEditedWarnings([savedWarning]);
      newProductBatch = await db.productBatchDao.get(pbId);
      expect(newProductBatch.synced, true);
      try {
        savedWarning = await db.batchWarningDao.get(bwId);
        expect(savedWarning, null);
      } catch (e) {}
    });
    test('error on batch warning api client call', () async {
      BatchWarning savedWarning = await db.batchWarningDao.get(bwId);

      when(batchWarningApiClient.updateWarnings([savedWarning]))
          .thenThrow('oops');
      try {
        await batchWarningRepository.uploadEditedWarnings([savedWarning]);
      } catch (e) {
        expect(e.toString(), 'Exception: Failed to update quantity online');
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

  group('deleteCheckedWarning test', () {
    int bwId;
    BatchWarning batchWarning;
    setUp(() async {
      bwId = await db.batchWarningDao.add(bw1);
      batchWarning = await db.batchWarningDao.get(bwId);
    });

    test('success delete batch warning', () async {
      await batchWarningRepository.deleteCheckedWarning(batchWarning);
      batchWarning = await db.batchWarningDao.get(bwId);
      expect(batchWarning, null);
    });

    test('doesn\'t do anything on invalid batch warning id', () async {
      batchWarning.id = 125151;
      await batchWarningRepository.deleteCheckedWarning(batchWarning);
      final productBatch = await db.batchWarningDao.all();
      expect(productBatch.length, 1);
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

  group('syncWarnings tests', () {
    test('sync warnings on empty db', () async {
      when(batchWarningApiClient.getAllBatchWarnings())
          .thenAnswer((_) => Future.value([bw1]));
      final message = await batchWarningRepository.syncWarnings();
      final warnings = await db.batchWarningDao.all();
      expect(warnings.length, 1);
      expect(message, 'Успешно ги синхронизиравте податоците.');
    });

    test('sync warning with some data in db already', () async {
      int bwId = await db.batchWarningDao.add(bw1);
      when(batchWarningApiClient.refreshWarnings(bwId))
          .thenAnswer((_) => Future.value([bw2]));

      final message = await batchWarningRepository.syncWarnings();

      final warnings = await db.batchWarningDao.all();
      expect(warnings.length, 2);
      expect(warnings[0].productName, bw1.productName);
      expect(message, 'Успешно ги синхронизиравте податоците.');
    });
    test('no more data on the server', () async {
      int bwId1 = await db.batchWarningDao.add(bw1);
      int bwId2 = await db.batchWarningDao.add(bw2);

      when(batchWarningApiClient.refreshWarnings(bwId2))
          .thenAnswer((_) => Future.value([]));
      final message = await batchWarningRepository.syncWarnings();

      expect(message, 'Нема нови податоци.');
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
  tearDown(() async {
    await db.close();
  });
}
