import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class EncryptionService {
  static EncryptionService instance;
  static PlatformStringCryptor _cryptor;

  static Future<EncryptionService> getInstance() async {
    if (instance == null) {
      instance = EncryptionService();
    }
    if (_cryptor == null) {
      _cryptor = PlatformStringCryptor();
    }
    return instance;
  }

  Future<String> _generateSalt() async {
    String salt = await _cryptor.generateSalt();
    return salt;
  }

  List<int> _getBytes(String entry) {
    return utf8.encode(entry);
  }

  Digest _getHash(List<int> bytes) {
    return sha256.convert(bytes);
  }

  Future<String> getSaltedHashString(String entry) async {
    String salt = await _generateSalt();
    String saltedEntry = salt + entry;
    final bytes = _getBytes(saltedEntry);
    final hash = _getHash(bytes);
    return '$salt.$hash';
  }

  bool matchHashedStrings(String hashedString, String entry) {
    List<String> parts = hashedString.split('.');
    String salt = parts[0];
    String savedHash = parts[1];
    String saltedEntry = salt + entry;
    String newHashedString = _getHashedString(saltedEntry);
    return savedHash == newHashedString;
  }

  String _getHashedString(String saltedEntry) {
    final bytes = _getBytes(saltedEntry);
    final hash = _getHash(bytes);
    return hash.toString();
  }
}
