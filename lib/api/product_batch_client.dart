import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/helper_functions.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class ProductBatchApiClient {
  final http.Client httpClient;

  ProductBatchApiClient({this.httpClient});

  Future<List<ProductBatch>> getAllProductBatches() async {
    try {
      http.Response productBatchesResponse = await callApiEndPoint(
        HttpAction.GET,
        productBatchesUrl,
        "Error calling products end point",
        httpClient,
      );
      final responseBody = jsonDecode(productBatchesResponse.body);
      List<dynamic> productBatchesJson = await getAllDataFromApiPoint(
        responseBody,
        httpClient,
      );
      return this.createProductBatchesFromJson(productBatchesJson);
    } catch (e) {
      throw Exception("Couldn't get products data");
    }
  }

  Future<String> updateProductBatch(ProductBatch productBatch) async {
    try {
      await callApiEndPoint(
        HttpAction.PUT,
        syncBatchesUrl,
        "Bad request, failed to update api.",
        this.httpClient,
        body: json.encode(ProductBatch.toJson(productBatch)),
      );
      return 'Successfully updated product batch';
    } catch (e) {
      throw Exception("Failed to update product batch on the server.");
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
      return this
          .createProductBatchesFromJson(json.decode(uploadResponse.body));
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
