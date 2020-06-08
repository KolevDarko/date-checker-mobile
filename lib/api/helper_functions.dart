import 'dart:convert';

import 'package:date_checker_app/api/constants.dart';
import 'package:http/http.dart' as http;

enum HttpAction { GET, POST, PUT, DELETE }

Future<http.Response> callApiEndPoint(
  HttpAction action,
  String url,
  String errorMessage,
  http.Client httpClient, {
  dynamic body,
}) async {
  http.Response response;
  switch (action) {
    case HttpAction.GET:
      {
        response = await httpClient.get(url, headers: authHeaders);
      }
      break;
    case HttpAction.POST:
      {
        response = await httpClient.post(
          url,
          headers: uploadBatchHeaders,
          body: body,
        );
      }
      break;
    case HttpAction.PUT:
      {
        response = await httpClient.put(
          url,
          headers: uploadBatchHeaders,
          body: body,
        );
      }
      break;
    case HttpAction.DELETE:
      {
        response = await httpClient.delete(url, headers: uploadBatchHeaders);
      }
      break;
  }

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

  dataJson = localResponseBody['results'];

  if (localResponseBody['next'] != null) {
    while (localResponseBody['next'] != null) {
      dataResponse = await callApiEndPoint(
        HttpAction.GET,
        localResponseBody['next'],
        "Error calling products end point",
        httpClient,
      );
      localResponseBody = jsonDecode(dataResponse.body);
      dataJson.addAll(localResponseBody['results']);
    }
  }

  return dataJson;
}
