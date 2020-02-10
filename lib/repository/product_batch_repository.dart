import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/main.dart';

class ProductBatchRepository {
  Future<ProductBatch> getProductBatch(int productBatchId) async {
    AppDatabase db = await DbProvider.instance.database;
    ProductBatch productBatch = await db.productBatchDao.get(productBatchId);
    return productBatch;
  }

  Future<int> addProductBatch(ProductBatch productBatch) async {
    print("here 123 $productBatch");
    AppDatabase db = await DbProvider.instance.database;
    int productBatchId = await db.productBatchDao.add(productBatch);
    print("saved id $productBatchId");
    return productBatchId;
  }

  Future<List<ProductBatch>> allProductBatchList() async {
    AppDatabase db = await DbProvider.instance.database;
    List<ProductBatch> productBatchList = await db.productBatchDao.all();
    return productBatchList;
  }
}
