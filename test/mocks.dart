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
