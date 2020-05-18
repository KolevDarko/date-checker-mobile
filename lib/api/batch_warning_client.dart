import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';
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

  Future<void> updateQuantity(int quantity, BatchWarning batchWarning) {
    // TODO, get endpoint to save the quantity straight away
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
