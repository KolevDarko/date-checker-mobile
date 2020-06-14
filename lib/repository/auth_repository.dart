import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';

class AuthRepository {
  final AppDatabase db;
  final LocalStorageService localStorage;
  static String userValueKey = 'user';

  AuthRepository({this.localStorage, this.db});

  Future<User> signIn({String email, String password}) async {
    User user = await this.db.userDao.getUserByEmail(email);
    if (user != null) {
      localStorage.saveToDiskAsString(userValueKey, user.email);
    }
    return user;
  }

  Future<void> signOut() async {
    localStorage.removeEntry(userValueKey);
  }

  Future<bool> isSignedIn() async {
    String entry = localStorage.getStringEntry(userValueKey);
    if (entry != null) {
      return true;
    }
    return false;
  }

  Future<User> getLoggedUser() async {
    String email = localStorage.getStringEntry(userValueKey);
    User user = await this.db.userDao.getUserByEmail(email);
    if (user != null) {
      return user;
    }
    return null;
  }
}
