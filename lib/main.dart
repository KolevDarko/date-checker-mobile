import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';
import 'package:date_checker_app/views/product_batch/add_product_batch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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
  print("here");
  Product product1 = Product(null, 'Product 1', 30.0, 'p1-100');
  Product product2 = Product(null, 'Product 2', 40.0, 'p2-100');
  Product product3 = Product(null, 'Product 3', 50.0, 'p3-100');
  Product product4 = Product(null, 'Product 4', 310.0, 'p4-100');
  Product product5 = Product(null, 'Product 5', 303.0, 'p5-100');
  Product product6 = Product(null, 'Product 6', 304.0, 'p6-100');
  Product product7 = Product(null, 'Product 7', 3055.0, 'p7-100');
  Product product8 = Product(null, 'Product 8', 302.0, 'p8-100');
  Product product9 = Product(null, 'Product 9', 130.0, 'p9-100');

  await database.productDao.add(product1);
  await database.productDao.add(product2);
  await database.productDao.add(product3);
  await database.productDao.add(product4);
  await database.productDao.add(product5);
  await database.productDao.add(product6);
  await database.productDao.add(product7);
  await database.productDao.add(product8);
  await database.productDao.add(product9);
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
    BlocProvider.of<ProductBatchBloc>(context).add(AllProductBatch());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: <Widget>[
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddProductBatchView()));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width - 40.0,
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        border: Border.all(width: 2.0, color: Colors.indigo)),
                    child: Text("Add New Product Batch"),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Column(
                children: <Widget>[
                  Container(
                    child: Text('Filters:', style: TextStyle(fontSize: 16.0)),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (orderByExpiry) {
                              BlocProvider.of<ProductBatchBloc>(context)
                                  .add(AllProductBatch());
                              setState(() {
                                orderByExpiry = !orderByExpiry;
                              });
                            } else {
                              BlocProvider.of<ProductBatchBloc>(context)
                                  .add(OrderByExpiryDateEvent());
                              setState(() {
                                orderByExpiry = !orderByExpiry;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            color: orderByExpiry
                                ? Colors.indigo[200]
                                : Colors.transparent,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text('Order by expiry date',
                                      style: TextStyle(fontSize: 16.0)),
                                ),
                                orderByExpiry
                                    ? Icon(Icons.keyboard_arrow_up)
                                    : Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text('Order by date created',
                                    style: TextStyle(fontSize: 16.0)),
                              ),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text('All Product Batches:',
                    style: TextStyle(fontSize: 16.0)),
              ),
              BlocBuilder<ProductBatchBloc, ProductBatchState>(
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductBatchItems(List<ProductBatch> productBatchList) {
    return DataTable(
      columns: [
        DataColumn(
          label: Text('Product'),
        ),
        DataColumn(label: Text('Bar Code')),
        DataColumn(label: Text('Quantity'), numeric: true),
        DataColumn(label: Text('Expiration'))
      ],
      rows: productBatchList
          .map((_batch) => DataRow(cells: [
                DataCell(Text(_batch.productId.toString())),
                DataCell(Text(_batch.barCode)),
                DataCell(Text(_batch.quantity.toString())),
                DataCell(Text(_batch.expirationDate)),
              ]))
          .toList(),
    );
//    return ListView.builder(
//        itemCount: productBatchList.length,
//        shrinkWrap: true,
//        itemBuilder: (context, index) {
//          return Container(
//            color: orderByExpiry ? Colors.indigo[200] : Colors.transparent,
//            padding: EdgeInsets.all(10.0),
//            child: Text('${productBatchList[index].barCode}'),
//          );
//        });
  }
}

//class _ProductBatchDataSource extends DataTableSource {
//  _ProductBatchDataSource(this.context){
//  }
//  final BuildContext context;
//  List<ProductBatchBloc> _desserts;
//}
