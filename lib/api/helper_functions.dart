import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:http/http.dart' as http;

Future<http.Response> callApiEndPoint(
    String url, String errorMessage, http.Client httpClient) async {
  final response = await httpClient.get(url, headers: authHeaders);
  if (response.statusCode != 200) {
    throw Exception(errorMessage);
  }
  return response;
}

// return only 20 products per request, hence the need of calling it again
Future<List> getAllDataFromApiPoint(
  dynamic responseBody,
  http.Client httpClient,
) async {
  List<dynamic> dataJson = [];
  http.Response dataResponse;
  var localResponseBody = responseBody;

  if (localResponseBody['next'] != null) {
    while (localResponseBody['next'] != null) {
      dataJson.addAll(localResponseBody['results']);
      dataResponse = await callApiEndPoint(
        localResponseBody['next'],
        "Error calling products end point",
        httpClient,
      );
      localResponseBody = jsonDecode(dataResponse.body);
    }
  } else {
    dataJson = localResponseBody['results'];
  }
  return dataJson;
}
