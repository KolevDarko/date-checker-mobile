import 'package:date_checker_app/database/dao.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:floor/floor.dart';
import 'dart:async';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Product, ProductBatch, BatchWarning, User])
abstract class AppDatabase extends FloorDatabase {
  ProductDao get productDao;
  ProductBatchDao get productBatchDao;
  BatchWarningDao get batchWarningDao;
  UserDao get userDao;
}
