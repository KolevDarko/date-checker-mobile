import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/encryption_service.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';

class AuthRepository {
  final AppDatabase _db;
  final LocalStorageService _localStorage;
  final EncryptionService _encryptionService;
  static String userValueKey = 'user';

  AuthRepository(
      {LocalStorageService localStorage,
      AppDatabase db,
      EncryptionService encryptionService})
      : _localStorage = localStorage,
        _encryptionService = encryptionService,
        _db = db,
        assert(localStorage != null),
        assert(db != null),
        assert(encryptionService != null);

  Future<User> signIn({String email, String password}) async {
    User user = await this._db.userDao.getUserByEmail(email);
    if (user != null && _passwordMatches(user.password, password)) {
      _localStorage.saveToDiskAsString(userValueKey, user.email);
      return user;
    }
    throw Exception("No such user.");
  }

  Future<void> signOut() async {
    _localStorage.removeEntry(userValueKey);
  }

  Future<bool> isSignedIn() async {
    String entry = _localStorage.getStringEntry(userValueKey);
    if (entry != null) {
      return true;
    }
    return false;
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
