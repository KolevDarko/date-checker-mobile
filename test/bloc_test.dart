import 'package:bloc_test/bloc_test.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/auth_repository.dart';
import 'package:date_checker_app/repository/batch_warning_repository.dart';
import 'package:date_checker_app/repository/product_batch_repository.dart';
import 'package:date_checker_app/repository/product_repository.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ProductBatchBloc', () {
    ProductBatchBloc productBatchBloc;
    ProductBatchRepository productBatchRepository;

    setUp(() {
      productBatchRepository = ProductBatchRepositoryMock();
      productBatchBloc =
          ProductBatchBloc(productBatchRepository: productBatchRepository);
    });

    test('initial state is product batch empty', () {
      expect(productBatchBloc.initialState, ProductBatchEmpty());
    });

    blocTest(
      'loads all the product batches',
      build: () async => productBatchBloc,
      act: (bloc) => bloc.add(AllProductBatch()),
      expect: [
        ProductBatchLoading(),
        AllProductBatchLoaded(),
      ],
    );

    blocTest(
      'synchronize product batch data',
      build: () async => productBatchBloc,
      act: (bloc) => bloc.add(SyncProductBatchData()),
      expect: [
        ProductBatchLoading(),
        SyncProductBatchDataSuccess(),
      ],
    );

    blocTest(
      'order by expiry date',
      build: () async => productBatchBloc,
      act: (bloc) => bloc.add(OrderByExpiryDateEvent()),
      expect: [
        ProductBatchLoading(),
        OrderedByExpiryDate(),
      ],
    );

    blocTest(
      'add product batch',
      build: () async => productBatchBloc,
      act: (bloc) => bloc.add(AddProductBatch()),
      expect: [
        ProductBatchLoading(),
        ProductBatchAdded(),
      ],
    );

    tearDown(() {
      productBatchBloc?.close();
    });
  });
  group('ProductBloc', () {
    ProductBloc productBloc;
    ProductRepository productRepository;

    setUp(() {
      productRepository = ProductRepositoryMock();
      productBloc = ProductBloc(productRepository: productRepository);
    });

    test('initial state is ProductEmpty', () {
      expect(productBloc.initialState, ProductEmpty());
    });

    blocTest(
      'get all products',
      build: () async => productBloc,
      act: (bloc) => bloc.add(FetchAllProducts()),
      expect: [
        ProductLoading(),
        AllProductsLoaded(),
      ],
    );
    tearDown(() {
      productBloc?.close();
    });
  });

  group('BatchWarningBloc', () {
    BatchWarningBloc batchWarningBloc;
    BatchWarningRepository batchWarningRepository;
    ProductBatchBloc productBatchBloc;
    BatchWarning batchWarning;
    setUp(() {
      batchWarningRepository = BatchWarningRepositoryMock();
      productBatchBloc = ProductBatchBlocMock();
      batchWarningBloc = BatchWarningBloc(
        batchWarningRepository: batchWarningRepository,
        productBatchBloc: productBatchBloc,
      );
      batchWarning = BatchWarning(
        1,
        'Product 1',
        20,
        "${DateTime.parse('2020-03-08')}",
        1,
        BatchWarning.batchWarningStatus()[0],
        BatchWarning.batchWarningPriority()[0],
        30,
        30,
        "${DateTime.now()}",
      );
    });

    test('initial state is ProductEmpty', () {
      expect(batchWarningBloc.initialState, BatchWarningEmpty());
    });

    blocTest(
      'get all batch warnings',
      build: () async => batchWarningBloc,
      act: (bloc) => bloc.add(AllBatchWarnings()),
      expect: [
        BatchWarningLoading(),
        BatchWarningAllLoaded(),
      ],
    );
    blocTest(
      'edit quantity',
      build: () async => batchWarningBloc,
      act: (bloc) =>
          bloc.add(EditQuantityEvent(quantity: 20, batchWarning: batchWarning)),
      expect: [
        Success(),
      ],
    );

    tearDown(() {
      productBatchBloc?.close();
      batchWarningBloc?.close();
    });
  });

  group('auth bloc test', () {
    AuthenticationBloc authenticationBloc;
    AuthRepository authRepository;
    User user;
    setUp(() {
      authRepository = MockAuthRespository();
      authenticationBloc = AuthenticationBloc(
        authRepository: authRepository,
      );
      user = User(1, "zoran@123.com", "heythere", "Zoran", "Stoilov");
    });

    test('initial state is correct', () {
      expect(authenticationBloc.initialState, AuthenticationInitial());
    });

    test('close does not emit new states', () {
      expectLater(authenticationBloc,
          emitsInOrder([AuthenticationInitial(), emitsDone]));
      authenticationBloc.close();
    });

    group('AuthenticationStarted', () {
      test('user not logged in state test', () {
        final expectedResponse = [
          AuthenticationInitial(),
          AuthenticationFailure(),
        ];
        when(authRepository.isSignedIn())
            .thenAnswer((_) => Future.value(false));
        expectLater(authenticationBloc, emitsInOrder(expectedResponse));

        authenticationBloc.add(AuthenticationStarted());
      });
      test('user logged in state test', () {
        final expectedResponse = [
          AuthenticationInitial(),
          AuthenticationSuccess(user),
        ];
        when(authRepository.isSignedIn()).thenAnswer((_) => Future.value(true));
        when(authRepository.getLoggedUser())
            .thenAnswer((_) => Future.value(user));
        expectLater(authenticationBloc, emitsInOrder(expectedResponse));

        authenticationBloc.add(AuthenticationStarted());
      });

      test('user logged in state test', () {
        final expectedResponse = [
          AuthenticationInitial(),
          AuthenticationSuccess(user),
        ];
        when(authRepository.isSignedIn()).thenAnswer((_) => Future.value(true));
        when(authRepository.getLoggedUser())
            .thenAnswer((_) => Future.value(user));
        expectLater(authenticationBloc, emitsInOrder(expectedResponse));

        authenticationBloc.add(AuthenticationStarted());
      });
    });

    group('AuthenticationLoggedIn', () {
      test('get logged in user', () {
        final expectedResponse = [
          AuthenticationInitial(),
          AuthenticationSuccess(user),
        ];
        when(authRepository.getLoggedUser())
            .thenAnswer((_) => Future.value(user));
        expectLater(authenticationBloc, emitsInOrder(expectedResponse));
        authenticationBloc.add(AuthenticationLoggedIn());
      });
    });

    group('AuthenticationLoggedOut', () {
      test('test AuthenticationLoggedOut event', () {
        final expectedResponse = [
          AuthenticationInitial(),
          AuthenticationFailure(),
        ];
        when(authRepository.signOut()).thenAnswer((_) => Future.value(null));
        expectLater(authenticationBloc, emitsInOrder(expectedResponse));
        authenticationBloc.add(AuthenticationLoggedOut());
      });
    });

    tearDown(() {
      authenticationBloc?.close();
    });
  });

  group('LoginBloc', () {
    LoginBloc loginBloc;
    AuthRepository authRepository;

    setUp(() {
      authRepository = MockAuthRespository();
      loginBloc = LoginBloc(authRepository: authRepository);
    });

    test('check correct initial state', () {
      expect(loginBloc.initialState.isSuccess, LoginState.initial().isSuccess);
    });

    blocTest(
      'login email changed event',
      build: () async => loginBloc,
      act: (bloc) => bloc.add(LoginEmailChanged()),
      expect: [],
    );

    blocTest(
      'login password changed event',
      build: () async => loginBloc,
      act: (bloc) => bloc.add(LoginPasswordChanged()),
      expect: [],
    );

    blocTest(
      'login password changed event',
      build: () async => loginBloc,
      act: (bloc) => bloc.add(LoginWithCredentialsPressed()),
      expect: [
        isA<LoginState>()
            .having((state) => state.isSubmitting, 'is submitting true', true),
        isA<LoginState>()
            .having((state) => state.isSuccess, 'login passed', true),
      ],
    );
    tearDown(() {
      loginBloc?.close();
    });
  });

  group('LoggedOutBloc', () {
    LoggedOutBloc loggedOutBloc;
    AuthenticationBloc authBloc;
    setUp(() {
      authBloc = MockAuthBloc();
      loggedOutBloc = LoggedOutBloc(
        authBloc: authBloc,
      );
    });

    test('check initial state is correct', () {
      expect(
        loggedOutBloc.initialState,
        isA<IsNotLoggedOut>(),
      );
    });

    blocTest(
      'on logged out event',
      build: () async => loggedOutBloc,
      act: (bloc) => bloc.add(LogOutPressed()),
      expect: [
        isA<IsLoggedOut>(),
      ],
    );

    tearDown(() {
      loggedOutBloc?.close();
      authBloc?.close();
    });
  });

  group('NotificationsBloc', () {
    NotificationsBloc notificationsBloc;
    ProductSyncBloc productSyncBloc;
    SyncBatchWarningBloc syncBatchWarningBloc;
    setUp(() {
      productSyncBloc = ProductSyncBlocMock();
      syncBatchWarningBloc = SyncBatchWarningBlocMock();
      notificationsBloc = NotificationsBloc(
        productSyncBloc: productSyncBloc,
        syncBatchWarningBloc: syncBatchWarningBloc,
      );
    });

    blocTest(
      'test AddNewNotification',
      build: () async => notificationsBloc,
      act: (bloc) => bloc.add(AddNewNotification()),
      expect: [
        isA<DisplayNotification>(),
      ],
    );

    tearDown(() {
      notificationsBloc?.close();
      productSyncBloc?.close();
      syncBatchWarningBloc?.close();
    });
  });
}
