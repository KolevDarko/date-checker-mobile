import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';
import 'package:date_checker_app/views/product_batch/add_product_batch.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

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

  BatchWarning.createBatchWarningInstance(database, 'Product 1', 4, pb1Id);
  BatchWarning.createBatchWarningInstance(database, 'Product 2', 2, pb2Id);
  BatchWarning.createBatchWarningInstance(database, 'Product 3', 13, pb3Id);
  BatchWarning.createBatchWarningInstance(database, 'Product 4', 6, pb4Id);
  BatchWarning.createBatchWarningInstance(database, 'Product 5', 9, pb5Id);
  BatchWarning.createBatchWarningInstance(database, 'Product 6', 5, pb6Id);
  BatchWarning.createBatchWarningInstance(database, 'Product 7', 4, pb7Id);
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
  fillDb();
  runApp(InheritedDataProviderHelper(
    database: db,
    child: MyApp(),
  ));
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
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (BuildContext context) =>
              ProductBloc(productRepository: ProductRepository()),
        ),
        BlocProvider<ProductBatchBloc>(
          create: (BuildContext context) => ProductBatchBloc(
              productBatchRepository: ProductBatchRepository()),
        ),
        BlocProvider<BatchWarningBloc>(
          create: (BuildContext context) => BatchWarningBloc(
            batchWarningRepository: BatchWarningRepository(),
          ),
        ),
      ],
      child: MaterialApp(title: "Date Checker App", home: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool orderByExpiry = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    BlocProvider.of<BatchWarningBloc>(context).add(AllBatchWarnings());
  }

  toggleOrderByExpiry() {
    setState(() {
      orderByExpiry = !orderByExpiry;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Text('Пратки')),
                Tab(icon: Text("Истекува")),
                Tab(icon: Text("Производи")),
              ],
            ),
            title: Text('Date Checker Tabs')),
        body: TabBarView(
          children: [
            ProductBatchTable(
              orderByDate: orderByExpiry,
              callBack: toggleOrderByExpiry,
            ),
            BatchWarningTable(),
            Icon(Icons.directions_car),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddProductBatchView()));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ProductBatchTable extends StatefulWidget {
  final bool orderByDate;
  final Function callBack;

  const ProductBatchTable({
    Key key,
    this.orderByDate,
    this.callBack,
  }) : super(key: key);
  @override
  _ProductBatchTableState createState() => _ProductBatchTableState();
}

class _ProductBatchTableState extends State<ProductBatchTable>
    with AutomaticKeepAliveClientMixin {
  bool orderByDate;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    BlocProvider.of<ProductBatchBloc>(context).add(AllProductBatch());
  }

  @override
  Widget build(BuildContext context) {
    orderByDate = widget.orderByDate;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: BlocBuilder<ProductBatchBloc, ProductBatchState>(
          builder: (context, state) {
            if (state is ProductBatchEmpty) {
              return Container();
            } else if (state is ProductBatchLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is AllProductBatchLoaded) {
              return _buildProductBatchItems(state.productBatchList);
            } else if (state is OrderedByExpiryDate) {
              return _buildProductBatchItems(state.productBatchList);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductBatchItems(List<ProductBatch> productBatchList) {
    var cellWidth = MediaQuery.of(context).size.width / 4;
    return customDataTable(
      context: context,
      columns: [
        DataColumn(
          label: Container(
            width: cellWidth,
            child: Row(
              children: <Widget>[
                Container(
                  child: Text(
                    'Датум истек',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                orderByDate
                    ? Icon(Icons.arrow_drop_down)
                    : Icon(Icons.arrow_drop_up),
              ],
            ),
          ),
          onSort: (i, b) {
            widget.callBack();
            if (!orderByDate) {
              BlocProvider.of<ProductBatchBloc>(context).add(
                OrderByExpiryDateEvent(),
              );
            } else {
              BlocProvider.of<ProductBatchBloc>(context).add(AllProductBatch());
            }
          },
        ),
        DataColumn(label: Text('Производ')),
        DataColumn(label: Text('Количина')),
        DataColumn(label: Text('Баркод')),
      ],
      rows: productBatchList
          .map(
            (_batch) => DataRow(
              cells: [
                DataCell(Container(
                    child: Text(_batch.formatDateTime()), width: cellWidth)),
                DataCell(Container(
                    child: Text(_batch.productId.toString()),
                    width: cellWidth)),
                DataCell(Container(
                    child: Text("${_batch.quantity}"), width: cellWidth)),
                DataCell(Container(
                    child: Text(
                      _batch.barCode,
                      overflow: TextOverflow.ellipsis,
                    ),
                    width: cellWidth)),
              ],
            ),
          )
          .toList(),
    );
  }
}

class BatchWarningTable extends StatefulWidget {
  @override
  _BatchWarningTableState createState() => _BatchWarningTableState();
}

class _BatchWarningTableState extends State<BatchWarningTable> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var cellWidth = MediaQuery.of(context).size.width / 3;
    return BlocBuilder<BatchWarningBloc, BatchWarningState>(
      builder: (context, state) {
        if (state is BatchWarningEmpty) {
          return Container();
        } else if (state is BatchWarningLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is BatchWarningAllLoaded) {
          return customDataTable(
            context: context,
            columns: [
              DataColumn(label: Text('Производ')),
              DataColumn(label: Text('Денови пред истек')),
              DataColumn(label: Text('Количина')),
            ],
            rows: state.allBatchWarning.map((warning) {
              return DataRow(cells: [
                DataCell(
                  Container(child: Text(warning.productName), width: cellWidth),
                ),
                DataCell(
                  Container(
                      child: Text(
                        "${warning.daysLeft}",
                        style: TextStyle(
                          color: warning.priorityColor(),
                        ),
                      ),
                      width: cellWidth),
                ),
                DataCell(
                  Container(
                      child: Text("${warning.oldQuantity}"), width: cellWidth),
                ),
              ]);
            }).toList(),
          );
        } else if (state is BatchWarningError) {
          return Center(
            child: Text(state.error),
          );
        }
      },
    );
  }
}

Widget customDataTable({
  BuildContext context,
  List<DataColumn> columns,
  List<DataRow> rows,
}) {
  return SingleChildScrollView(
    child: DataTable(
      columnSpacing: 0.0,
      horizontalMargin: 0.0,
      columns: columns,
      rows: rows,
    ),
  );
}
