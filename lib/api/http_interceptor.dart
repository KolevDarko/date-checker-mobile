import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:http_interceptor/http_interceptor.dart';

class AuthHttpInterceptor implements InterceptorContract {
  final LocalStorageService localStorageService;

  AuthHttpInterceptor(this.localStorageService);
  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    try {
      data.headers["Content-Type"] = "application/json";
      String token =
          localStorageService.getStringEntry(AuthRepository.tokenValueKey);
      if (token != null) {
        data.headers["Authorization"] = "Token $token";
      }
    } catch (e) {
      print(e);
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async => data;
}
