import 'package:date_checker_app/database/models.dart';
import 'package:floor/floor.dart';

@dao
abstract class ProductDao {
  @Query('SELECT * FROM Product')
  Future<List<Product>> all();

  @Query('SELECT * from Product order by id desc limit 1')
  Future<Product> getLast();

  @Query('SELECT * FROM Product WHERE serverId = :serverId')
  Future<Product> getByServerId(int serverId);

  @Query('SELECT * FROM Product WHERE name = :name')
  Future<Product> fetchByName(String name);

  @Query('SELECT * FROM Product WHERE id = :id')
  Future<Product> get(int id);

  @Query('SELECT * FROM Product ORDER BY serverId DESC LIMIT 1')
  Future<Product> getProductWithLastServerId();

  @Query('SELECT * FROM Product WHERE instr(name, :inputString) > 0')
  Future<List<Product>> getProductsBySearchTerm(String inputString);

  Future<int> getLastServerId() async {
    Product lastProduct = await this.getProductWithLastServerId();
    return lastProduct.serverId;
  }

  @Query('DELETE FROM Product WHERE id = :id')
  Future<void> delete(int id);

  @insert
  Future<int> add(Product product);

  @insert
  Future<void> insertAllProducts(List<Product> products);

  @transaction
  Future<void> saveProducts(List<Product> products) async {
    await insertAllProducts(products);
  }
}

@dao
abstract class ProductBatchDao {
  @Query('SELECT * FROM ProductBatch')
  Future<List<ProductBatch>> all();

  @Query('SELECT * from ProductBatch order by id desc limit 1')
  Future<ProductBatch> getLast();

  @Query('SELECT * FROM ProductBatch WHERE serverId IS NULL')
  Future<List<ProductBatch>> getNewProductBatches();

  @Query('SELECT * FROM ProductBatch WHERE NOT sync AND serverId NOT NULL')
  Future<List<ProductBatch>> getUnsyncedProductBatches();

  @Query('SELECT * FROM ProductBatch WHERE name = :name')
  Future<ProductBatch> fetchByName(String name);

  @Query('SELECT * FROM ProductBatch WHERE barCode = :barCode')
  Future<List<ProductBatch>> getByBarCode(String barCode);

  @Query(
      "SELECT * FROM ProductBatch WHERE INSTR(productName, :inputString) > 0")
  Future<List<ProductBatch>> searchQuery(String inputString);

  @Query('SELECT * FROM ProductBatch WHERE id = :id')
  Future<ProductBatch> get(int id);

  @Query('SELECT * FROM ProductBatch WHERE serverId = :id')
  Future<ProductBatch> getByServerId(int id);

  @Query('DELETE FROM ProductBatch WHERE id = :id')
  Future<void> delete(int id);

  @update
  Future<void> updateProductBatch(ProductBatch productBatch);

  @update
  Future<int> updateBatches(List<ProductBatch> productBatches);

  @insert
  Future<int> add(ProductBatch productBatch);

  @insert
  Future<void> insertAllProductBatches(List<ProductBatch> productBatches);

  @transaction
  Future<void> saveProductBatches(List<ProductBatch> productBatches) async {
    await insertAllProductBatches(productBatches);
  }
}

@dao
abstract class BatchWarningDao {
  @Query('SELECT * FROM BatchWarning')
  Future<List<BatchWarning>> all();

  @Query('SELECT * FROM BatchWarning WHERE status = :status')
  Future<List<BatchWarning>> allStatusChecked(String status);

  @Query('SELECT * FROM BatchWarning WHERE name = :name')
  Future<BatchWarning> fetchByName(String name);

  @Query('SELECT * FROM BatchWarning WHERE id = :id')
  Future<BatchWarning> get(int id);

  @Query('DELETE FROM BatchWarning WHERE id = :id')
  Future<void> delete(int id);

  @Query('SELECT * from BatchWarning order by id desc limit 1')
  Future<BatchWarning> getLast();

  @insert
  Future<int> add(BatchWarning batchWarning);

  @update
  Future<void> updateBatchWarning(BatchWarning batchWarning);

  @insert
  Future<void> insertAllWarnings(List<BatchWarning> warnings);

  @transaction
  Future<void> saveWarnings(List<BatchWarning> warnings) async {
    await insertAllWarnings(warnings);
  }
}
