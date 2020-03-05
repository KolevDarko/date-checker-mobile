// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final database = _$AppDatabase();
    database.database = await database.open(
      name ?? ':memory:',
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ProductDao _productDaoInstance;

  ProductBatchDao _productBatchDaoInstance;

  BatchWarningDao _batchWarningDaoInstance;

  Future<sqflite.Database> open(String name, List<Migration> migrations,
      [Callback callback]) async {
    final path = join(await sqflite.getDatabasesPath(), name);

    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Product` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT, `price` REAL, `barCode` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ProductBatch` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `barCode` TEXT, `productId` INTEGER, `quantity` INTEGER, `expirationDate` TEXT, `created` TEXT, `updated` TEXT, FOREIGN KEY (`productId`) REFERENCES `Product` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `BatchWarning` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `productName` TEXT, `daysLeft` INTEGER, `productBatchId` INTEGER, `status` TEXT, `priority` TEXT, `oldQuantity` INTEGER, `newQuantity` INTEGER, `created` TEXT, `updated` TEXT, FOREIGN KEY (`productBatchId`) REFERENCES `ProductBatch` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  ProductDao get productDao {
    return _productDaoInstance ??= _$ProductDao(database, changeListener);
  }

  @override
  ProductBatchDao get productBatchDao {
    return _productBatchDaoInstance ??=
        _$ProductBatchDao(database, changeListener);
  }

  @override
  BatchWarningDao get batchWarningDao {
    return _batchWarningDaoInstance ??=
        _$BatchWarningDao(database, changeListener);
  }
}

class _$ProductDao extends ProductDao {
  _$ProductDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _productInsertionAdapter = InsertionAdapter(
            database,
            'Product',
            (Product item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'price': item.price,
                  'barCode': item.barCode
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _productMapper = (Map<String, dynamic> row) => Product(
      row['id'] as int,
      row['name'] as String,
      row['price'] as double,
      row['barCode'] as String);

  final InsertionAdapter<Product> _productInsertionAdapter;

  @override
  Future<List<Product>> all() async {
    return _queryAdapter.queryList('SELECT * FROM Product',
        mapper: _productMapper);
  }

  @override
  Future<Product> fetchByName(String name) async {
    return _queryAdapter.query('SELECT * FROM Product WHERE name = ?',
        arguments: <dynamic>[name], mapper: _productMapper);
  }

  @override
  Future<Product> get(int id) async {
    return _queryAdapter.query('SELECT * FROM Product WHERE id = ?',
        arguments: <dynamic>[id], mapper: _productMapper);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Product WHERE id = ?',
        arguments: <dynamic>[id]);
  }

  @override
  Future<int> add(Product product) {
    return _productInsertionAdapter.insertAndReturnId(
        product, sqflite.ConflictAlgorithm.abort);
  }
}

class _$ProductBatchDao extends ProductBatchDao {
  _$ProductBatchDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _productBatchInsertionAdapter = InsertionAdapter(
            database,
            'ProductBatch',
            (ProductBatch item) => <String, dynamic>{
                  'id': item.id,
                  'barCode': item.barCode,
                  'productId': item.productId,
                  'quantity': item.quantity,
                  'expirationDate': item.expirationDate,
                  'created': item.created,
                  'updated': item.updated
                }),
        _productBatchUpdateAdapter = UpdateAdapter(
            database,
            'ProductBatch',
            ['id'],
            (ProductBatch item) => <String, dynamic>{
                  'id': item.id,
                  'barCode': item.barCode,
                  'productId': item.productId,
                  'quantity': item.quantity,
                  'expirationDate': item.expirationDate,
                  'created': item.created,
                  'updated': item.updated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _productBatchMapper = (Map<String, dynamic> row) => ProductBatch(
      row['id'] as int,
      row['barCode'] as String,
      row['productId'] as int,
      row['quantity'] as int,
      row['expirationDate'] as String,
      row['created'] as String,
      row['updated'] as String);

  final InsertionAdapter<ProductBatch> _productBatchInsertionAdapter;

  final UpdateAdapter<ProductBatch> _productBatchUpdateAdapter;

  @override
  Future<List<ProductBatch>> all() async {
    return _queryAdapter.queryList('SELECT * FROM ProductBatch',
        mapper: _productBatchMapper);
  }

  @override
  Future<ProductBatch> fetchByName(String name) async {
    return _queryAdapter.query('SELECT * FROM ProductBatch WHERE name = ?',
        arguments: <dynamic>[name], mapper: _productBatchMapper);
  }

  @override
  Future<ProductBatch> get(int id) async {
    return _queryAdapter.query('SELECT * FROM ProductBatch WHERE id = ?',
        arguments: <dynamic>[id], mapper: _productBatchMapper);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM ProductBatch WHERE id = ?',
        arguments: <dynamic>[id]);
  }

  @override
  Future<int> add(ProductBatch productBatch) {
    return _productBatchInsertionAdapter.insertAndReturnId(
        productBatch, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateProductBatch(ProductBatch productBatch) async {
    await _productBatchUpdateAdapter.update(
        productBatch, sqflite.ConflictAlgorithm.abort);
  }
}

class _$BatchWarningDao extends BatchWarningDao {
  _$BatchWarningDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _batchWarningInsertionAdapter = InsertionAdapter(
            database,
            'BatchWarning',
            (BatchWarning item) => <String, dynamic>{
                  'id': item.id,
                  'productName': item.productName,
                  'daysLeft': item.daysLeft,
                  'productBatchId': item.productBatchId,
                  'status': item.status,
                  'priority': item.priority,
                  'oldQuantity': item.oldQuantity,
                  'newQuantity': item.newQuantity,
                  'created': item.created,
                  'updated': item.updated
                }),
        _batchWarningUpdateAdapter = UpdateAdapter(
            database,
            'BatchWarning',
            ['id'],
            (BatchWarning item) => <String, dynamic>{
                  'id': item.id,
                  'productName': item.productName,
                  'daysLeft': item.daysLeft,
                  'productBatchId': item.productBatchId,
                  'status': item.status,
                  'priority': item.priority,
                  'oldQuantity': item.oldQuantity,
                  'newQuantity': item.newQuantity,
                  'created': item.created,
                  'updated': item.updated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _batchWarningMapper = (Map<String, dynamic> row) => BatchWarning(
      row['id'] as int,
      row['productName'] as String,
      row['daysLeft'] as int,
      row['productBatchId'] as int,
      row['status'] as String,
      row['priority'] as String,
      row['oldQuantity'] as int,
      row['newQuantity'] as int,
      row['created'] as String,
      row['updated'] as String);

  final InsertionAdapter<BatchWarning> _batchWarningInsertionAdapter;

  final UpdateAdapter<BatchWarning> _batchWarningUpdateAdapter;

  @override
  Future<List<BatchWarning>> all() async {
    return _queryAdapter.queryList('SELECT * FROM BatchWarning',
        mapper: _batchWarningMapper);
  }

  @override
  Future<List<BatchWarning>> allStatusChecked(String status) async {
    return _queryAdapter.queryList(
        'SELECT * FROM BatchWarning WHERE status = ?',
        arguments: <dynamic>[status],
        mapper: _batchWarningMapper);
  }

  @override
  Future<BatchWarning> fetchByName(String name) async {
    return _queryAdapter.query('SELECT * FROM BatchWarning WHERE name = ?',
        arguments: <dynamic>[name], mapper: _batchWarningMapper);
  }

  @override
  Future<BatchWarning> get(int id) async {
    return _queryAdapter.query('SELECT * FROM BatchWarning WHERE id = ?',
        arguments: <dynamic>[id], mapper: _batchWarningMapper);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM BatchWarning WHERE id = ?',
        arguments: <dynamic>[id]);
  }

  @override
  Future<int> add(BatchWarning batchWarning) {
    return _batchWarningInsertionAdapter.insertAndReturnId(
        batchWarning, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> insertAllWarnings(List<BatchWarning> warnings) async {
    await _batchWarningInsertionAdapter.insertList(
        warnings, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateBatchWarning(BatchWarning batchWarning) async {
    await _batchWarningUpdateAdapter.update(
        batchWarning, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> saveWarnings(List<BatchWarning> warnings) async {
    if (database is sqflite.Transaction) {
      await super.saveWarnings(warnings);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.batchWarningDao.saveWarnings(warnings);
      });
    }
  }
}
