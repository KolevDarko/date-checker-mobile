import 'package:date_checker_app/repository/repository.dart';
import 'package:flutter/material.dart';

DataColumn customDataColumn({
  BuildContext context,
  String label,
  Function filterCallback,
  Function updatedFilterCallback,
  double cellWidth,
  ProductBatchFilter filter,
  ProductBatchFilter currentFilter,
}) {
  return DataColumn(
    label: Container(
      width: cellWidth,
      child: Row(
        children: <Widget>[
          Container(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
              child: filter == currentFilter
                  ? Icon(Icons.arrow_drop_down)
                  : Container()),
        ],
      ),
    ),
    onSort: (i, b) {
      if (filter != currentFilter) {
        filterCallback();
      } else {
        updatedFilterCallback();
      }
    },
  );
}
