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
    int productBatchId = await this.db.productBatchDao.add(productBatch);
    return productBatchId;
  }

  Future<List<ProductBatch>> allProductBatchList() async {
    List<ProductBatch> productBatchList = await this.db.productBatchDao.all();
    return productBatchList;
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
      print("something went wrong with product batches api GET call");
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

  Future<String> uploadNewProductBatches() async {
    List<ProductBatch> localBatches =
        await this.db.productBatchDao.getLocalProductBatches();
    if (localBatches.length > 0) {
      List<ProductBatch> serverResponseBatches =
          await this.productBatchApiClient.uploadLocalBatches(localBatches);
      await this.updateProductBatchesLocally(serverResponseBatches);
      return "Успешна синхронизација на податоците.";
    } else {
      return 'Локалните податоци се синхронизирани.';
    }
  }

  Future<void> saveProductBatchesLocally(
    List<ProductBatch> productBatches,
  ) async {
    try {
      await this.db.productBatchDao.saveProductBatches(productBatches);
    } catch (e) {
      print("here error when saving product batches locally");
      print(e);
    }
  }

  Future<void> updateProductBatchesLocally(
      List<ProductBatch> productBatches) async {
    try {
      int updatedItems =
          await this.db.productBatchDao.updateBatches(productBatches);
    } catch (e) {
      throw Exception(
          "Something went wrong when tried to update product batches.");
    }
  }
}
