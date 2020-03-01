import 'package:date_checker_app/database/models.dart';
import 'package:floor/floor.dart';

@dao
abstract class ProductDao {
  @Query('SELECT * FROM Product')
  Future<List<Product>> all();

  @Query('SELECT * FROM Product WHERE name = :name')
  Future<Product> fetchByName(String name);

  @Query('SELECT * FROM Product WHERE id = :id')
  Future<Product> get(int id);

  @Query('DELETE FROM Product WHERE id = :id')
  Future<void> delete(int id);

  @insert
  Future<int> add(Product product);
}

@dao
abstract class ProductBatchDao {
  @Query('SELECT * FROM ProductBatch')
  Future<List<ProductBatch>> all();

  @Query('SELECT * FROM ProductBatch WHERE name = :name')
  Future<ProductBatch> fetchByName(String name);

  @Query('SELECT * FROM ProductBatch WHERE id = :id')
  Future<ProductBatch> get(int id);

  @Query('DELETE FROM ProductBatch WHERE id = :id')
  Future<void> delete(int id);

  @update
  Future<void> updateProductBatch(ProductBatch productBatch);

  @insert
  Future<int> add(ProductBatch productBatch);
}

@dao
abstract class BatchWarningDao {
  @Query('SELECT * FROM BatchWarning')
  Future<List<BatchWarning>> all();

  @Query('SELECT * FROM BatchWarning WHERE name = :name')
  Future<BatchWarning> fetchByName(String name);

  @Query('SELECT * FROM BatchWarning WHERE id = :id')
  Future<BatchWarning> get(int id);

  @Query('DELETE FROM BatchWarning WHERE id = :id')
  Future<void> delete(int id);

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
