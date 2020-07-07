import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/date_time_formatter.dart';

enum ProductBatchFilter { barCode, productName, quantity, updated, expiryDate }

class ProductBatchRepository {
  final ProductBatchApiClient productBatchApiClient;
  final AppDatabase db;

  ProductBatchRepository({this.productBatchApiClient, this.db})
      : assert(productBatchApiClient != null),
        assert(db != null);

  Future<int> addProductBatch(ProductBatch productBatch) async {
    try {
      int productBatchId = await this.db.productBatchDao.add(productBatch);
      return productBatchId;
    } catch (e) {
      throw Exception("Error saving product batch to database.");
    }
  }

  Future<List<ProductBatch>> allProductBatchList() async {
    List<ProductBatch> productBatchList = await this.db.productBatchDao.all();
    productBatchList.sort((a, b) => DateTimeFormatter.dateTimeParser(b.updated)
        .compareTo(DateTimeFormatter.dateTimeParser(a.updated)));
    return productBatchList;
  }

  Future<List<ProductBatch>> getFilteredProductBatches(
    String inputValue,
  ) async {
    try {
      List<ProductBatch> productBatches =
          await this.db.productBatchDao.searchQuery(inputValue);

      return productBatches;
    } catch (e) {
      throw Exception("Error fetching items from the db, error: $e");
    }
  }

  Future<List<ProductBatch>> applyFilter(
      List<ProductBatch> batches, ProductBatchFilter filter) async {
    if (filter == ProductBatchFilter.barCode) {
      batches.sort((a, b) => a.barCode.compareTo(b.barCode));
    } else if (filter == ProductBatchFilter.quantity) {
      batches.sort((a, b) => a.quantity.compareTo(b.quantity));
    } else if (filter == ProductBatchFilter.productName) {
      batches.sort((a, b) => a.productName.compareTo(b.productName));
    } else if (filter == ProductBatchFilter.expiryDate) {
      batches.sort((a, b) => DateTimeFormatter.dateTimeParser(a.expirationDate)
          .compareTo(DateTimeFormatter.dateTimeParser(b.expirationDate)));
    } else if (filter == ProductBatchFilter.updated) {
      batches.sort((a, b) => DateTimeFormatter.dateTimeParser(b.updated)
          .compareTo(DateTimeFormatter.dateTimeParser(a.updated)));
    }

    return batches;
  }

  Future<String> syncProductBatchesData() async {
    List<ProductBatch> productBatches = [];
    ProductBatch productBatch;
    try {
      productBatch = await this.db.productBatchDao.getLast();
    } catch (e) {
      productBatch = null;
    }
    if (productBatch == null) {
      productBatches =
          await this.productBatchApiClient.getAllProductBatchesFromServer();
      await this.saveProductBatchesLocally(productBatches);
      return "Успешно ги синхронизиравте вашите податоци.";
    }
    return "Вашите податоци се веќе синхронизирани.";
  }

  Future<String> closeProductBatch(BatchWarning warning) async {
    try {
      warning.newQuantity = 0;
      warning.updated = DateTime.now().toString();
      warning.status = BatchWarning.batchWarningStatus()[1];
      await this.db.batchWarningDao.updateBatchWarning(warning);
      ProductBatch productBatch =
          await this.db.productBatchDao.getByServerId(warning.productBatchId);
      productBatch.quantity = 0;
      productBatch.synced = false;
      productBatch.updated = DateTime.now().toString();
      await this.db.productBatchDao.updateProductBatch(productBatch);
      return "Успешно ја елиминиравте пратката од базата на податоци. Ве молиме синхронизирајте со серверот!";
    } catch (e) {
      print(e);
      throw Exception("Error while deleting batch locally.");
    }
  }

  Future<String> uploadNewProductBatches(List<ProductBatch> newBatches) async {
    try {
      List<ProductBatch> updatedBatches = await this
          .productBatchApiClient
          .updatedBatchesAfterPostCall(newBatches);
      await this.updateProductBatchesLocally(updatedBatches);

      return "Успешна синхронизација на податоците.";
    } catch (e) {
      throw Exception(
          "Something went wrong when tried to update product batches");
    }
  }

  Future<void> uploadEditedProductBatches(
    List<ProductBatch> editedBatches,
  ) async {
    List<ProductBatch> synced = List.of(editedBatches);
    dynamic responseBody = await this
        .productBatchApiClient
        .putCallResponseBodyOfBatch(editedBatches);
    if (responseBody['success']) {
      for (ProductBatch batch in synced) {
        batch.synced = true;
      }
      await this.updateProductBatchesLocally(synced);
    }
  }

  Future<void> saveProductBatchesLocally(
    List<ProductBatch> productBatches,
  ) async {
    try {
      await this.db.productBatchDao.saveProductBatches(productBatches);
    } catch (e) {
      throw Exception("Error when saving product batches to the database.");
    }
  }

  Future<void> updateProductBatchesLocally(
      List<ProductBatch> productBatches) async {
    try {
      int _ = await this.db.productBatchDao.updateBatches(productBatches);
    } catch (e) {
      throw Exception(
          "Something went wrong when tried to update product batches in the database.");
    }
  }

  Future<void> updateProductBatch(ProductBatch productBatch) async {
    try {
      ProductBatch pb = await this.db.productBatchDao.get(productBatch.id);
      if (pb != null) {
        await this.db.productBatchDao.updateProductBatch(productBatch);

        BatchWarning batchWarning = await this
            .db
            .batchWarningDao
            .getByProductBatchId(productBatch.serverId);
        if (batchWarning != null) {
          batchWarning.newQuantity = productBatch.quantity;
          batchWarning.status = BatchWarning.batchWarningStatus()[1];
          batchWarning.updated = DateTime.now().toString();
          await db.batchWarningDao.updateBatchWarning(batchWarning);
        }
      }
    } catch (e) {
      throw Exception(
          "Error when updating single product batch in the database.");
    }
  }
}
