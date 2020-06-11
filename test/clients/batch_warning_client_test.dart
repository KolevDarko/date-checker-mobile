import 'dart:convert';

import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Batch Warning Api Client tests', () {
    BatchWarningApiClient batchWarningApiClient;
    http.Client mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      batchWarningApiClient = BatchWarningApiClient(httpClient: mockHttpClient);
    });

    test('throws AssertionError when httpClient is null', () {
      expect(
          () => BatchWarningApiClient(httpClient: null), throwsAssertionError);
    });

    group('getAllBatchWarnings tests', () {
      var jsonResponse;

      setUp(() {
        jsonResponse = """
        [
            {
                "id": 2,
                "product_batch_id": 2,
                "expiration_date": "2020-03-11",
                "days_left": -86,
                "product_id": 3,
                "product_name": "Fanta",
                "quantity": 100,
                "priority": "WARNING"
            }
        ]
        """;
      });

      test('throws Exception when httpClient return non-200 response',
          () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(500);
        when(mockHttpClient.get(batchWarningsUrl, headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));
        try {
          await batchWarningApiClient.getAllBatchWarningsFromServer();
          fail('Should throw');
        } catch (e) {
          expect(e.toString(), 'Exception: Error getting batch warning data');
        }
      });
      test('returns list of batch warnings on 200', () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(jsonResponse);
        when(mockHttpClient.get(batchWarningsUrl, headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));

        List<BatchWarning> warnings =
            await batchWarningApiClient.getAllBatchWarningsFromServer();

        expect(warnings.length, 1);
        expect(warnings[0].productName, "Fanta");
      });
    });

    group('refreshWarnings tests', () {
      var jsonResponse;
      String syncBatchWarningsUrl;
      setUp(() {
        syncBatchWarningsUrl = '$batchWarningsUrl?last_id=1';

        jsonResponse = """
        [
            {
                "id": 2,
                "product_batch_id": 2,
                "expiration_date": "2020-03-11",
                "days_left": -86,
                "product_id": 3,
                "product_name": "Fanta",
                "quantity": 100,
                "priority": "WARNING"
            }
        ]
        """;
      });

      test('returns list of batch warnings for non-200 response', () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(jsonResponse);
        when(mockHttpClient.get(syncBatchWarningsUrl,
                headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));

        List<BatchWarning> warnings =
            await batchWarningApiClient.getLatestBatchWarnings(1);
        expect(warnings.length, 1);
        expect(warnings[0].productName, "Fanta");
      });

      test('throws Exception when httpClient return non-200 response',
          () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(500);
        when(mockHttpClient.get(syncBatchWarningsUrl,
                headers: uploadBatchHeaders))
            .thenAnswer((_) => Future.value(response));
        try {
          await batchWarningApiClient.getLatestBatchWarnings(1);
          fail('Should throw');
        } catch (e) {
          expect(e.toString(), 'Exception: Error getting new batches');
        }
      });
    });
    group('updateWarnings tests', () {
      List<BatchWarning> warnings;
      setUp(() {
        warnings = [
          BatchWarning(1, 'Schweppes', 15, DateTime.now().toString(), 1, 'NEW',
              'WARNING', 50, 50, DateTime.now().toString()),
        ];
      });
      test('throws Exception when httpClient return non-200 response',
          () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(500);
        when(mockHttpClient.put(
          batchWarningsUrl,
          headers: uploadBatchHeaders,
          body: json.encode(BatchWarning.toJsonMap(warnings)),
        )).thenAnswer((_) => Future.value(response));
        try {
          await batchWarningApiClient.warningsPutCallResponseBody(warnings);
          fail('Should throw');
        } catch (e) {
          expect(e.toString(), 'Exception: Failed to update server data');
        }
      });
      test('return success: true on  200 response', () async {
        var response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(json.encode({"success": true}));
        when(mockHttpClient.put(
          batchWarningsUrl,
          headers: uploadBatchHeaders,
          body: json.encode(BatchWarning.toJsonMap(warnings)),
        )).thenAnswer((_) => Future.value(response));
        var bodyResponse =
            await batchWarningApiClient.warningsPutCallResponseBody(warnings);
        expect(bodyResponse['success'], true);
      });
    });
  });
}
