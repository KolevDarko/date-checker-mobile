import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets.dart/custom_table.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/views/product_warning/edit_product_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

class BatchWarningTable extends StatefulWidget {

  @override
  _BatchWarningTableState createState() => _BatchWarningTableState();
}

class _BatchWarningTableState extends State<BatchWarningTable> {

  Client httpClient = Client();
  BatchWarningApiClient batchWarningApiClient;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    batchWarningApiClient = BatchWarningApiClient(httpClient: httpClient);
  }

  @override
  Widget build(BuildContext context) {
    var cellWidth = MediaQuery.of(context).size.width / 4;
    return Scaffold(
      appBar: AppBar(
          title: Text('Batch Warnings')),
      body: BlocListener<BatchWarningBloc, BatchWarningState>(
        listener: (context, state) {
          if (state is Success) {
            Scaffold.of(context).showSnackBar(
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
                      label: Text('Денови пред истек',
                          overflow: TextOverflow.clip)),
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
                              "${warning.expirationDate}",
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
                                builder: (context) =>
                                    QuantityEdit(
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
            return null;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<BatchWarning> test = await batchWarningApiClient.getNewBatchWarnings();
        },
        child: Icon(Icons.refresh),
      )
    );
  }
}
