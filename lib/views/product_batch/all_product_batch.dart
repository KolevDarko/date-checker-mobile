import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/button_with_indicator.dart';
import 'package:date_checker_app/custom_widgets/custom_table.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/debouncer.dart';
import 'package:date_checker_app/dependencies/dependency_assembler.dart';
import 'package:date_checker_app/main.dart';
import 'package:date_checker_app/views/product_batch/unsynced_components_tracker.dart';
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
  // @override
  // bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = InheritedDataProviderHelper.of(context).database;
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
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: ButtonWithIndicator(
                          buttonIndicator: ButtonIndicator.EditedBatches,
                          callback: () {
                            BlocProvider.of<ProductBatchBloc>(context)
                              ..add(UploadProductBatchData())
                              ..add(AllProductBatch());
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: ButtonWithIndicator(
                          buttonIndicator: ButtonIndicator.NewUnsavedBatches,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductBatchItems(List<ProductBatch> productBatchList) {
    var cellWidth = MediaQuery.of(context).size.width / 4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: customDataTable(
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
                      child: Text(
                        _batch.formatDateTime(),
                        style: TextStyle(
                          color: _textColor(_batch),
                        ),
                      ),
                      width: cellWidth,
                    ),
                  ),
                  DataCell(
                    CustomDataCell(
                      db: db,
                      width: cellWidth,
                      productId: _batch.productId,
                      color: _textColor(_batch),
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
                  DataCell(Container(
                      child: Text(
                        _batch.barCode,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textColor(_batch),
                        ),
                      ),
                      width: cellWidth)),
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

class CustomDataCell extends StatefulWidget {
  final int productId;
  final double width;
  final AppDatabase db;
  final Color color;
  const CustomDataCell({
    Key key,
    this.productId,
    this.width,
    this.db,
    this.color,
  }) : super(key: key);

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
              child: Container(),
              width: widget.width,
            );
          case ConnectionState.active:
            return Container(
                child: CircularProgressIndicator(), width: widget.width);
          case ConnectionState.done:
            return Container(
                child: Text(
                  snapshot.data,
                  style: TextStyle(
                    color: widget.color,
                  ),
                ),
                width: widget.width);
        }
        return null;
      },
    );
  }
}

class SearchInputWidget extends StatefulWidget {
  @override
  _SearchInputWidgetState createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  final _controller = TextEditingController();
  Debouncer debouncer = dependencyAssembler.get<Debouncer>();

  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.text.length >= 3) {
        debouncer.run(() {
          BlocProvider.of<ProductBatchBloc>(context).add(
            FilterProductBatch(
              inputValue: _controller.text,
            ),
          );
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Пребарајте пратка',
            suffixIcon: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.red,
              ),
              onPressed: () {
                _controller.clear();
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                BlocProvider.of<ProductBatchBloc>(context).add(
                  AllProductBatch(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
