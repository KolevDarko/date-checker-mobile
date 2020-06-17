import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/dependencies/debouncer.dart';
import 'package:date_checker_app/dependencies/encryption_service.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:date_checker_app/api/products_client.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

GetIt dependencyAssembler = GetIt.instance;

void setupDependencyAssembler({
  AppDatabase db,
  GetIt dependencyAssembler,
  LocalStorageService localStorage,
  EncryptionService encService,
}) {
  Client httpClient = Client();

  dependencyAssembler.registerFactory(() => Debouncer(milliseconds: 500));

  dependencyAssembler.registerSingleton<LocalStorageService>(localStorage);

  dependencyAssembler.registerSingleton<EncryptionService>(encService);

  dependencyAssembler.registerLazySingleton(
    () => AuthRepository(
      db: db,
      localStorage: localStorage,
      encryptionService: encService,
    ),
  );

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
