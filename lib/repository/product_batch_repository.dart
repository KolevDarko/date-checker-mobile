import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/date_time_formatter.dart';

class ProductBatchRepository {
  final ProductBatchApiClient productBatchApiClient;
  final AppDatabase db;

  ProductBatchRepository({this.productBatchApiClient, this.db});

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

  Future<List<ProductBatch>> orderedByExpiryDateList() async {
    List<ProductBatch> productBatchList = await allProductBatchList();
    productBatchList.sort((a, b) =>
        DateTimeFormatter.dateTimeParser(a.expirationDate)
            .compareTo(DateTimeFormatter.dateTimeParser(b.expirationDate)));

    return productBatchList;
  }

  Future<String> syncProductBatchesData() async {
    List<ProductBatch> productBatches = [];
    try {
      productBatches = await this.productBatchApiClient.getAllProductBatches();
    } catch (e) {
      throw Exception("Failed to get product batches");
    }
    ProductBatch productBatch;
    try {
      productBatch = await this.db.productBatchDao.getLast();
    } catch (e) {
      productBatch = null;
    }
    if (productBatch == null) {
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
      throw Exception("Error while deleting batch locally.");
    }
  }

  Future<String> uploadNewProductBatches(List<ProductBatch> newBatches) async {
    try {
      // TODO ne gi snima kako so treba
      List<ProductBatch> serverResponseBatches =
          await this.productBatchApiClient.uploadLocalBatches(newBatches);
      await this.updateProductBatchesLocally(serverResponseBatches);
      return "Успешна синхронизација на податоците.";
    } catch (e) {
      throw Exception(
          "Something went wrong when tried to update product batches");
    }
  }

  Future<void> uploadEditedProductBatches(
      List<ProductBatch> editedBatches) async {
    List<ProductBatch> synced = editedBatches;
    var responseBody =
        await this.productBatchApiClient.callEditBatch(editedBatches);
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
      throw Exception("here error when saving product batches to the databse.");
    }
  }

  Future<void> updateProductBatchesLocally(
      List<ProductBatch> productBatches) async {
    try {
      int updatedItems =
          await this.db.productBatchDao.updateBatches(productBatches);
    } catch (e) {
      throw Exception(
          "Something went wrong when tried to update product batches in the database.");
    }
  }

  Future<void> updateProductBatch(ProductBatch productBatch) async {
    await this.db.productBatchDao.updateProductBatch(productBatch);
  }
}
