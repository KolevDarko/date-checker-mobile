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
  AppDatabase db;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = InheritedDataProviderHelper.of(context).database;
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
                DataCell(
                  CustomDataCell(
                    database: this.db,
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
    );
  }
}

class CustomDataCell extends StatefulWidget {
  final AppDatabase database;
  final int productId;
  final double width;
  const CustomDataCell({Key key, this.database, this.productId, this.width})
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
      product = await widget.database.productDao.get(widget.productId);
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
