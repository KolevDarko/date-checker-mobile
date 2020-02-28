import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';

class BatchWarningRepository {
  Future<List<BatchWarning>> warnings() async {
    AppDatabase db = await DbProvider.instance.database;
    return db.batchWarningDao.all();
  }
}
