import 'package:date_checker_app/custom_widgets.dart/custom_table.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:flutter/material.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsTable extends StatefulWidget {
  @override
  _ProductsTableState createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
