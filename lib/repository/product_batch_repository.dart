import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';

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

  Future<void> syncProductBatchesData() async {
    List<ProductBatch> productBatches =
        await this.productBatchApiClient.getAllProductBatches();

    ProductBatch productBatch;
    try {
      productBatch = await this.db.productBatchDao.getLast();
    } catch (e) {
      productBatch = null;
    }
    if (productBatch != null) {
    } else {
      this.saveProductBatchesLocally(productBatches);
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
}
