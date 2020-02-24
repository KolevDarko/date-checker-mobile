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
          body: TabBarView(children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
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
                    BlocBuilder<ProductBatchBloc, ProductBatchState>(
                      builder: (context, state) {
                        if (state is ProductBatchEmpty) {
                          return Container();
                        } else if (state is ProductBatchLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is AllProductBatchLoaded) {
                          return _buildProductBatchItems(
                              state.productBatchList);
                        } else if (state is OrderedByExpiryDate) {
                          return _buildProductBatchItems(
                              state.productBatchList);
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            Icon(Icons.directions_bike),
            Icon(Icons.directions_car)
          ]),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddProductBatchView()));
              },
          ),
        ));
  }
}

Widget _buildProductBatchItems(List<ProductBatch> productBatchList) {
  var formatter = new DateFormat('dd-MM-yy');
  return DataTable(
    columns: [
      DataColumn(label: Text('Датум истек')),
      DataColumn(label: Text('Производ')),
      DataColumn(label: Text('Количина'), numeric: true),
      DataColumn(label: Text('Баркод')),
    ],
    rows: productBatchList
        .map((_batch) => DataRow(cells: [
              DataCell(Text(_batch.expirationDate)),
              DataCell(Text(_batch.productId.toString())),
              DataCell(Text(_batch.barCode)),
              DataCell(Text(_batch.quantity.toString())),
            ]))
        .toList(),
  );
}


//class _ProductBatchDataSource extends DataTableSource {
//  _ProductDataSource(batchList) {
//    _batchList = batchList;
//  }
//
//  List<ProductBatch> _batchList;
//
//
//  void _sort<T>(Comparable<T> getField(ProductBatch d), bool ascending) {
//    _desserts.sort((a, b) {
//      final Comparable<T> aValue = getField(a);
//      final Comparable<T> bValue = getField(b);
//      return ascending
//          ? Comparable.compare(aValue, bValue)
//          : Comparable.compare(bValue, aValue);
//    });
//    notifyListeners();
//  }
//
//  int _selectedCount = 0;
//
//  @override
//  DataRow getRow(int index) {
//    final format = NumberFormat.decimalPercentPattern(
//      locale: GalleryOptions.of(context).locale.toString(),
//      decimalDigits: 0,
//    );
//    assert(index >= 0);
//    if (index >= _desserts.length) return null;
//    final _Dessert dessert = _desserts[index];
//    return DataRow.byIndex(
//      index: index,
//      selected: dessert.selected,
//      onSelectChanged: (value) {
//        if (dessert.selected != value) {
//          _selectedCount += value ? 1 : -1;
//          assert(_selectedCount >= 0);
//          dessert.selected = value;
//          notifyListeners();
//        }
//      },
//      cells: [
//        DataCell(Text(dessert.name)),
//        DataCell(Text('${dessert.calories}')),
//        DataCell(Text(dessert.fat.toStringAsFixed(1))),
//        DataCell(Text('${dessert.carbs}')),
//        DataCell(Text(dessert.protein.toStringAsFixed(1))),
//        DataCell(Text('${dessert.sodium}')),
//        DataCell(Text('${format.format(dessert.calcium / 100)}')),
//        DataCell(Text('${format.format(dessert.iron / 100)}')),
//      ],
//    );
//  }
//
//  @override
//  int get rowCount => _desserts.length;
//
//  @override
//  bool get isRowCountApproximate => false;
//
//  @override
//  int get selectedRowCount => _selectedCount;
//
//  void _selectAll(bool checked) {
//    for (final _Dessert dessert in _desserts) {
//      dessert.selected = checked;
//    }
//    _selectedCount = checked ? _desserts.length : 0;
//    notifyListeners();
//  }
//}