import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets.dart/custom_table.dart';
import 'package:date_checker_app/views/product_warning/edit_product_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatchWarningTable extends StatefulWidget {
  final BuildContext scaffoldContext;

  const BatchWarningTable({Key key, this.scaffoldContext}) : super(key: key);
  @override
  _BatchWarningTableState createState() => _BatchWarningTableState();
}

class _BatchWarningTableState extends State<BatchWarningTable> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var cellWidth = MediaQuery.of(context).size.width / 4;
    return BlocListener<BatchWarningBloc, BatchWarningState>(
      listener: (context, state) {
        if (state is Success) {
          Scaffold.of(widget.scaffoldContext).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
              content: Text(
                  'Успешно ја променивте количината на ${state.productName}. Сега е проверен и отстранет од табелата на внимание.'),
            ),
          );
        }
      },
      child: BlocBuilder<BatchWarningBloc, BatchWarningState>(
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
                        Text('Денови пред истек', overflow: TextOverflow.clip)),
                DataColumn(label: Text('Количина')),
                DataColumn(label: Text('')),
              ],
              rows: state.allBatchWarning.map((warning) {
                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                          child: Text(warning.productName), width: cellWidth),
                    ),
                    DataCell(
                      Container(
                          child: Text(
                            "${warning.daysLeft}",
                            style: TextStyle(
                              color: warning.priorityColor(),
                            ),
                          ),
                          width: cellWidth),
                    ),
                    DataCell(
                      GestureDetector(
                        onTap: () {
                          // openQuantityEditModal();
                        },
                        child: Container(
                          child: Text("${warning.newQuantity}"),
                          width: cellWidth,
                        ),
                      ),
                    ),
                    DataCell(
                      RaisedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuantityEdit(
                                oldQuantity: warning.oldQuantity,
                                batchWarning: warning,
                              ),
                            ),
                          );
                        },
                        child: Text('Kopce'),
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
        },
      ),
    );
  }
}
