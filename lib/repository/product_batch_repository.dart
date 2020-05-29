import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';

class ProductBatchRepository {
  final ProductBatchApiClient productBatchApiClient;
  final AppDatabase db;

  ProductBatchRepository({this.productBatchApiClient, this.db});

  Future<ProductBatch> getProductBatch(int productBatchId) async {
    ProductBatch productBatch =
        await this.db.productBatchDao.get(productBatchId);
    return productBatch;
  }

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
    productBatchList.sort((a, b) =>
        b.returnDateTimeUpdated().compareTo(a.returnDateTimeUpdated()));
    return productBatchList;
  }

  Future<List<ProductBatch>> getFilteredProductBatches(
      ProductBatch productBatch) async {
    try {
      List<ProductBatch> productBatches =
          await this.db.productBatchDao.getByBarCode(productBatch.barCode);
      return productBatches;
    } catch (e) {
      throw Exception("Error fetching items from the db, error: $e");
    }
  }

  Future<List<ProductBatch>> orderedByExpiryDateList() async {
    List<ProductBatch> productBatchList = await allProductBatchList();

    productBatchList.sort((a, b) =>
        a.returnDateTimeExpDate().compareTo(b.returnDateTimeExpDate()));

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
      this.saveProductBatchesLocally(productBatches);
      return "Успешно ги синхронизиравте вашите податоци.";
    }
    return "Вашите податоци се веќе синхронизирани.";
  }

  Future<String> closeProductBatch(BatchWarning warning) async {
    try {
      // delete product warning
      await this.db.batchWarningDao.delete(warning.id);
      ProductBatch productBatch =
          await this.db.productBatchDao.getByServerId(warning.productBatchId);
      productBatch.quantity = 0;
      productBatch.synced = false;
      productBatch.updated = DateTime.now().toString();
      await this.db.productBatchDao.updateProductBatch(productBatch);
      String message;
      // try to update online
      try {
        // await this.productBatchApiClient.updateProductBatch(productBatch);
        // await this.db.productBatchDao.delete(warning.productBatchId);
        message = "Успешно ја избришавте пратката на серверот!";
      } catch (e) {
        message =
            "Успешно ја избришавте пратката од базата на податоци. Ве молиме синхронизирајте со серверот.";
      }
      return message;
    } catch (e) {
      throw Exception("Error while deleting batch locally.");
    }
  }

  Future<String> uploadNewProductBatches() async {
    try {
      List<ProductBatch> localBatches =
          await this.db.productBatchDao.getNewProductBatches();
      if (localBatches.length > 0) {
        List<ProductBatch> serverResponseBatches =
            await this.productBatchApiClient.uploadLocalBatches(localBatches);
        await this.updateProductBatchesLocally(serverResponseBatches);
        return "Успешна синхронизација на податоците.";
      } else {
        return 'Локалните податоци се синхронизирани.';
      }
    } catch (e) {
      throw Exception(
          "Something went wrong when tried to update product batches");
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
}
