import 'package:flutter/material.dart';

Widget customDataTable({
  BuildContext context,
  List<DataColumn> columns,
  List<DataRow> rows,
}) {
  return SingleChildScrollView(
    child: FittedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 0.0,
          horizontalMargin: 0.0,
          columns: columns,
          rows: rows,
        ),
      ),
    ),
  );
}
