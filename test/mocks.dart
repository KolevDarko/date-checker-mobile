import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/api/products_client.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockProductsApiClient extends Mock implements ProductsApiClient {}

class MockProductBatchApiClient extends Mock implements ProductBatchApiClient {}

class MockBatchWarningApiClient extends Mock implements BatchWarningApiClient {}

class ProductBatchRepositoryMock extends Mock
    implements ProductBatchRepository {}

class ProductRepositoryMock extends Mock implements ProductRepository {}

class ProductBatchBlocMock extends Mock implements ProductBatchBloc {}

class ProductBlocMock extends Mock implements ProductBloc {}

class BatchWarningRepositoryMock extends Mock
    implements BatchWarningRepository {}

class SyncBatchWarningBlocMock extends Mock implements SyncBatchWarningBloc {}

class ProductSyncBlocMock extends Mock implements ProductSyncBloc {}

class MockAuthRespository extends Mock implements AuthRepository {}

class MockAuthBloc extends Mock implements AuthenticationBloc {}

class BatchWarningMock extends Mock implements BatchWarningBloc {}
