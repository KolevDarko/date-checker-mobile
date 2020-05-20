import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/dependencies/debouncer.dart';
import 'package:date_checker_app/dependencies/dependency_assembler.dart';
import 'package:date_checker_app/views/product_batch/add_product_batch.dart';
import 'package:date_checker_app/views/product_batch/all_product_batch.dart';
import 'package:date_checker_app/views/product_warning/all_product_warnings.dart';
import 'package:date_checker_app/views/products/products_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool orderByExpiry = false;
  int _currentTabIndex = 0;
  BuildContext scaffoldContext;

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
              onTap: (int currentTabIndex) {
                setState(() {
                  _currentTabIndex = currentTabIndex;
                });
              },
              tabs: [
                Tab(icon: Text('Пратки')),
                Tab(icon: Text('Истекување')),
                Tab(icon: Text("Производи")),
              ],
            ),
            title: Text('Date Checker Tabs')),
        body: Builder(
          builder: (BuildContext context) {
            scaffoldContext = context;
            return TabBarView(
              children: [
                ProductBatchTable(
                  orderByDate: orderByExpiry,
                  callBack: toggleOrderByExpiry,
                  scaffoldContext: context,
                ),
                BatchWarningTable(
                  scaffoldContext: context,
                ),
                ProductsTable(
                  scaffoldContext: context,
                ),
              ],
            );
          },
        ),
        floatingActionButton: customFloatingButton(_currentTabIndex),
      ),
    );
  }

  FloatingActionButton customFloatingButton(int _currentTabIndex) {
    switch (_currentTabIndex) {
      case 0:
        {
          return FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddProductBatchView(
                      repository: BlocProvider.of<ProductBloc>(context)
                          .productRepository),
                ),
              );
            },
            child: Icon(Icons.add),
          );
        }
        break;
      case 1:
        {
          return FloatingActionButton(
            onPressed: () async {
              BlocProvider.of<BatchWarningBloc>(context)
                ..add(SyncBatchWarnings())
                ..add(AllBatchWarnings());
            },
            child: Icon(Icons.refresh),
          );
        }
        break;
      case 2:
        {
          return FloatingActionButton(
            onPressed: () {
              BlocProvider.of<ProductBloc>(context)
                ..add(SyncProductData())
                ..add(FetchAllProducts());
            },
            child: Icon(Icons.refresh),
          );
        }
    }
    return null;
  }
}
