import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/route_animation.dart';

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

    productBatchSubscription =
        BlocProvider.of<ProductBatchBloc>(context).listen(
      (state) {
        if (state is AllProductBatchLoaded) {
          productBatchSubscription.cancel();
          Navigator.of(context).push(
            createRoute(
              HomePage(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    productBatchSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
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
