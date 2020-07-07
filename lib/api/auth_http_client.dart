import 'dart:convert';

import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:http/http.dart' as http;

import 'base_http_client.dart';
import 'constants.dart';

class AuthHttpClient extends BaseHttpClient {
  final http.Client httpClient;
  final LocalStorageService localStorage;

  AuthHttpClient({this.httpClient, this.localStorage})
      : assert(httpClient != null),
        assert(localStorage != null),
        super(httpClient: httpClient, localStorage: localStorage);

  Future<String> getAuthToken({String user, String password}) async {
    dynamic body = jsonEncode({"username": user, "password": password});
    http.Response response = await noHeadersPostApiCallResponse(
      errorMessage: 'Failed to obtain token',
      url: authUrl,
      body: body,
    );
    final responseBody = jsonDecode(response.body);
    return responseBody['token'];
  }
}
