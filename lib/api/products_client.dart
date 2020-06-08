import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/helper_functions.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class ProductsApiClient {
  final http.Client httpClient;

  ProductsApiClient({this.httpClient}) : assert(httpClient != null);

  Future<List<Product>> getAllProducts() async {
    List<dynamic> productsJson = [];
    dynamic responseBody;
    http.Response productResponse;
    try {
      productResponse = await callApiEndPoint(
        HttpAction.GET,
        productsUrl,
        "Error calling products end point",
        httpClient,
      );
    } catch (e) {
      throw Exception("Couldn't get products data");
    }
    responseBody = jsonDecode(productResponse.body);
    productsJson = await getAllDataFromApiPoint(responseBody, httpClient);
    return Product.productsListFromJson(productsJson);
  }

  Future<List<Product>> syncProducts(int lastProductId) async {
    String url = productsSyncUrl + '$lastProductId';
    http.Response productsSyncResponse = await callApiEndPoint(
      HttpAction.GET,
      url,
      'Error getting products data sync',
      this.httpClient,
    );
    var productsJson = jsonDecode(productsSyncResponse.body);

    return Product.productsListFromJson(productsJson);
  }
}
