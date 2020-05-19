import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/helper_functions.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class ProductsApiClient {
  final http.Client httpClient;

  ProductsApiClient({this.httpClient});

  Future<List<Product>> getAllProducts() async {
    List<dynamic> productsJson = [];
    dynamic responseBody;
    http.Response productResponse;
    try {
      productResponse = await callApiEndPoint(
        productsUrl,
        "Error calling products end point",
        httpClient,
      );
    } catch (e) {
      print("error when calling api endpoint, error: $e");
      throw Exception("Couldn't get products data");
    }
    responseBody = jsonDecode(productResponse.body);

    productsJson = await getAllDataFromApiPoint(responseBody, httpClient);
    return this.createProductsFromJson(productsJson);
  }

  List<Product> createProductsFromJson(var productsJson) {
    List<Product> products = [];
    for (var productJson in productsJson) {
      products.add(Product.fromJson(productJson));
    }
    return products;
  }

  Future<List<Product>> syncProducts(int lastProductId) async {
    String url = productsSyncUrl + '$lastProductId';
    http.Response productsSyncResponse = await callApiEndPoint(
      url,
      'Error getting products data sync',
      this.httpClient,
    );
    var productsJson = jsonDecode(productsSyncResponse.body);
    return this.createProductsFromJson(productsJson);
  }
}
