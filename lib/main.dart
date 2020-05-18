import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/api/products_client.dart';
import 'package:date_checker_app/api/product_batch_client.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/provider.dart';
import 'package:date_checker_app/views/authentication/login.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import 'database/models.dart';
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
  List<BatchWarning> warnings = await db.batchWarningDao.all();
  Client httpClient = Client();
  ProductRepository productRepository = ProductRepository(
    productsApiClient: ProductsApiClient(
      httpClient: httpClient,
    ),
    db: db,
  );
  ProductBatchRepository productBatchRepository = ProductBatchRepository(
    productBatchApiClient: ProductBatchApiClient(
      httpClient: httpClient,
    ),
    db: db,
  );
  BatchWarningRepository batchWarningRepository = BatchWarningRepository(
    batchWarningApi: BatchWarningApiClient(
      httpClient: httpClient,
    ),
    db: db,
  );

  runApp(
    InheritedDataProviderHelper(
      database: db,
      child: MyApp(
          productRepository: productRepository,
          productBatchRepository: productBatchRepository,
          batchWarningRepository: batchWarningRepository),
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
            batchWarningRepository: batchWarningRepository,
          ),
        ),
      ],
      child: MaterialApp(title: "Date Checker App", home: LoginView()),
    );
  }
}
