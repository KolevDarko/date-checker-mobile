import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService _instance;
  static SharedPreferences _preferences;

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
    }
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance;
  }

  void saveToDiskAsBool(String key, bool content) {
    _preferences.setBool(key, content);
  }

  void saveToDiskAsString(String key, String content) {
    _preferences.setString(key, content);
  }

  void saveToDiskAsInt(String key, int content) {
    _preferences.setInt(key, content);
  }

  void saveToDiskAsStringList(String key, List<String> content) {
    _preferences.setStringList(key, content);
  }

  void saveToDiskAsDouble(String key, double content) {
    _preferences.setDouble(key, content);
  }

  void removeEntry(String key) {
    _preferences.remove(key);
  }

  String getStringEntry(String key) {
    return _preferences.getString(key);
  }
}
