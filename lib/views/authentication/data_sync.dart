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

  @override
  void initState() {
    super.initState();

    Future(() {
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomePage()));
    });
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
  void didChangeDependencies() {
    saveBatchWarnings = _saveBatchWarnings();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Sync'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: saveBatchWarnings,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.none) {
            return Container();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Container();
          }
        },
      ),
    );
  }
}
