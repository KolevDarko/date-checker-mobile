import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Product Batch Api Client tests', () {
    ProductBatchApiClient productBatchApiClient;
    http.Client mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      productBatchApiClient = ProductBatchApiClient(httpClient: mockHttpClient);
    });
    test('throws AssertionError when httpClient is null', () {
      expect(
          () => ProductBatchApiClient(httpClient: null), throwsAssertionError);
    });

    group('getAllProductBatches tests', () {
      var jsonResponse;
      var jsonResponseNext;
      String nextUrl;
      setUp(() {
        nextUrl = "http://datecheck.lifehqapp.com/api/product-batches/?page=2";
        jsonResponse = """
          {
            "count": 2,
            "next": null,
            "previous": null,
            "results": [
              {
                "id": 4,
                "original_quantity": 400,
                "quantity": 50,
                "expiration_date": "2020-03-13",
                "id_code": "121",
                "created_on": "2020-03-06T19:06:39.718855Z",
                "updated_on": "2020-05-21T16:55:50.422308Z",
                "store": {
                    "id": 1,
                    "name": "Reptil Aerodrom",
                    "address": "Posle kruzniot",
                    "company": 1
                },
                "product": {
                    "id": 6,
                    "name": "Mirinda",
                    "price": 49.0,
                    "id_code": "005",
                    "company": 1
                }
              }  
            ]
          }
        """;
        jsonResponseNext = """
          {
            "count": 8,
            "next": "http://datecheck.lifehqapp.com/api/product-batches/?page=2",
            "previous": null,
            "results": [
              {
                "id": 3,
                "original_quantity": 99,
                "quantity": 100,
                "expiration_date": "2020-03-13",
                "id_code": "121",
                "created_on": "2020-03-06T19:05:33.442586Z",
                "updated_on": "2020-06-04T20:05:18.503219Z",
                "store": {
                  "id": 1,
                  "name": "Reptil Aerodrom",
                  "address": "Posle kruzniot",
                  "company": 1
                },
                "product": {
                    "id": 5,
                    "name": "Schwepes",
                    "price": 56.0,
                    "id_code": "004",
                    "company": 1
                }
              }                               
            ]
          }
        """;
      });

      test('throws Exception when httpClient return non-200 response',
          () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(404);
        when(mockHttpClient.get(productBatchesUrl))
            .thenAnswer((_) => Future.value(response));

        try {
          await productBatchApiClient.getAllProductBatchesFromServer();
          fail('Should fail');
        } catch (e) {
          expect(e.toString(), 'Exception: Error calling products end point');
        }
      });
      test(
          'return list of product batches on 200 status code with next in response',
          () async {
        var response = MockResponse();
        var responseNext = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(jsonResponseNext);
        when(mockHttpClient.get(productBatchesUrl))
            .thenAnswer((_) => Future.value(response));

        when(responseNext.statusCode).thenReturn(200);
        when(responseNext.body).thenReturn(jsonResponse);
        when(mockHttpClient.get(nextUrl))
            .thenAnswer((_) => Future.value(responseNext));

        List<ProductBatch> batches =
            await productBatchApiClient.getAllProductBatchesFromServer();
        expect(batches.length, 2);
      });

      test(
          'return list of product batches on 200 status code with next = null in response',
          () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(jsonResponse);
        when(mockHttpClient.get(productBatchesUrl))
            .thenAnswer((_) => Future.value(response));

        List<ProductBatch> batches =
            await productBatchApiClient.getAllProductBatchesFromServer();
        expect(batches.length, 1);
      });
    });

    group('callEditBatch test', () {
      var jsonProductBatches;
      List<ProductBatch> batches;
      setUp(() {
        batches = [
          ProductBatch(1, 1, "1001", 1, 30, DateTime.now().toString(), false),
          ProductBatch(2, 2, "2001", 2, 50, DateTime.now().toString(), false),
        ];
        jsonProductBatches = json.encode(ProductBatch.toJsonList(batches));
      });

      test('throws Exception when httpClient return non-200 response',
          () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(500);
        when(mockHttpClient.put(
          syncBatchesUrl,
          body: jsonProductBatches,
        )).thenAnswer((_) => Future.value(response));
        try {
          await productBatchApiClient.putCallResponseBodyOfBatch(batches);
          fail('Should fail');
        } catch (e) {
          expect(e.toString(), 'Exception: Error uploading edited batches.');
        }
      });
      test('return success: true on 200 response', () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(json.encode({"success": true}));
        when(mockHttpClient.put(
          syncBatchesUrl,
          body: jsonProductBatches,
        )).thenAnswer((_) => Future.value(response));
        var responseBody =
            await productBatchApiClient.putCallResponseBodyOfBatch(batches);
        expect(responseBody['success'], true);
      });
    });

    group('uploadLocalBatches tests', () {
      var jsonResponse;
      ProductBatch newBatch;
      setUp(() {
        newBatch = ProductBatch(1, null, '121', 6, 50, "2020-03-13", false,
            DateTime.now().toString(), DateTime.now().toString(), "Mirinda");
        jsonResponse = """
        [
          {
            "id": 4,
            "original_quantity": 400,
            "quantity": 50,
            "expiration_date": "2020-03-13",
            "id_code": "121",
            "created_on": "2020-03-06T19:06:39.718855Z",
            "updated_on": "2020-05-21T16:55:50.422308Z",
            "store": {
                "id": 1,
                "name": "Reptil Aerodrom",
                "address": "Posle kruzniot",
                "company": 1
            },
            "product": {
                "id": 6,
                "name": "Mirinda",
                "price": 49.0,
                "id_code": "005",
                "company": 1
            }
          }  
        ]
        """;
      });
      test('success on upload', () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(jsonResponse);
        when(mockHttpClient.post(
          syncBatchesUrl,
          body: json.encode(ProductBatch.toJsonList([newBatch])),
        )).thenAnswer((_) => Future.value(response));

        List<ProductBatch> editedBatches =
            await productBatchApiClient.updatedBatchesAfterPostCall([newBatch]);
        expect(editedBatches.length, 1);
        expect(editedBatches[0].serverId, 4);
        expect(editedBatches[0].synced, true);
      });
      test('server returns 500', () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(500);
        when(mockHttpClient.post(
          syncBatchesUrl,
          body: json.encode(ProductBatch.toJsonList([newBatch])),
        )).thenAnswer((_) => Future.value(response));

        try {
          List<ProductBatch> editedBatches = await productBatchApiClient
              .updatedBatchesAfterPostCall([newBatch]);
        } catch (e) {
          expect(e.toString(), 'Exception: Bad request, post call.');
        }
      });
    });
  });
}
