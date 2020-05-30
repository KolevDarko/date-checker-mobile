import 'package:flutter/material.dart';

Widget customDataTable({
  BuildContext context,
  List<DataColumn> columns,
  List<DataRow> rows,
}) {
  return SingleChildScrollView(
    child: FittedBox(
      child: DataTable(
        columnSpacing: 0.0,
        horizontalMargin: 0.0,
        columns: columns,
        rows: rows,
      ),
    ),
  );
}
