import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/api/helper_functions.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:http/http.dart' as http;

class ProductsApiClient extends BaseHttpClient {
  final http.Client httpClient;

  ProductsApiClient({this.httpClient})
      : assert(httpClient != null),
        super(httpClient: httpClient);

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

  Future<List<Product>> syncProducts(int lastProductId) async {
    String url = productsSyncUrl + '$lastProductId';
    http.Response response = await getApiCallResponse(
      url: url,
      errorMessage: 'Error getting products data sync',
    );
    return Product.productsListFromJson(jsonDecode(response.body));
  }
}
