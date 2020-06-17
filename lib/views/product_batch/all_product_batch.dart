import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/button_with_indicator.dart';
import 'package:date_checker_app/custom_widgets/custom_data_column.dart';
import 'package:date_checker_app/custom_widgets/custom_table.dart';
import 'package:date_checker_app/custom_widgets/route_animation.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/date_time_formatter.dart';
import 'package:date_checker_app/main.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:date_checker_app/views/product_batch/_search_component.dart';
import 'package:date_checker_app/views/product_batch/add_edit_product_batch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBatchTable extends StatefulWidget {
  const ProductBatchTable({
    Key key,
  }) : super(key: key);
  @override
  _ProductBatchTableState createState() => _ProductBatchTableState();
}

class _ProductBatchTableState extends State<ProductBatchTable>
    with AutomaticKeepAliveClientMixin {
  ProductBatchFilter filter;
  AppDatabase db;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = InheritedDataProviderHelper.of(context).database;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: BlocListener<ProductBatchBloc, ProductBatchState>(
            listener: (context, state) {
              if (state is UploadProductBatchesSuccess) {
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.green,
                    content: Text(state.message),
                  ),
                );
              } else if (state is ProductBatchError) {
                Scaffold.of(context).removeCurrentSnackBar();

                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.redAccent,
                    content: Text(state.error),
                  ),
                );
              } else if (state is ProductBatchAdded) {
                Scaffold.of(context).removeCurrentSnackBar();

                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.greenAccent,
                    content: Text("Успешно додадовте нова пратка."),
                  ),
                );
              } else if (state is ProductBatchEditSuccess) {
                Scaffold.of(context).removeCurrentSnackBar();

                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.greenAccent,
                    content: Text(state.message),
                  ),
                );
              }
            },
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: BlocProvider<UnsyncedProductBatchBloc>(
                          create: (BuildContext context) =>
                              UnsyncedProductBatchBloc(
                            productBatchBloc:
                                BlocProvider.of<ProductBatchBloc>(context),
                          ),
                          child: ButtonWithIndicator(
                            buttonIndicator: ButtonIndicator.EditedBatches,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: BlocProvider<UnsyncedProductBatchBloc>(
                          create: (BuildContext context) =>
                              UnsyncedProductBatchBloc(
                            productBatchBloc:
                                BlocProvider.of<ProductBatchBloc>(context),
                          ),
                          child: ButtonWithIndicator(
                            buttonIndicator: ButtonIndicator.NewUnsavedBatches,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: SearchInputWidget(),
                ),
                BlocBuilder<ProductBatchBloc, ProductBatchState>(
                  builder: (context, state) {
                    if (state is ProductBatchEmpty) {
                      return Container();
                    } else if (state is ProductBatchLoading) {
                      return Center(
                        child: Container(),
                      );
                    } else if (state is AllProductBatchLoaded) {
                      return _buildProductBatchItems(state.productBatchList);
                    } else if (state is FilteredBatches) {
                      filter = state.filter;
                      return _buildProductBatchItems(state.productBatchList);
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _updatedFilterCallback(List<ProductBatch> items) {
    BlocProvider.of<ProductBatchBloc>(context).add(FilterEvent(
      productBatchList: items,
      filter: ProductBatchFilter.updated,
    ));
  }

  _filterCallBack(List<ProductBatch> items, ProductBatchFilter filter) {
    BlocProvider.of<ProductBatchBloc>(context).add(FilterEvent(
      productBatchList: items,
      filter: filter,
    ));
  }

  Widget _buildProductBatchItems(List<ProductBatch> productBatchList) {
    var cellWidth = MediaQuery.of(context).size.width / 4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: customDataTable(
        context: context,
        columns: [
          customDataColumn(
            context: context,
            label: 'Дата Истек',
            cellWidth: cellWidth,
            filter: ProductBatchFilter.expiryDate,
            currentFilter: filter,
            filterCallback: () => _filterCallBack(
              productBatchList,
              ProductBatchFilter.expiryDate,
            ),
            updatedFilterCallback: () => _updatedFilterCallback(
              productBatchList,
            ),
          ),
          customDataColumn(
            context: context,
            label: 'Производ',
            cellWidth: cellWidth,
            filter: ProductBatchFilter.productName,
            currentFilter: filter,
            filterCallback: () => _filterCallBack(
              productBatchList,
              ProductBatchFilter.productName,
            ),
            updatedFilterCallback: () => _updatedFilterCallback(
              productBatchList,
            ),
          ),
          customDataColumn(
            context: context,
            label: 'Количина',
            cellWidth: cellWidth,
            filter: ProductBatchFilter.quantity,
            currentFilter: filter,
            filterCallback: () => _filterCallBack(
              productBatchList,
              ProductBatchFilter.quantity,
            ),
            updatedFilterCallback: () => _updatedFilterCallback(
              productBatchList,
            ),
          ),
          customDataColumn(
            context: context,
            label: 'Баркод',
            cellWidth: cellWidth,
            filter: ProductBatchFilter.barCode,
            currentFilter: filter,
            filterCallback: () => _filterCallBack(
              productBatchList,
              ProductBatchFilter.barCode,
            ),
            updatedFilterCallback: () => _updatedFilterCallback(
              productBatchList,
            ),
          ),
        ],
        rows: productBatchList
            .map(
              (_batch) => DataRow(
                onSelectChanged: (val) async {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  Product product =
                      await this.db.productDao.getByServerId(_batch.productId);
                  if (val) {
                    Navigator.of(context).push(
                      createRoute(
                        AddOrEditProductBatchView(
                          productBatch: _batch,
                          product: product,
                        ),
                      ),
                    );
                  }
                },
                cells: [
                  DataCell(
                    Container(
                      child: Text(
                        DateTimeFormatter.formatDateDMY(_batch.expirationDate),
                        style: TextStyle(
                          color: _textColor(_batch),
                        ),
                      ),
                      width: cellWidth,
                    ),
                  ),
                  DataCell(
                    Container(
                      child: Text(
                        "${_batch.productName}",
                        style: TextStyle(
                          color: _textColor(_batch),
                        ),
                      ),
                      width: cellWidth,
                    ),
                  ),
                  DataCell(
                    Container(
                      child: Text(
                        "${_batch.quantity}",
                        style: TextStyle(
                          color: _textColor(_batch),
                        ),
                      ),
                      width: cellWidth,
                    ),
                  ),
                  DataCell(
                    Container(
                        child: Text(
                          _batch.barCode,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _textColor(_batch),
                          ),
                        ),
                        width: cellWidth),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Color _textColor(ProductBatch batch) {
    if (batch.serverId == null) {
      return Colors.green;
    } else if (batch.synced == false && batch.serverId == null) {
      return Colors.green;
    } else if (batch.synced == false) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }
}
