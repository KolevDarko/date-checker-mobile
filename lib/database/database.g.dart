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
    final path = name != null
        ? join(await sqflite.getDatabasesPath(), name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
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

  UserDao _userDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
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
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Product` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `serverId` INTEGER, `name` TEXT, `price` REAL, `barCode` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ProductBatch` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `serverId` INTEGER, `barCode` TEXT, `productId` INTEGER, `quantity` INTEGER, `expirationDate` TEXT, `productName` TEXT, `synced` INTEGER, `created` TEXT, `updated` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `BatchWarning` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `productName` TEXT, `daysLeft` INTEGER, `expirationDate` TEXT, `productBatchId` INTEGER, `status` TEXT, `priority` TEXT, `oldQuantity` INTEGER, `newQuantity` INTEGER, `created` TEXT, `updated` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `email` TEXT, `password` TEXT, `firstName` TEXT, `lastName` TEXT)');

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

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
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
                  'serverId': item.serverId,
                  'name': item.name,
                  'price': item.price,
                  'barCode': item.barCode
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _productMapper = (Map<String, dynamic> row) => Product(
      row['id'] as int,
      row['serverId'] as int,
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
  Future<Product> getLast() async {
    return _queryAdapter.query('SELECT * from Product order by id desc limit 1',
        mapper: _productMapper);
  }

  @override
  Future<Product> getByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM Product WHERE serverId = ?',
        arguments: <dynamic>[serverId], mapper: _productMapper);
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
  Future<Product> getProductWithLastServerId() async {
    return _queryAdapter.query(
        'SELECT * FROM Product ORDER BY serverId DESC LIMIT 1',
        mapper: _productMapper);
  }

  @override
  Future<List<Product>> getProductsBySearchTerm(String inputString) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Product WHERE instr(name, ?) > 0',
        arguments: <dynamic>[inputString],
        mapper: _productMapper);
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

  @override
  Future<void> insertAllProducts(List<Product> products) async {
    await _productInsertionAdapter.insertList(
        products, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    if (database is sqflite.Transaction) {
      await super.saveProducts(products);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.productDao.saveProducts(products);
      });
    }
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
                  'serverId': item.serverId,
                  'barCode': item.barCode,
                  'productId': item.productId,
                  'quantity': item.quantity,
                  'expirationDate': item.expirationDate,
                  'productName': item.productName,
                  'synced': item.synced ? 1 : 0,
                  'created': item.created,
                  'updated': item.updated
                }),
        _productBatchUpdateAdapter = UpdateAdapter(
            database,
            'ProductBatch',
            ['id'],
            (ProductBatch item) => <String, dynamic>{
                  'id': item.id,
                  'serverId': item.serverId,
                  'barCode': item.barCode,
                  'productId': item.productId,
                  'quantity': item.quantity,
                  'expirationDate': item.expirationDate,
                  'productName': item.productName,
                  'synced': item.synced ? 1 : 0,
                  'created': item.created,
                  'updated': item.updated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _productBatchMapper = (Map<String, dynamic> row) => ProductBatch(
      row['id'] as int,
      row['serverId'] as int,
      row['barCode'] as String,
      row['productId'] as int,
      row['quantity'] as int,
      row['expirationDate'] as String,
      (row['synced'] as int) != 0,
      row['created'] as String,
      row['updated'] as String,
      row['productName'] as String);

  final InsertionAdapter<ProductBatch> _productBatchInsertionAdapter;

  final UpdateAdapter<ProductBatch> _productBatchUpdateAdapter;

  @override
  Future<List<ProductBatch>> all() async {
    return _queryAdapter.queryList('SELECT * FROM ProductBatch',
        mapper: _productBatchMapper);
  }

  @override
  Future<ProductBatch> getLast() async {
    return _queryAdapter.query(
        'SELECT * from ProductBatch order by id desc limit 1',
        mapper: _productBatchMapper);
  }

  @override
  Future<List<ProductBatch>> getNewProductBatches() async {
    return _queryAdapter.queryList(
        'SELECT * FROM ProductBatch WHERE serverId IS NULL',
        mapper: _productBatchMapper);
  }

  @override
  Future<List<ProductBatch>> getUnsyncedProductBatches() async {
    return _queryAdapter.queryList(
        'SELECT * FROM ProductBatch WHERE NOT sync AND serverId NOT NULL',
        mapper: _productBatchMapper);
  }

  @override
  Future<ProductBatch> fetchByName(String name) async {
    return _queryAdapter.query('SELECT * FROM ProductBatch WHERE name = ?',
        arguments: <dynamic>[name], mapper: _productBatchMapper);
  }

  @override
  Future<List<ProductBatch>> getByBarCode(String barCode) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ProductBatch WHERE barCode = ?',
        arguments: <dynamic>[barCode],
        mapper: _productBatchMapper);
  }

  @override
  Future<List<ProductBatch>> searchQuery(String inputString) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ProductBatch WHERE INSTR(productName, ?) > 0',
        arguments: <dynamic>[inputString],
        mapper: _productBatchMapper);
  }

  @override
  Future<ProductBatch> get(int id) async {
    return _queryAdapter.query('SELECT * FROM ProductBatch WHERE id = ?',
        arguments: <dynamic>[id], mapper: _productBatchMapper);
  }

  @override
  Future<ProductBatch> getByServerId(int id) async {
    return _queryAdapter.query('SELECT * FROM ProductBatch WHERE serverId = ?',
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
  Future<void> insertAllProductBatches(
      List<ProductBatch> productBatches) async {
    await _productBatchInsertionAdapter.insertList(
        productBatches, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateProductBatch(ProductBatch productBatch) async {
    await _productBatchUpdateAdapter.update(
        productBatch, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> updateBatches(List<ProductBatch> productBatches) {
    return _productBatchUpdateAdapter.updateListAndReturnChangedRows(
        productBatches, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> saveProductBatches(List<ProductBatch> productBatches) async {
    if (database is sqflite.Transaction) {
      await super.saveProductBatches(productBatches);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.productBatchDao
            .saveProductBatches(productBatches);
      });
    }
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
                  'expirationDate': item.expirationDate,
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
                  'expirationDate': item.expirationDate,
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
      row['expirationDate'] as String,
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
  Future<BatchWarning> getByProductBatchId(int id) async {
    return _queryAdapter.query(
        'SELECT * FROM BatchWarning WHERE productBatchId = ?',
        arguments: <dynamic>[id],
        mapper: _batchWarningMapper);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM BatchWarning WHERE id = ?',
        arguments: <dynamic>[id]);
  }

  @override
  Future<BatchWarning> getLast() async {
    return _queryAdapter.query(
        'SELECT * from BatchWarning order by id desc limit 1',
        mapper: _batchWarningMapper);
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

class _$UserDao extends UserDao {
  _$UserDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, dynamic>{
                  'id': item.id,
                  'email': item.email,
                  'password': item.password,
                  'firstName': item.firstName,
                  'lastName': item.lastName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _userMapper = (Map<String, dynamic> row) => User(
      row['id'] as int,
      row['email'] as String,
      row['password'] as String,
      row['firstName'] as String,
      row['lastName'] as String);

  final InsertionAdapter<User> _userInsertionAdapter;

  @override
  Future<User> getUserById(int id) async {
    return _queryAdapter.query('SELECT * FROM User WHERE id = ?',
        arguments: <dynamic>[id], mapper: _userMapper);
  }

  @override
  Future<User> getUserByEmail(String email) async {
    return _queryAdapter.query('SELECT * FROM User WHERE email = ?',
        arguments: <dynamic>[email], mapper: _userMapper);
  }

  @override
  Future<int> add(User user) {
    return _userInsertionAdapter.insertAndReturnId(
        user, sqflite.ConflictAlgorithm.abort);
  }
}
