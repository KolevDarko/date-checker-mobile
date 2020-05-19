import 'dart:convert';
import 'dart:io';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/helper_functions.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class ProductBatchApiClient {
  final http.Client httpClient;

  ProductBatchApiClient({this.httpClient});

  Future<List<ProductBatch>> getAllProductBatches() async {
    List<dynamic> productBatchesJson = [];
    dynamic responseBody;
    http.Response productBatchesResponse;
    try {
      productBatchesResponse = await callApiEndPoint(
        productBatchesUrl,
        "Error calling products end point",
        httpClient,
      );
    } catch (e) {
      print("error when calling api endpoint, error: $e");
      throw Exception("Couldn't get products data");
    }
    responseBody = jsonDecode(productBatchesResponse.body);
    productBatchesJson = await getAllDataFromApiPoint(responseBody, httpClient);
    return this.createProductBatchesFromJson(productBatchesJson);
  }

  List<ProductBatch> createProductBatchesFromJson(var productBatchesJson) {
    List<ProductBatch> productBatches = [];
    for (var productBatchJson in productBatchesJson) {
      productBatches.add(ProductBatch.fromJson(productBatchJson));
    }
    return productBatches;
  }

  Future<List<ProductBatch>> uploadLocalBatches(
    List<ProductBatch> localBatches,
  ) async {
    http.Response uploadResponse = await this.httpClient.post(
          syncBatchesUrl,
          headers: uploadBatchHeaders,
          body: jsonEncode(localBatches),
        );
    if (uploadResponse.statusCode != 201) {
      throw Exception("Error saving data on the server");
    }
    return this.createProductBatchesFromJson(json.decode(uploadResponse.body));
  }
}
