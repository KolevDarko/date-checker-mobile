import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';

class BatchWarningRepository {
  final BatchWarningApiClient batchWarningApi;
  final AppDatabase db;

  BatchWarningRepository({this.db, this.batchWarningApi});

  Future<List<BatchWarning>> warnings() async {
    return this.db.batchWarningDao.allStatusChecked('NEW');
  }

  Future<String> updateQuantity(int quantity, BatchWarning batchWarning) async {
    batchWarning.newQuantity = quantity;
    batchWarning.status = 'CHECKED';
    try {
      ProductBatch productBatch = await this
          .db
          .productBatchDao
          .getByServerId(batchWarning.productBatchId);
      productBatch.quantity = quantity;
      productBatch.synced = false;
      await this.db.productBatchDao.updateProductBatch(productBatch);
      await this.db.batchWarningDao.updateBatchWarning(batchWarning);
      // bool saved = await batchWarningApi.updateQuantity(quantity, productBatch);
      bool saved;
      if (saved == true) {
        productBatch.synced = false;
        await this.db.productBatchDao.updateProductBatch(productBatch);
        return 'Успешно ги снимавте податоците на серверот.';
      }
      return 'Успешно ги снимавте податоците локално. Ве молиме синхронизирајте ги податоците за пратки.';
    } catch (e) {
      throw Exception("Something went wrong while saving on the database.");
    }
  }

  Future<String> syncWarnings() async {
    BatchWarning batchWarning;
    List<BatchWarning> warnings = [];
    try {
      batchWarning = await this.db.batchWarningDao.getLast();
    } catch (e) {
      batchWarning = null;
    }
    if (batchWarning != null) {
      warnings = await this.batchWarningApi.refreshWarnings(batchWarning.id);
    } else {
      warnings = await this.batchWarningApi.getAllBatchWarnings();
    }

    if (warnings.length > 0) {
      this.saveWarningsLocally(warnings);
      return 'Успешно ги синхронизиравте податоците.';
    }
    return 'Нема нови податоци.';
  }

  Future<void> saveWarningsLocally(List<BatchWarning> newWarnings) async {
    try {
      await this.db.batchWarningDao.saveWarnings(newWarnings);
    } catch (e) {
      throw Exception("Error saving Batch Warnings to database.");
    }
  }
}
