import 'package:date_checker_app/api/products_client.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/dependency_assembler.dart';

class MockProductClientApi extends ProductsApiClient {
  @override
  Future<List<Product>> getAllProducts() {
    return Future.value([
      Product(1, 1, 'Coca Cola', 30.0, "1001"),
      Product(2, 2, 'Schweppes', 50.0, "2001"),
      Product(3, 3, 'Mirinda', 100.0, "3001"),
    ]);
  }
}

void main() {
  setupDependencyAssembler();

  // var productListViewModel = depe
}
