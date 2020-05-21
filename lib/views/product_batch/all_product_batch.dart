import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets.dart/custom_table.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBatchTable extends StatefulWidget {
  final bool orderByDate;
  final Function callBack;
  final BuildContext scaffoldContext;

  const ProductBatchTable({
    Key key,
    this.orderByDate,
    this.callBack,
    this.scaffoldContext,
  }) : super(key: key);
  @override
  _ProductBatchTableState createState() => _ProductBatchTableState();
}

class _ProductBatchTableState extends State<ProductBatchTable> {
  bool orderByDate;
  AppDatabase db;
  @override
  // bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = InheritedDataProviderHelper.of(context).database;
    BlocProvider.of<ProductBatchBloc>(context).add(AllProductBatch());
  }

  @override
  Widget build(BuildContext context) {
    orderByDate = widget.orderByDate;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: BlocListener<ProductBatchBloc, ProductBatchState>(
            listener: (context, state) {
              if (state is SyncProductDataSuccess) {
                Scaffold.of(widget.scaffoldContext).removeCurrentSnackBar();
                Scaffold.of(widget.scaffoldContext).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.green,
                    content: Text(state.message),
                  ),
                );
              } else if (state is UploadProductBatchesSuccess) {
                Scaffold.of(widget.scaffoldContext).removeCurrentSnackBar();
                Scaffold.of(widget.scaffoldContext).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.green,
                    content: Text(state.message),
                  ),
                );
              } else if (state is ProductBatchError) {
                Scaffold.of(widget.scaffoldContext).removeCurrentSnackBar();
                Scaffold.of(widget.scaffoldContext).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.redAccent,
                    content: Text(state.error),
                  ),
                );
              } else if (state is ProductBatchAdded) {
                Scaffold.of(widget.scaffoldContext).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.greenAccent,
                    content: Text("Успешно додадовте нова пратка."),
                  ),
                );
              }
            },
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
        ),
      ),
    );
  }

  Widget _buildProductBatchItems(List<ProductBatch> productBatchList) {
    var cellWidth = MediaQuery.of(context).size.width / 4;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: OutlineButton(
                  onPressed: () {
                    BlocProvider.of<ProductBatchBloc>(context)
                      ..add(SyncProductBatchData())
                      ..add(AllProductBatch());
                  },
                  child: Text(
                    'Синхронизирај податоци',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: OutlineButton(
                  onPressed: () {
                    BlocProvider.of<ProductBatchBloc>(context)
                      ..add(UploadProductBatchData())
                      ..add(AllProductBatch());
                  },
                  child: Text(
                    'Снимај податоци на сервер',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        customDataTable(
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
                  BlocProvider.of<ProductBatchBloc>(context)
                      .add(AllProductBatch());
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
                    DataCell(
                      Container(
                          child: Text(_batch.formatDateTime()),
                          width: cellWidth,
                          color:
                              !_batch.synced ? Colors.red : Colors.transparent),
                    ),
                    DataCell(
                      CustomDataCell(
                        db: db,
                        width: cellWidth,
                        productId: _batch.productId,
                      ),
                    ),
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
        ),
      ],
    );
  }
}

class CustomDataCell extends StatefulWidget {
  final int productId;
  final double width;
  final AppDatabase db;
  const CustomDataCell({Key key, this.productId, this.width, this.db})
      : super(key: key);

  @override
  _CustomDataCellState createState() => _CustomDataCellState();
}

class _CustomDataCellState extends State<CustomDataCell> {
  Future<String> getProductName;

  @override
  void didChangeDependencies() {
    getProductName = _getProduct();
    super.didChangeDependencies();
  }

  Future<String> _getProduct() async {
    Product product;
    try {
      product = await widget.db.productDao.getByServerId(widget.productId);
    } catch (e) {}
    return product.name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getProductName,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: Text("Something went wrong..."),
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Container();
            case ConnectionState.waiting:
              return Container(
                child: CircularProgressIndicator(),
                width: widget.width,
              );
            case ConnectionState.active:
              return Container(
                  child: CircularProgressIndicator(), width: widget.width);
            case ConnectionState.done:
              return Container(child: Text(snapshot.data), width: widget.width);
          }
          return null;
        });
  }
}
