import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/helper_functions.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class ProductBatchApiClient {
  final http.Client httpClient;

  ProductBatchApiClient({this.httpClient}) : assert(httpClient != null);

  Future<List<ProductBatch>> getAllProductBatches() async {
    try {
      http.Response productBatchesResponse = await callApiEndPoint(
        HttpAction.GET,
        productBatchesUrl,
        "Error calling products end point",
        httpClient,
      );
      final responseBody = json.decode(productBatchesResponse.body);
      List<dynamic> productBatchesJson = await getAllDataFromApiPoint(
        responseBody,
        httpClient,
      );
      return this.createProductBatchesFromJson(productBatchesJson);
    } catch (e) {
      print(e);
      throw Exception("Couldn't get product bathes data");
    }
  }

  Future<List<ProductBatch>> uploadLocalBatches(
    List<ProductBatch> localBatches,
  ) async {
    try {
      http.Response uploadResponse = await callApiEndPoint(
        HttpAction.POST,
        syncBatchesUrl,
        "Bad request, post call.",
        this.httpClient,
        body: json.encode(ProductBatch.toJsonList(localBatches)),
      );
      var uploadResponseBody = json.decode(uploadResponse.body);
      List<ProductBatch> editedBatches = List<ProductBatch>.of(localBatches);
      // TODO check if this script works
      for (ProductBatch productBatch in editedBatches) {
        var item = uploadResponseBody
            .firstWhere((val) => val['id_code'] == productBatch.barCode);
        productBatch.serverId = item['id'];
        productBatch.synced = true;
      }
      return editedBatches;
    } catch (e) {
      throw Exception("Error saving data on the server");
    }
  }

  Future<dynamic> callEditBatch(List<ProductBatch> editedBatches) async {
    http.Response uploadResponse = await callApiEndPoint(
      HttpAction.PUT,
      syncBatchesUrl,
      "Error uploading edited batches.",
      httpClient,
      body: json.encode(ProductBatch.toJsonList(editedBatches)),
    );

    return json.decode(uploadResponse.body);
  }

  List<ProductBatch> createProductBatchesFromJson(var productBatchesJson) {
    List<ProductBatch> productBatches = [];
    for (var productBatchJson in productBatchesJson) {
      productBatches.add(ProductBatch.fromJson(productBatchJson));
    }
    return productBatches;
  }
}
