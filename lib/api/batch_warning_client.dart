import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/helper_functions.dart';
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
    http.Response batchWarningResponse = await callApiEndPoint(
      HttpAction.GET,
      syncBatchWarningsUrl,
      "Error getting new batches",
      httpClient,
    );

    final batchWarnings = jsonDecode(batchWarningResponse.body);
    return this.createBatchWarningsFromJson(batchWarnings);
  }

  Future<dynamic> updateWarnings(List<BatchWarning> warnings) async {
    try {
      http.Response updateResponse = await callApiEndPoint(
        HttpAction.PUT,
        batchWarningsUrl,
        "Failed to update server data",
        httpClient,
        body: json.encode(BatchWarning.toJsonMap(warnings)),
      );

      return json.decode(updateResponse.body);
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
