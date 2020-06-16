import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class AuthRepository {
  final AppDatabase db;
  final LocalStorageService localStorage;
  static String userValueKey = 'user';

  AuthRepository({this.localStorage, this.db})
      : assert(localStorage != null),
        assert(db != null);

  Future<User> signIn({String email, String password}) async {
    print("here 1");
    User user = await this.db.userDao.getUserByEmail(email);
    print("user $user");
    if (user != null && _passwordHashMatches(user.password, password)) {
      localStorage.saveToDiskAsString(userValueKey, user.email);
      return user;
    }
    throw Exception("No such user.");
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

  Future<String> hashPassword(String password) async {
    final cryptor = new PlatformStringCryptor();
    final salt = await cryptor.generateSalt();
    final saltedPassword = salt + password;
    final bytes = utf8.encode(saltedPassword);
    final hash = sha256.convert(bytes);
    return '$salt.$hash';
  }

  bool _passwordHashMatches(String saltHash, String password) {
    final parts = saltHash.split('.');
    final salt = parts[0];
    final savedHash = parts[1];
    final saltedPassword = salt + password;
    final bytes = utf8.encode(saltedPassword);
    final newHash = sha256.convert(bytes).toString();
    return newHash == savedHash;
  }
}
