import 'dart:convert';

import 'package:http/http.dart' as http;

import 'base_http_client.dart';
import 'constants.dart';

class AuthHttpClient extends BaseHttpClient {
  final http.Client httpClient;

  AuthHttpClient({this.httpClient})
      : assert(httpClient != null),
        super(httpClient: httpClient);

  Future<String> getAuthToken({String user, String password}) async {
    http.Response response = await noHeadersGetApiCallResponse(
      errorMessage: 'Failed to obtain token',
      url: authUrl,
    );
    final responseBody = jsonDecode(response.body);
    return responseBody['token'];
  }
}
