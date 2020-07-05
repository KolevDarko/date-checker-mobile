import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:date_checker_app/dependencies/dependency_assembler.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:http/http.dart' as http;

class BaseHttpClient {
  final http.Client httpClient;
  String baseUrl;
  Map httpAuthHeaders;
  String _token;

  BaseHttpClient({
    this.httpClient,
  }) : assert(httpClient != null) {
    AuthRepository authRepo = dependencyAssembler.get<AuthRepository>();
    this._token = authRepo.getToken();
    authHeaders['Authorization'] = 'Token ${this._token}';
    this.httpAuthHeaders = authHeaders;
    print("base clinet constructor headers: ${this.httpAuthHeaders}");
  }

  Future<http.Response> noHeadersGetApiCallResponse({
    String url,
    String errorMessage,
  }) async {
    http.Response response = await httpClient.get(url);

    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> getApiCallResponse(
      {String url, String errorMessage}) async {
    http.Response response =
        await httpClient.get(url, headers: httpAuthHeaders);

    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> postApiCallResponse(
      {String url, String errorMessage, dynamic body}) async {
    http.Response response = await httpClient.post(
      url,
      headers: httpAuthHeaders,
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> putApiCallResponse(
      {String url, String errorMessage, dynamic body}) async {
    http.Response response = await httpClient.put(
      url,
      headers: httpAuthHeaders,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> deleteApiCallResponse(
      {String url, String errorMessage}) async {
    http.Response response =
        await httpClient.delete(url, headers: httpAuthHeaders);
    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<List> getPaginatedApiCallResults(dynamic responseBody) async {
    List<dynamic> dataJson = [];
    http.Response response;
    var localResponseBody = responseBody;

    dataJson = localResponseBody['results'];

    while (localResponseBody['next'] != null) {
      response = await this.getApiCallResponse(
        url: localResponseBody['next'],
        errorMessage: "Error calling products end point",
      );
      localResponseBody = jsonDecode(response.body);
      dataJson.addAll(localResponseBody['results']);
    }
    return dataJson;
  }
}
