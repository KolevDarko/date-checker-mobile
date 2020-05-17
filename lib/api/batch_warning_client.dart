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
    List<BatchWarning> warnings = [];
    final batchWarningResponse = await this.httpClient.get(
          batchWarningsUrl,
          headers: authHeaders,
        );
    if (batchWarningResponse.statusCode != 200) {
      throw Exception('Error getting batch warning data');
    }
    final batchWarnings = jsonDecode(batchWarningResponse.body);
    for (var batchWarningJson in batchWarnings) {
      BatchWarning batchWarning = BatchWarning.fromJson(batchWarningJson);
      warnings.add(batchWarning);
    }
    return warnings;
  }

  Future<List<BatchWarning>> refreshWarnings() async {
    List<BatchWarning> warnings = [];
    AppDatabase db = await DbProvider.instance.database;
    BatchWarning lastBatch = await db.batchWarningDao.getLast();

    int lastId = lastBatch?.id ?? 0;

    String newBatchWarningsUrl = '$batchWarningsUrl?last_id=${lastId}';
    final batchWarningResponse =
        await this.httpClient.get(newBatchWarningsUrl, headers: authHeaders);

    if (batchWarningResponse.statusCode != 200) {
      throw Exception('Error getting new batches');
    }
    final batchWarnings = jsonDecode(batchWarningResponse.body);
    for (var batchWarningJson in batchWarnings) {
      BatchWarning batchWarning = BatchWarning.fromJson(batchWarningJson);
      warnings.add(batchWarning);
    }
    await saveWarningsLocally(newWarnings: warnings);
    return warnings;
  }

  Future<void> saveWarningsLocally({List<BatchWarning> newWarnings}) async {
    AppDatabase db = await DbProvider.instance.database;
    if (newWarnings != null) {
      try {
        await db.batchWarningDao.saveWarnings(newWarnings);
      } catch (e) {
        print("here error when saving warnings from http");
        print(e);
      }
    } else {
      try {
        List<BatchWarning> warnings = await this.getAllBatchWarnings();
        await db.batchWarningDao.saveWarnings(warnings);
      } catch (e) {
        print("here error when saving warnings from http, full request");
        print(e);
      }
    }
  }

  Future<void> updateQuantity(int quantity, BatchWarning batchWarning) {
    // TODO, get endpoint to save the quantity straight away
  }
}
