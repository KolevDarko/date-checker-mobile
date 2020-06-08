import 'package:date_checker_app/database/database.dart';

class DbProvider {
  static final DbProvider _dbProvider = DbProvider._internal();
  DbProvider._internal();

  static DbProvider get instance => _dbProvider;

  static AppDatabase _database;

  Future<AppDatabase> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDb();
      return _database;
    }
  }

  Future<AppDatabase> _initDb() async {
    AppDatabase dbRef =
        await $FloorAppDatabase.databaseBuilder('date_checker.db').build();
    return dbRef;
  }
}
