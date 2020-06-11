import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/products_client.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';

import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductsApiClient tests', () {
    ProductsApiClient productsApiClient;
    http.Client mockHttpClient;

    setUp(() async {
      mockHttpClient = MockHttpClient();
      productsApiClient = ProductsApiClient(httpClient: mockHttpClient);
    });

    test('throws AssertionError when httpClient is null', () {
      expect(() => ProductsApiClient(httpClient: null), throwsAssertionError);
    });

    group('getAllProducts', () {
      var jsonResponse;
      var jsonResponseNext;
      var nextUrl;
      setUp(() {
        nextUrl = "http://datecheck.lifehqapp.com/api/product-batches/?page=2";
        jsonResponse = """
        {
          "count": 1,
          "next": null,
          "previous": null,
          "results": [
            {"name": "Mirinda", "price": 49.0, "id_code": "005", "id": 6}
          ]
        }
        """;
        jsonResponseNext = """
        {
          "count": 2,
          "next": "$nextUrl",
          "previous": null,
          "results": [
            {"name": "Scheweppes", "price": 59.0, "id_code": "009", "id": 5}
          ]
        }
        """;
      });
      test('throws Exception when httpClient return non-200 response',
          () async {
        final response = MockResponse();
        when(response.statusCode).thenReturn(404);
        when(mockHttpClient.get(productsUrl, headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));
        try {
          await productsApiClient.getAllProductsFromServer();
          fail('should throw');
        } catch (e) {
          expect(e.toString(), 'Exception: Error calling products end point');
        }
      });
      test('return list of products on 200', () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(jsonResponse);
        when(mockHttpClient.get(productsUrl, headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));
        List<Product> products =
            await productsApiClient.getAllProductsFromServer();
        expect(products.length, 1);
        expect(products[0].barCode,
            json.decode(jsonResponse)['results'][0]['id_code']);
      });

      test('return list of products on 200, with having next in url', () async {
        var response = MockResponse();
        var responseNext = MockResponse();
        when(responseNext.statusCode).thenReturn(200);
        when(responseNext.body).thenReturn(jsonResponseNext);
        when(mockHttpClient.get(productsUrl, headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(responseNext));

        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(jsonResponse);
        when(mockHttpClient.get(nextUrl, headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));

        List<Product> products =
            await productsApiClient.getAllProductsFromServer();
        expect(products.length, 2);
      });
    });

    group('sync products', () {
      Product product;
      String finalUrl;
      setUp(() {
        product = Product(1, 1, 'Schweppes', 50.0, "1005");
        finalUrl = productsSyncUrl + product.id.toString();
      });
      test('throws exception on non-200 status code', () async {
        final response = MockResponse();
        when(response.statusCode).thenReturn(404);
        when(mockHttpClient.get(finalUrl, headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));
        try {
          await productsApiClient.syncProducts(product.id);
          fail('should throw');
        } catch (e) {
          expect(e.toString(), 'Exception: Error getting products data sync');
        }
      });

      test('returns list of products on 200 status code', () async {
        final response = MockResponse();
        final jsonResponse = """
        [
            {
                "name": "Mirinda",
                "price": 49.0,
                "id_code": "005",
                "id": 6
            },
            {
                "name": "Schwepes",
                "price": 56.0,
                "id_code": "004",
                "id": 5
            },
            {
                "name": "Sprite",
                "price": 68.0,
                "id_code": "003",
                "id": 4
            },
            {
                "name": "Fanta",
                "price": 70.0,
                "id_code": "002",
                "id": 3
            },
            {
                "name": "Coca Cola",
                "price": 100.0,
                "id_code": "001",
                "id": 2
            }
        ]
        """;
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(jsonResponse);
        when(mockHttpClient.get(finalUrl, headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));

        List<Product> products =
            await productsApiClient.syncProducts(product.id);
        expect(products.length, 5);
      });
    });
  });
}
