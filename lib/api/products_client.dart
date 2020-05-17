import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class ProductsApiClient {
  final http.Client httpClient;

  ProductsApiClient({this.httpClient});

  Future<List<Product>> getAllProducts() async {
    final productResponse = await this.httpClient.get(
          productsUrl,
          headers: authHeaders,
        );
    if (productResponse.statusCode != 200) {
      throw Exception('Error getting products data');
    }
    final responseBody = jsonDecode(productResponse.body);
    final productsJson = responseBody['results'];

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
    var productsSyncResponse =
        await this.httpClient.get(url, headers: authHeaders);

    if (productsSyncResponse.statusCode != 200) {
      throw Exception('Error getting products data');
    }
    var productsJson = jsonDecode(productsSyncResponse.body);
    return this.createProductsFromJson(productsJson);
  }
}
