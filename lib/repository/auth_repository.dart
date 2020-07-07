import 'package:date_checker_app/api/auth_http_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/encryption_service.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';

class AuthRepository {
  final AppDatabase _db;
  final LocalStorageService _localStorage;
  final EncryptionService _encryptionService;
  final AuthHttpClient _authClient;
  static String userValueKey = 'user';
  static String tokenValueKey = 'token';

  AuthRepository(
      {LocalStorageService localStorage,
      AppDatabase db,
      EncryptionService encryptionService,
      AuthHttpClient authHttpClient})
      : _localStorage = localStorage,
        _encryptionService = encryptionService,
        _db = db,
        _authClient = authHttpClient,
        assert(localStorage != null),
        assert(db != null),
        assert(encryptionService != null),
        assert(authHttpClient != null);

  Future<bool> signIn({String email, String password}) async {
    String token =
        await this._authClient.getAuthToken(user: email, password: password);
    if (token != null) {
      _localStorage.saveToDiskAsString(tokenValueKey, token);
      return true;
    }
    throw Exception("No such user.");
  }

  Future<void> signOut() async {
    _localStorage.removeEntry(tokenValueKey);
  }

  Future<bool> isSignedIn() async {
    String entry = _localStorage.getStringEntry(tokenValueKey);
    if (entry != null) {
      return true;
    }
    return false;
  }

  String getToken() {
    return _localStorage.getStringEntry(tokenValueKey);
  }

  Future<User> getLoggedUser() async {
    String email = _localStorage.getStringEntry(userValueKey);
    User user = await this._db.userDao.getUserByEmail(email);
    if (user != null) {
      return user;
    }
    return null;
  }

  Future<String> hashPassword(String password) async {
    String hashedPassword =
        await this._encryptionService.getSaltedHashString(password);
    return hashedPassword;
  }

  bool _passwordMatches(String saltHash, String password) {
    bool isMatch =
        this._encryptionService.matchHashedStrings(saltHash, password);
    return isMatch;
  }
}
