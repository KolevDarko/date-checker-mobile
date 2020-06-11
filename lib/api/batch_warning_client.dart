import 'dart:convert';

import 'package:date_checker_app/api/base_http_client.dart';
import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class BatchWarningApiClient extends BaseHttpClient {
  final http.Client httpClient;

  BatchWarningApiClient({this.httpClient})
      : assert(httpClient != null),
        super(httpClient: httpClient);

  Future<List<BatchWarning>> getAllBatchWarningsFromServer() async {
    http.Response response = await getApiCallResponse(
        url: batchWarningsUrl,
        errorMessage: "Error getting batch warning data");
    return BatchWarning.warningsListFromJson(jsonDecode(response.body));
  }

  Future<List<BatchWarning>> getLatestBatchWarnings(int batchWarningId) async {
    String latestWarningsUrl = '$batchWarningsUrl?last_id=$batchWarningId';
    http.Response response = await getApiCallResponse(
      url: latestWarningsUrl,
      errorMessage: "Error getting new batches",
    );
    return BatchWarning.warningsListFromJson(jsonDecode(response.body));
  }

  Future<dynamic> warningsPutCallResponseBody(
    List<BatchWarning> warnings,
  ) async {
    http.Response updateResponse = await putApiCallResponse(
      url: batchWarningsUrl,
      errorMessage: "Failed to update server data",
      body: json.encode(BatchWarning.toJsonMap(warnings)),
    );

    return json.decode(updateResponse.body);
  }
}
