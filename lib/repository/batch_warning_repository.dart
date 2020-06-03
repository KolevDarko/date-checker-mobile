import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/date_time_formatter.dart';

class BatchWarningRepository {
  final BatchWarningApiClient batchWarningApi;
  final AppDatabase db;

  BatchWarningRepository({this.db, this.batchWarningApi});

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
      productBatch.quantity = quantity;
      productBatch.updated = DateTime.now().toString();
      productBatch.synced = false;
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
      var responseBody = await batchWarningApi.updateWarnings(warnings);
      if (responseBody['success']) {
        for (BatchWarning warning in warnings) {
          ProductBatch batch =
              await this.db.productBatchDao.get(warning.productBatchId);
          batch.synced = true;
          await this.db.productBatchDao.updateProductBatch(batch);
          await this.db.batchWarningDao.delete(warning.id);
        }
      }
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
