import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class ProductBatchApiClient {
  final http.Client httpClient;

  ProductBatchApiClient({this.httpClient});

  Future<List<ProductBatch>> getAllProductBatches() async {
    final productBatchesResponse = await this.httpClient.get(
          productBatchesUrl,
          headers: authHeaders,
        );
    if (productBatchesResponse.statusCode != 200) {
      throw Exception('Error getting product batches data');
    }
    final responseBody = jsonDecode(productBatchesResponse.body);
    final productBatchesJson = responseBody['results'];
    return this.createProductBatchesFromJson(productBatchesJson);
  }

  List<ProductBatch> createProductBatchesFromJson(var productBatchesJson) {
    List<ProductBatch> productBatches = [];
    for (var productBatchJson in productBatchesJson) {
      productBatches.add(ProductBatch.fromJson(productBatchJson));
    }
    return productBatches;
  }
}
