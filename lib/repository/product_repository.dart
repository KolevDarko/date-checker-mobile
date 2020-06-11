import 'package:date_checker_app/api/products_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';

class ProductRepository {
  final ProductsApiClient productsApiClient;
  final AppDatabase db;

  ProductRepository({this.productsApiClient, this.db})
      : assert(productsApiClient != null),
        assert(db != null);

  Future<List<Product>> getAllProducts() async {
    return this.db.productDao.all();
  }

  Future<int> syncProducts() async {
    int lastProductId;
    List<Product> newProducts = [];
    try {
      lastProductId = await this.db.productDao.getLastServerId();
    } catch (e) {
      lastProductId = null;
    }
    if (lastProductId != null) {
      newProducts = await this.productsApiClient.syncProducts(lastProductId);
    } else {
      newProducts = await this.productsApiClient.getAllProductsFromServer();
    }
    int newProductsLength = newProducts.length;
    if (newProductsLength > 0) {
      await this.saveProductsLocally(newProducts);
    }
    return newProductsLength;
  }

  Future<void> saveProductsLocally(List<Product> newProducts) async {
    try {
      await this.db.productDao.saveProducts(newProducts);
    } catch (e) {
      throw Exception("Error when saving products to the database");
    }
  }
}
