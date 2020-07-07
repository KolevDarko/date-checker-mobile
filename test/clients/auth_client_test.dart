import 'dart:convert';

import 'package:date_checker_app/api/auth_http_client.dart';
import 'package:date_checker_app/api/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthHttpClient tests', () {
    http.Client httpClient;
    AuthHttpClient authHttpClient;
    var body;
    String url;
    String responseBody;
    String password;
    String username;
    setUp(() {
      httpClient = MockHttpClient();
      password = "there";
      username = "hey";

      authHttpClient = AuthHttpClient(httpClient: httpClient);
      body = jsonEncode({"username": username, "password": password});
      url = authUrl;
      responseBody = """
      {
        "token": "token"
      }
      """;
    });
    test('getAuthToken valid response from server', () async {
      var response = MockResponse();
      when(response.statusCode).thenReturn(200);
      when(response.body).thenReturn(responseBody);
      when(httpClient.post(url, body: body))
          .thenAnswer((_) => Future.value(response));

      String token = await authHttpClient.getAuthToken(
        user: username,
        password: password,
      );
      expect(token, "token");
    });
    test('getAuthToken invalid response from server', () async {
      var response = MockResponse();
      when(response.statusCode).thenReturn(500);
      when(httpClient.post(url, body: body))
          .thenAnswer((_) => Future.value(response));
      try {
        String token = await authHttpClient.getAuthToken(
          user: username,
          password: password,
        );
      } catch (e) {
        expect(e.toString(), 'Exception: Failed to obtain token');
      }
    });
  });
}
