import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';

class BatchWarningRepository {

  Future<List<BatchWarning>> warnings() async {
    AppDatabase db = await DbProvider.instance.database;
    return db.batchWarningDao.allStatusChecked('NEW');
  }

  Future<void> updateQuantity(int quantity, BatchWarning batchWarning) async {
    AppDatabase db = await DbProvider.instance.database;
    batchWarning.newQuantity = quantity;
    batchWarning.status = 'CHECKED';
    ProductBatch productBatch =
        await db.productBatchDao.get(batchWarning.productBatchId);
    productBatch.quantity = quantity;
    await db.productBatchDao.updateProductBatch(productBatch);
    await db.batchWarningDao.updateBatchWarning(batchWarning);
  }

}
