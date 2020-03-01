import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets.dart/custom_table.dart';
import 'package:date_checker_app/database/models.dart';
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
