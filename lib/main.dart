import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/bloc_delegate.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';
import 'package:date_checker_app/dependencies/dependency_assembler.dart';
import 'package:date_checker_app/dependencies/encryption_service.dart';
import 'package:date_checker_app/dependencies/local_storage_service.dart';
import 'package:date_checker_app/views/authentication/starter_screen.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'repository/repository.dart';

class InheritedDataProvider extends InheritedWidget {
  final AppDatabase database;

  InheritedDataProvider({
    this.database,
    Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase db = await DbProvider.instance.database;
  BlocSupervisor.delegate = SimpleBlocDelegate();
  LocalStorageService ls = await LocalStorageService.getInstance();
  EncryptionService eS = await EncryptionService.getInstance();

  setupDependencyAssembler(
    db: db,
    dependencyAssembler: dependencyAssembler,
    localStorage: ls,
    encService: eS,
  );
  AuthRepository auth = dependencyAssembler.get<AuthRepository>();
  String hashedPass = await auth.hashPassword("123456");
  try {
    User user = User(2, "admin@admin.com", hashedPass, "Admin", "User");
    await db.userDao.add(user);
  } catch (e) {
    print(e);
    print("user exists");
  }

  runApp(
    InheritedDataProviderHelper(
      database: db,
      child: MyApp(
        productRepository: dependencyAssembler.get<ProductRepository>(),
        productBatchRepository:
            dependencyAssembler.get<ProductBatchRepository>(),
        batchWarningRepository:
            dependencyAssembler.get<BatchWarningRepository>(),
      ),
    ),
  );
}

class InheritedDataProviderHelper extends StatefulWidget {
  final AppDatabase database;
  final Widget child;

  const InheritedDataProviderHelper({Key key, this.database, this.child})
      : super(key: key);

  static InheritedDataProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedDataProvider>();
  }

  @override
  _InheritedDataProviderHelperState createState() =>
      _InheritedDataProviderHelperState();
}

class _InheritedDataProviderHelperState
    extends State<InheritedDataProviderHelper> {
  @override
  Widget build(BuildContext context) {
    return InheritedDataProvider(
      database: widget.database,
      child: widget.child,
    );
  }
}

class MyApp extends StatelessWidget {
  final ProductRepository productRepository;
  final ProductBatchRepository productBatchRepository;
  final BatchWarningRepository batchWarningRepository;

  const MyApp(
      {Key key,
      this.productRepository,
      this.productBatchRepository,
      this.batchWarningRepository})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (BuildContext context) =>
              ProductBloc(productRepository: productRepository),
        ),
        BlocProvider<ProductBatchBloc>(
          create: (BuildContext context) =>
              ProductBatchBloc(productBatchRepository: productBatchRepository),
        ),
        BlocProvider<BatchWarningBloc>(
          create: (BuildContext context) => BatchWarningBloc(
            productBatchBloc: BlocProvider.of<ProductBatchBloc>(context),
            batchWarningRepository: batchWarningRepository,
          ),
        ),
        BlocProvider<ProductSyncBloc>(
          create: (BuildContext context) => ProductSyncBloc(
            productRepository: productRepository,
            productBloc: BlocProvider.of<ProductBloc>(context),
          ),
        ),
        BlocProvider<SyncBatchWarningBloc>(
          create: (BuildContext context) => SyncBatchWarningBloc(
            batchWarningRepository: batchWarningRepository,
            batchWarningBloc: BlocProvider.of<BatchWarningBloc>(context),
          ),
        ),
        BlocProvider<NotificationsBloc>(
          create: (BuildContext context) => NotificationsBloc(
            productSyncBloc: BlocProvider.of<ProductSyncBloc>(context),
            syncBatchWarningBloc:
                BlocProvider.of<SyncBatchWarningBloc>(context),
          ),
        ),
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => AuthenticationBloc(
            authRepository: dependencyAssembler.get<AuthRepository>(),
          )..add(
              AuthenticationStarted(),
            ),
        ),
        BlocProvider<LoggedOutBloc>(
          create: (context) => LoggedOutBloc(
            authBloc: BlocProvider.of<AuthenticationBloc>(context),
          ),
        )
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Date Checker App",
          home: LoginView(),
          theme: ThemeData(
            // Define the default brightness and colors.
            appBarTheme: AppBarTheme(color: Colors.black38),
            primaryColor: Colors.lightBlue[800],
            accentColor: Colors.red[600],

            // Define the default font family.
            fontFamily: 'Georgia',

            // Define the default TextTheme. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
            textTheme: TextTheme(
              headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
              headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
              bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
            ),
          )),
    );
  }
}
