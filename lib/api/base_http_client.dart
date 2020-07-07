import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseHttpClient {
  final http.Client httpClient;

  BaseHttpClient({this.httpClient});

  Future<http.Response> noHeadersPostApiCallResponse(
      {String url, String errorMessage, dynamic body}) async {
    http.Response response = await httpClient.post(
      url,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> getApiCallResponse(
      {String url, String errorMessage}) async {
    http.Response response = await httpClient.get(url);

    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> postApiCallResponse(
      {String url, String errorMessage, dynamic body}) async {
    http.Response response = await httpClient.post(
      url,
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
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<http.Response> deleteApiCallResponse(
      {String url, String errorMessage}) async {
    http.Response response = await httpClient.delete(url);
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
