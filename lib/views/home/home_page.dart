import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/views/product_batch/add_product_batch.dart';
import 'package:date_checker_app/views/product_batch/all_product_batch.dart';
import 'package:date_checker_app/views/product_warning/all_product_warnings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
