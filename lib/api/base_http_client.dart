import 'dart:convert';
import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:http/http.dart' as http;

class BaseHttpClient {
  final http.Client httpClient;
  final LocalStorageService localStorage;
  String baseUrl;
  Map<String, String> httpAuthHeaders;
  String _token;

  BaseHttpClient({this.httpClient, this.localStorage});

  void _setHeaders() {
    this._token = localStorage.getStringEntry(AuthRepository.tokenValueKey);
    this.httpAuthHeaders = {
      'Authorization': "Token ${this._token}",
      'Content-Type': 'application/json',
    };
  }

  Future<http.Response> noHeadersPostApiCallResponse(
      {String url, String errorMessage, dynamic body}) async {
    http.Response response = await httpClient.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> getApiCallResponse(
      {String url, String errorMessage}) async {
    _setHeaders();
    http.Response response =
        await httpClient.get(url, headers: this.httpAuthHeaders);
    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> postApiCallResponse(
      {String url, String errorMessage, dynamic body}) async {
    _setHeaders();
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
    _setHeaders();
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
    _setHeaders();
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
