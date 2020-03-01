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
    final batchWarningResponse = await this
        .httpClient
        .get(batchWarningsUrl, headers: batchWarningHeaders);
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

  Future<void> saveWarningsLocally() async {
    AppDatabase db = await DbProvider.instance.database;
    List<BatchWarning> warnings = await this.getAllBatchWarnings();
    try {
      await db.batchWarningDao.saveWarnings(warnings);
    } catch (e) {
      print("here error when saving warnings from http");
      print(e);
    }
  }
}
