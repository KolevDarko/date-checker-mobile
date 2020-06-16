import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/encryption_service.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:date_checker_app/repository/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockEncryptionService extends Mock implements EncryptionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  AppDatabase db;
  LocalStorageService localStorage;
  User user;
  AuthRepository authRepository;
  EncryptionService encryptionService;
  String userValueKey;

  setUp(() async {
    userValueKey = 'user';
    user = User(1, "test@test.com", "pass123", "Admin", "Admin");
    db = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    await db.userDao.add(user);
    encryptionService = MockEncryptionService();
    localStorage = MockLocalStorageService();
    authRepository = AuthRepository(
      db: db,
      localStorage: localStorage,
      encryptionService: encryptionService,
    );
  });

  test('throws AssertionError when LocalStorageService is null', () {
    expect(
      () => AuthRepository(
        localStorage: null,
        db: db,
        encryptionService: encryptionService,
      ),
      throwsAssertionError,
    );
  });
  test('throws AssertionError when db is null', () {
    expect(
      () => AuthRepository(
        localStorage: localStorage,
        db: null,
        encryptionService: encryptionService,
      ),
      throwsAssertionError,
    );
  });

  group('signIn tests', () {
    test('signIn with existing user and valid credentials', () async {
      when(localStorage.saveToDiskAsString(userValueKey, user.email))
          .thenReturn(null);
      when(encryptionService.matchHashedStrings('pass123', 'pass123'))
          .thenReturn(true);
      User loggedInUser = await authRepository.signIn(
          email: user.email, password: user.password);
      expect(loggedInUser.email, user.email);
      expect(loggedInUser, isNot(null));
    });

    test('signIn with existing user and invalid credentials', () async {
      when(localStorage.saveToDiskAsString(userValueKey, user.email))
          .thenReturn(null);
      when(encryptionService.matchHashedStrings('pass123', '123456'))
          .thenReturn(false);
      try {
        User loggedInUser =
            await authRepository.signIn(email: user.email, password: '123456');
      } catch (e) {
        expect(e.toString(), 'Exception: No such user.');
      }
    });
  });

  group('isSignedIn tests', () {
    String userKey;
    setUp(() {
      userKey = 'user';
    });
    test('isSignedIn true', () async {
      when(localStorage.getStringEntry(userKey)).thenReturn(user.email);
      bool isSignedIn = await authRepository.isSignedIn();
      expect(isSignedIn, true);
    });

    test('isSignedIn false', () async {
      when(localStorage.getStringEntry(userKey)).thenReturn(null);
      bool isSignedIn = await authRepository.isSignedIn();
      expect(isSignedIn, false);
    });
  });

  group('getLoggedUser tests', () {
    String userKey;
    setUp(() {
      userKey = 'user';
    });
    test('getLoggedUser with user logged in', () async {
      when(localStorage.getStringEntry(userKey)).thenReturn(user.email);
      User loggedUser = await authRepository.getLoggedUser();
      expect(loggedUser.email, user.email);
    });

    test('getLoggedUser with no logged in users', () async {
      when(localStorage.getStringEntry(userKey)).thenReturn(null);
      User loggedUser = await authRepository.getLoggedUser();
      expect(loggedUser, null);
    });
  });

  tearDown(() async {
    await db.close();
  });
}
