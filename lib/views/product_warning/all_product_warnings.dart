import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/custom_table.dart';
import 'package:date_checker_app/custom_widgets/button_with_indicator.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/views/product_warning/edit_product_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatchWarningTable extends StatefulWidget {
  const BatchWarningTable({Key key}) : super(key: key);
  @override
  _BatchWarningTableState createState() => _BatchWarningTableState();
}

class _BatchWarningTableState extends State<BatchWarningTable>
    with AutomaticKeepAliveClientMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    var cellWidth = MediaQuery.of(context).size.width / 3;

    return BlocListener<BatchWarningBloc, BatchWarningState>(
      listener: (context, state) {
        if (state is Success) {
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 4),
              backgroundColor: Colors.green,
              content: Text(state.message),
            ),
          );
        } else if (state is BatchWarningError) {
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 4),
              backgroundColor: Colors.redAccent,
              content: Text(state.error),
            ),
          );
        }
      },
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: BlocProvider<UnsyncWarningBloc>(
              create: (BuildContext context) => UnsyncWarningBloc(
                  batchWarningBloc: BlocProvider.of<BatchWarningBloc>(context)),
              child: ButtonWithIndicator(
                buttonIndicator: ButtonIndicator.EditedWarnings,
              ),
            ),
          ),
          BlocBuilder<BatchWarningBloc, BatchWarningState>(
            builder: (context, state) {
              if (state is BatchWarningEmpty) {
                return Container();
              } else if (state is BatchWarningLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is BatchWarningAllLoaded) {
                return customDataTable(
                  context: context,
                  columns: [
                    DataColumn(
                        label: Text(
                      'Производ',
                    )),
                    DataColumn(
                      label:
                          Text('Датум на истек', overflow: TextOverflow.clip),
                    ),
                    DataColumn(
                      label: Text('Количина'),
                    ),
                  ],
                  rows: state.allBatchWarning.map((warning) {
                    return DataRow(
                      onSelectChanged: (selected) {
                        if (selected) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuantityEdit(
                                oldQuantity: warning.newQuantity,
                                batchWarning: warning,
                              ),
                            ),
                          );
                        }
                      },
                      cells: [
                        DataCell(
                          Container(
                            child: Text(
                              warning.productName,
                              style: _textStylePicker(warning),
                            ),
                            width: cellWidth,
                          ),
                        ),
                        DataCell(
                          Container(
                              child: Text(
                                "${warning.expirationDate}",
                                style: TextStyle(
                                  color: warning.priorityColor(),
                                ),
                              ),
                              width: cellWidth),
                        ),
                        DataCell(
                          GestureDetector(
                            child: Container(
                              child: Text(
                                "${warning.newQuantity}",
                                style: _textStylePicker(warning),
                              ),
                              width: cellWidth,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              } else if (state is BatchWarningError) {
                return Center(
                  child: Text(state.error),
                );
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  TextStyle _textStylePicker(BatchWarning warning) {
    switch (warning.status) {
      case 'NEW':
        {
          return TextStyle(color: Colors.black);
        }
        break;
      case 'CHECKED':
        {
          return TextStyle(color: Colors.orange);
        }
    }
    return TextStyle(color: Colors.black);
  }
}
