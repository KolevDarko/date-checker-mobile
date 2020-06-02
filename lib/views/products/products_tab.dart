import 'package:date_checker_app/custom_widgets/custom_table.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:flutter/material.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsTable extends StatefulWidget {
  const ProductsTable({Key key}) : super(key: key);

  @override
  _ProductsTableState createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable>
    with AutomaticKeepAliveClientMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductSyncDone) {
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Colors.green,
                content: Text(state.message),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductEmpty) {
                  return Container();
                } else if (state is ProductLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is AllProductsLoaded) {
                  return _buildProductBatchItems(state.products);
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

  Widget _buildProductBatchItems(List<Product> products) {
    var cellWidth = MediaQuery.of(context).size.width / 3;
    if (products.length > 0) {
      return customDataTable(
        context: context,
        columns: [
          DataColumn(label: Text('Назив')),
          DataColumn(label: Text('Цена')),
          DataColumn(label: Text('Баркод')),
        ],
        rows: products
            .map(
              (product) => DataRow(
                cells: [
                  DataCell(Container(
                      child: Text(product.name.toString()), width: cellWidth)),
                  DataCell(Container(
                      child: Text(product.price.toString()), width: cellWidth)),
                  DataCell(Container(
                      child: Text(
                        product.barCode,
                        overflow: TextOverflow.ellipsis,
                      ),
                      width: cellWidth)),
                ],
              ),
            )
            .toList(),
      );
    }
    return Container(
      child: Text('Empty'),
    );
  }
}
