// import 'package:date_checker_app/database/database.dart';
// import 'package:date_checker_app/database/models.dart';
// // import 'package:flutter_test/flutter_test.dart';

// Future<AppDatabase> setDb() async {
//   final database =
//       await $FloorAppDatabase.databaseBuilder('test_db.db').build();
//   return database;
// }

// fillDb(AppDatabase db) async {
//   Product product = Product(null, 'name', 30.0, 'barCode');
//   int productId = await db.productDao.add(product);

//   ProductBatch productBatch =
//       ProductBatch(null, 'barcode', productId, 31, "6th Feb");
//   int productBatchId = await db.productBatchDao.add(productBatch);
// }

// void main() async {
//   // TestWidgetsFlutterBinding.ensureInitialized();
//   final AppDatabase db = await setDb();
//   await fillDb(db);
//   var products = await db.productDao.all();
//   var productBatch = await db.productBatchDao.all();

//   print(products);
//   print(productBatch);
// }
