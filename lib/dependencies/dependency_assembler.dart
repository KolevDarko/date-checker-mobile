import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/dependencies/debouncer.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:date_checker_app/api/products_client.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

GetIt dependencyAssembler = GetIt.instance;

void setupDependencyAssembler({
  AppDatabase db,
  GetIt dependencyAssembler,
}) {
  Client httpClient = Client();

  dependencyAssembler.registerFactory(() => Debouncer(milliseconds: 500));

  dependencyAssembler.registerLazySingleton(
    () => ProductRepository(
      productsApiClient: ProductsApiClient(
        httpClient: httpClient,
      ),
      db: db,
    ),
  );
  dependencyAssembler.registerLazySingleton(
    () => ProductBatchRepository(
      productBatchApiClient: ProductBatchApiClient(
        httpClient: httpClient,
      ),
      db: db,
    ),
  );
  dependencyAssembler.registerLazySingleton(
    () => BatchWarningRepository(
      batchWarningApi: BatchWarningApiClient(
        httpClient: httpClient,
      ),
      db: db,
    ),
  );
}
