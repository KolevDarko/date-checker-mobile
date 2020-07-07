import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:http/http.dart' as http;

import 'base_http_client.dart';

class ProductBatchApiClient extends BaseHttpClient {
  final http.Client httpClient;
  final LocalStorageService localStorage;

  ProductBatchApiClient({this.httpClient, this.localStorage})
      : assert(httpClient != null),
        assert(localStorage != null),
        super(
          httpClient: httpClient,
          localStorage: localStorage,
        );

  Future<List<ProductBatch>> getAllProductBatchesFromServer() async {
    List<dynamic> productBatchesJson;
    http.Response response = await getApiCallResponse(
      url: productBatchesUrl,
      errorMessage: "Error calling products end point",
    );
    dynamic responseBody = json.decode(response.body);
    if (responseBody['next'] != null) {
      productBatchesJson = await getPaginatedApiCallResults(responseBody);
    } else {
      productBatchesJson = responseBody['results'];
    }
    return ProductBatch.batchesListFromJson(productBatchesJson);
  }

  Future<List<ProductBatch>> updatedBatchesAfterPostCall(
    List<ProductBatch> localBatches,
  ) async {
    http.Response response = await postApiCallResponse(
      url: syncBatchesUrl,
      errorMessage: "Bad request, post call.",
      body: json.encode(ProductBatch.toJsonList(localBatches)),
    );

    return this.updatedBatchesWithServerIdValues(
      localBatches,
      json.decode(response.body),
    );
  }

  Future<dynamic> putCallResponseBodyOfBatch(
    List<ProductBatch> editedBatches,
  ) async {
    http.Response uploadResponse = await putApiCallResponse(
      url: syncBatchesUrl,
      errorMessage: "Error uploading edited batches.",
      body: json.encode(ProductBatch.toJsonList(editedBatches)),
    );
    return json.decode(uploadResponse.body);
  }

  List<ProductBatch> updatedBatchesWithServerIdValues(
    List<ProductBatch> localBatches,
    dynamic responseBody,
  ) {
    List<ProductBatch> editedBatches = List<ProductBatch>.of(localBatches);
    for (ProductBatch productBatch in editedBatches) {
      var item = responseBody
          .firstWhere((val) => val['id_code'] == productBatch.barCode);
      productBatch.serverId = item['id'];
      productBatch.synced = true;
    }
    return editedBatches;
  }
}
