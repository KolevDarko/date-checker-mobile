import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataSync extends StatefulWidget {
  @override
  _DataSyncState createState() => _DataSyncState();
}

class _DataSyncState extends State<DataSync> {
  Future<void> saveBatchWarnings;
  StreamSubscription productBatchSubscription;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveBatchWarnings() async {
    BlocProvider.of<ProductBloc>(context)
      ..add(SyncProductData())
      ..add(FetchAllProducts());
    BlocProvider.of<ProductBatchBloc>(context)
      ..add(SyncProductBatchData())
      ..add(AllProductBatch());
  }

  @override
  void dispose() {
    productBatchSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    saveBatchWarnings = _saveBatchWarnings();
    productBatchSubscription =
        BlocProvider.of<ProductBatchBloc>(context).listen((state) {
      if (state is AllProductBatchLoaded) {
        Navigator.push(
            context, MaterialPageRoute(builder: (ctx) => HomePage()));
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Sync'),
        centerTitle: true,
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
