import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:http/http.dart' as http;

import 'base_http_client.dart';

class ProductsApiClient extends BaseHttpClient {
  final http.Client httpClient;
  final LocalStorageService localStorage;

  ProductsApiClient({this.httpClient, this.localStorage})
      : assert(httpClient != null),
        assert(localStorage != null),
        super(
          httpClient: httpClient,
          localStorage: localStorage,
        );

  Future<List<Product>> getAllProductsFromServer() async {
    List<dynamic> productsJson = [];
    dynamic responseBody;
    http.Response response;

    response = await getApiCallResponse(
      url: productsUrl,
      errorMessage: "Error calling products end point",
    );
    responseBody = jsonDecode(response.body);
    if (responseBody['next'] != null) {
      productsJson = await getPaginatedApiCallResults(responseBody);
    } else {
      productsJson = List.of(responseBody['results']);
    }

    return Product.productsListFromJson(productsJson);
  }

  Future<List<Product>> getLatestProducts(int lastProductId) async {
    String url = productsSyncUrl + '$lastProductId';
    http.Response response = await getApiCallResponse(
      url: url,
      errorMessage: 'Error getting products data sync',
    );
    return Product.productsListFromJson(jsonDecode(response.body));
  }
}
