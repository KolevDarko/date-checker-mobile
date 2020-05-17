import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/api/products_client.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';
import 'package:date_checker_app/views/authentication/login.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import 'repository/repository.dart';

Future<void> fillDb() async {
  AppDatabase database = await DbProvider.instance.database;
  List<Product> products = [];
  products = await database.productDao.all();
  if (products.length == 0) {
    await createProducts(database);
  }
}

Future<void> createProducts(AppDatabase database) async {
  Product product1 = Product(null, 'Product 1', 30.0, 'p1-100');
  Product product2 = Product(null, 'Product 2', 40.0, 'p2-100');
  Product product3 = Product(null, 'Product 3', 50.0, 'p3-100');
  Product product4 = Product(null, 'Product 4', 310.0, 'p4-100');
  Product product5 = Product(null, 'Product 5', 303.0, 'p5-100');
  Product product6 = Product(null, 'Product 6', 304.0, 'p6-100');
  Product product7 = Product(null, 'Product 7', 3055.0, 'p7-100');
  Product product8 = Product(null, 'Product 8', 302.0, 'p8-100');
  Product product9 = Product(null, 'Product 9', 130.0, 'p9-100');

  int idP1 = await database.productDao.add(product1);
  int idP2 = await database.productDao.add(product2);
  int idP3 = await database.productDao.add(product3);
  int idP4 = await database.productDao.add(product4);
  int idP5 = await database.productDao.add(product5);
  int idP6 = await database.productDao.add(product6);
  int idP7 = await database.productDao.add(product7);
  int idP8 = await database.productDao.add(product8);
  int idP9 = await database.productDao.add(product9);

  ProductBatch pb1 =
      ProductBatch(null, 'barcode1', idP1, 30, "${DateTime.now()}");
  ProductBatch pb2 =
      ProductBatch(null, 'barcode1', idP2, 15, "${DateTime.now()}");
  ProductBatch pb3 =
      ProductBatch(null, 'barcode1', idP3, 3, "${DateTime.now()}");
  ProductBatch pb4 =
      ProductBatch(null, 'barcode1', idP4, 50, "${DateTime.now()}");
  ProductBatch pb5 =
      ProductBatch(null, 'barcode1', idP5, 1, "${DateTime.now()}");
  ProductBatch pb6 =
      ProductBatch(null, 'barcode1', idP6, 40, "${DateTime.now()}");
  ProductBatch pb7 =
      ProductBatch(null, 'barcode1', idP7, 30, "${DateTime.now()}");

  int pb1Id = await database.productBatchDao.add(pb1);
  int pb2Id = await database.productBatchDao.add(pb2);
  int pb3Id = await database.productBatchDao.add(pb3);
  int pb4Id = await database.productBatchDao.add(pb4);
  int pb5Id = await database.productBatchDao.add(pb5);
  int pb6Id = await database.productBatchDao.add(pb6);
  int pb7Id = await database.productBatchDao.add(pb7);
}

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
  Client httpClient = Client();
  ProductRepository productRepository = ProductRepository(
    productsApiClient: ProductsApiClient(
      httpClient: httpClient,
    ),
    db: db,
  );
  ProductBatchRepository productBatchRepository =
      ProductBatchRepository(httpClient: httpClient);
  BatchWarningRepository batchWarningRepository = BatchWarningRepository(
    batchWarningApi: BatchWarningApiClient(
      httpClient: httpClient,
    ),
  );

  // fillDb();

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
