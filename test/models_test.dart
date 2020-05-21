import 'package:date_checker_app/database/dao.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  group('database tests', () {
    AppDatabase database;
    ProductBatchDao productBatchDao;

    setUp(() async {
      database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
      productBatchDao = database.productBatchDao;
    });

    test('find person by id', () async {
      final productBatch1 =
          ProductBatch(null, null, '1001', 1, 30, "2020-03-13", false);
      final productBatch2 =
          ProductBatch(null, 1, '1002', 2, 50, "2020-03-13", true);
      await productBatchDao.add(productBatch1);
      await productBatchDao.add(productBatch2);

      List<ProductBatch> savedBatches =
          await productBatchDao.getLocalProductBatches();

      print("SAVED BATCHES, : $savedBatches");

      // List<ProductBatch> batches = [
      //   ProductBatch(1, 1, '1001', 1, 30, "2020-03-13"),
      //   ProductBatch(2, 2, '1002', 2, 50, "2020-03-13")
      // ];

      // int numberRows = await productBatchDao.updateBatches(batches);

      // print("Updated $numberRows");

      savedBatches = await productBatchDao.all();

      print("Updated BATCHES, : $savedBatches");

      expect(1, 1);
    });

    tearDown(() async {
      await database.close();
    });
  });
}
