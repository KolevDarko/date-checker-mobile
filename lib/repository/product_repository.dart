import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';

class ProductRepository {
  Future<List<Product>> getAllProducts() async {
    print("called here");
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

  // Future<List<Product>> getProductsInLocation(int storeId) async {
  //   AppDatabase db = await DbProvider.instance.database;
  //   Future<List<Product>> products = db.storeDao.getProducts(storeId);
  //   return products;
  // }

  // Future<int> addProduct(int storeId, String productName, double price,
  //     int quantity, String expiryDate) async {
  //   AppDatabase db = await DbProvider.instance.database;
  //   Product product = Product(null, productName, price);
  //   int productId = await db.productDao.add(product);
  //   ProductInStore productInStore =
  //       ProductInStore(null, storeId, productId, quantity, expiryDate);
  //   int productInStoreId = await db.productInStoreDao.add(productInStore);
  //   return productInStoreId;
  // }

  Future<Product> getProduct(int productId) async {
    AppDatabase db = await DbProvider.instance.database;
    Product product = await db.productDao.get(productId);
    return product;
  }
}
