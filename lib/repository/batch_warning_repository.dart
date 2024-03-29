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

      String dtString = DateTime.now().toString();
      productBatch.updateQuantity(
        quantity: quantity,
        dtString: dtString,
      );
      batchWarning.updateQuantity(
        quantity: quantity,
        dtString: dtString,
      );
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
        await this.db.productBatchDao.updateAsSynced(
            warnings.map<int>((warning) => warning.productBatchId).toList());
        await this.db.batchWarningDao.deleteWarnings(
            warnings.map<int>((warning) => warning.id).toList());
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
    batchWarning = await this.db.batchWarningDao.getLast();
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
