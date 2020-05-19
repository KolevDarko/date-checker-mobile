import 'package:date_checker_app/api/products_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';

class ProductRepository {
  final ProductsApiClient productsApiClient;
  final AppDatabase db;

  ProductRepository({this.productsApiClient, this.db});

  Future<List<Product>> getAllProducts() async {
    return this.db.productDao.all();
  }

  Future<List<Product>> getSuggestions(String pattern) async {
    List<Product> products = await getAllProducts();
    List<Product> suggested = [];
    for (Product product in products) {
      if (product.barCode.toLowerCase().contains(pattern.toLowerCase())) {
        suggested.add(product);
      }
    }
    return suggested;
  }

  Future<Product> getProduct(int productId) async {
    Product product = await this.db.productDao.get(productId);
    return product;
  }

  Future<String> syncProducts() async {
    Product lastProduct;
    List<Product> newProducts = [];
    try {
      lastProduct = await this.db.productDao.getLast();
    } catch (e) {
      lastProduct = null;
    }

    if (lastProduct != null) {
      newProducts = await this.productsApiClient.syncProducts(lastProduct.id);
    } else {
      newProducts = await this.productsApiClient.getAllProducts();
    }
    if (newProducts.length > 0) {
      await this.saveProductsLocally(newProducts);
      return 'Успешно ги синхронизиравте продуктите.';
    } else {
      return 'Нема нови продукти.';
    }
  }

  Future<void> saveProductsLocally(List<Product> newProducts) async {
    if (newProducts != null) {
      try {
        await this.db.productDao.saveProducts(newProducts);
      } catch (e) {
        print("here error when saving warnings from http");
        print(e);
      }
    } else {
      try {
        List<Product> warnings = await this.getAllProducts();
        await this.db.productDao.saveProducts(warnings);
      } catch (e) {
        print("here error when saving warnings from http, full request");
        print(e);
      }
    }
  }
}
