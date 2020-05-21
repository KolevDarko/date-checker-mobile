import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class BatchWarningApiClient {
  final http.Client httpClient;

  BatchWarningApiClient({this.httpClient});

  Future<List<BatchWarning>> getAllBatchWarnings() async {
    final batchWarningResponse = await this.httpClient.get(
          batchWarningsUrl,
          headers: authHeaders,
        );
    if (batchWarningResponse.statusCode != 200) {
      throw Exception('Error getting batch warning data');
    }
    final batchWarnings = jsonDecode(batchWarningResponse.body);

    return this.createBatchWarningsFromJson(batchWarnings);
  }

  Future<List<BatchWarning>> refreshWarnings(int batchWarningId) async {
    String syncBatchWarningsUrl = '$batchWarningsUrl?last_id=$batchWarningId';
    final batchWarningResponse =
        await this.httpClient.get(syncBatchWarningsUrl, headers: authHeaders);
    if (batchWarningResponse.statusCode != 200) {
      throw Exception('Error getting new batches');
    }
    final batchWarnings = jsonDecode(batchWarningResponse.body);
    return this.createBatchWarningsFromJson(batchWarnings);
  }

  Future<bool> updateQuantity(int quantity, ProductBatch productBatch) async {
    try {
      http.Response updateResponse = await this.httpClient.put(syncBatchesUrl,
          headers: uploadBatchHeaders,
          body: json.encode(
            ProductBatch.toJson(productBatch),
          ));
      if (updateResponse.statusCode != 204) {
        throw Exception(
            "Failed to update server data, status code: ${updateResponse.statusCode}");
      } else {
        return true;
      }
    } catch (e) {
      throw Exception("Something went wrong when doing update on the server");
    }
  }

  List<BatchWarning> createBatchWarningsFromJson(var batchWarnings) {
    List<BatchWarning> warnings = [];
    for (var batchWarningJson in batchWarnings) {
      BatchWarning batchWarning = BatchWarning.fromJson(batchWarningJson);
      warnings.add(batchWarning);
    }
    return warnings;
  }
}
