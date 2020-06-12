import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/date_time_formatter.dart';

class BatchWarningRepository {
  final BatchWarningApiClient batchWarningApi;
  final AppDatabase db;

  BatchWarningRepository({this.db, this.batchWarningApi})
      : assert(batchWarningApi != null),
        assert(db != null);

  Future<List<BatchWarning>> warnings() async {
    List<BatchWarning> warnings = await this.db.batchWarningDao.all();
    warnings.sort(((a, b) => DateTimeFormatter.dateTimeParser(b.updated)
        .compareTo(DateTimeFormatter.dateTimeParser(a.updated))));
    return warnings;
  }

  Future<String> updateQuantity(int quantity, BatchWarning batchWarning) async {
    try {
      ProductBatch productBatch = await this
          .db
          .productBatchDao
          .getByServerId(batchWarning.productBatchId);
//      update data in model
//      productBatch.updateQuantity(quantity);
      productBatch.quantity = quantity;
      productBatch.updated = DateTime.now().toString();
      productBatch.synced = false;
//      batchWarning.updateQuantity(quantity)
      batchWarning.status = 'CHECKED';
      batchWarning.updated = DateTime.now().toString();
      batchWarning.newQuantity = quantity;

      await this.db.batchWarningDao.updateBatchWarning(batchWarning);
      await this.db.productBatchDao.updateProductBatch(productBatch);
      return 'Успешно ја променивте количина на пратката.';
    } catch (e) {
      throw Exception("Something went wrong while saving in the database.");
    }
  }

  Future<void> uploadEditedWarnings(List<BatchWarning> warnings) async {
    try {
      dynamic responseBody =
          await batchWarningApi.warningsPutCallResponseBody(warnings);
      if (responseBody['success']) {
//        1. with sql update all product batches in one query
//      2. with sql delete all warnings
//      two separate methods
        for (BatchWarning warning in warnings) {
          ProductBatch batch = await this
              .db
              .productBatchDao
              .getByServerId(warning.productBatchId);
          batch.synced = true;
          await this.db.productBatchDao.updateProductBatch(batch);
          await this.db.batchWarningDao.delete(warning.id);
        }
      }
    } catch (e) {
      print(e);
      throw Exception("Failed to update quantity online");
    }
  }

  Future<void> deleteCheckedWarning(BatchWarning batchWarning) async {
    try {
      await this.db.batchWarningDao.delete(batchWarning.id);
    } catch (e) {
      throw Exception("Error while deleting batch warning in the database.");
    }
  }

  Future<int> syncWarnings() async {
    BatchWarning batchWarning;
    List<BatchWarning> warnings = [];
//    try/catch probably not needed, query should return null if row doesn't exist
    try {
      batchWarning = await this.db.batchWarningDao.getLast();
    } catch (e) {
      batchWarning = null;
    }
    if (batchWarning != null) {
      warnings =
          await this.batchWarningApi.getLatestBatchWarnings(batchWarning.id);
    } else {
      warnings = await this.batchWarningApi.getAllBatchWarningsFromServer();
    }
    int warningsLength = warnings.length;
    if (warningsLength > 0) {
      await this.db.batchWarningDao.saveWarnings(warnings);
    }
    return warningsLength;
  }
}
