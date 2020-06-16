import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:date_checker_app/repository/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  AppDatabase db;
  LocalStorageService localStorage;
  User user;
  AuthRepository authRepository;
  String userValueKey;

  setUp(() async {
    userValueKey = 'user';
    user = User(1, "test@test.com", "pass123", "Admin", "Admin");
    db = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    await db.userDao.add(user);
    localStorage = MockLocalStorageService();
    authRepository = AuthRepository(db: db, localStorage: localStorage);
  });

  test('throws AssertionError when LocalStorageService is null', () {
    expect(
      () => AuthRepository(localStorage: null, db: db),
      throwsAssertionError,
    );
  });
  test('throws AssertionError when db is null', () {
    expect(
      () => AuthRepository(localStorage: localStorage, db: null),
      throwsAssertionError,
    );
  });

  group('signIn tests', () {
    User unsavedUser;
    setUp(() {
      unsavedUser = User(2, 'zoran@123.com', 'heythere', 'Zoran', 'Stoilov');
    });

    test('signIn with existing user and valid credentials', () async {
      print("USER from setUP $user");
      when(localStorage.saveToDiskAsString(userValueKey, user.email))
          .thenReturn(null);
      User loggedInUser = await authRepository.signIn(
          email: user.email, password: user.password);
      print("the user $loggedInUser");
      expect(loggedInUser.email, user.email);
      expect(loggedInUser, isNot(null));
    });
  });

  tearDown(() async {
    await db.close();
  });
}
