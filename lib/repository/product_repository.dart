import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';
import 'package:http/http.dart';

class ProductRepository {
  final Client httpClient;

  ProductRepository({this.httpClient});

  Future<List<Product>> getAllProducts() async {
    AppDatabase db = await DbProvider.instance.database;
    return db.productDao.all();
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
    AppDatabase db = await DbProvider.instance.database;
    Product product = await db.productDao.get(productId);
    return product;
  }
}
