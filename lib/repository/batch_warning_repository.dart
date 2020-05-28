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
    try {
      ProductBatch productBatch = await this
          .db
          .productBatchDao
          .getByServerId(batchWarning.productBatchId);
      productBatch.quantity = quantity;
      productBatch.updated = DateTime.now().toString();
      productBatch.synced = false;
      await this.db.productBatchDao.updateProductBatch(productBatch);
      await this.deleteCheckedWarning(batchWarning);

      // check if we can update batch warning online
      // String message =
      //     await this.syncUpdatedQuantityOnline(quantity, productBatch);
      // if (message != null) {
      //   return message;
      // }
      return 'Успешно ја зачувавте промената на количина локално.';
    } catch (e) {
      throw Exception("Something went wrong while saving in the database.");
    }
  }

  Future<String> syncUpdatedQuantityOnline(
      int quantity, ProductBatch productBatch) async {
    try {
      bool saved = await batchWarningApi.updateQuantity(quantity, productBatch);
      if (saved == true) {
        productBatch.synced = true;
        await this.db.productBatchDao.updateProductBatch(productBatch);
        return 'Успешно ја зачувавте количината на серверот.';
      }
      return null;
    } catch (e) {
      throw Exception("Failed to update quantity online");
    }
  }

  Future<void> deleteCheckedWarning(BatchWarning batchWarning) async {
    try {
      await this.db.batchWarningDao.delete(batchWarning.id);
    } catch (e) {
      throw Exception("Error while deleting batch warning, error: $e");
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
      await this.db.batchWarningDao.saveWarnings(warnings);
      return 'Успешно ги синхронизиравте податоците.';
    }
    return 'Нема нови податоци.';
  }
}
