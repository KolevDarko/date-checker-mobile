import 'package:flutter/material.dart';

Future<bool> confirmationDialog(
  BuildContext context,
  String title,
  String content,
) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          IconButton(
            color: Colors.redAccent,
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          IconButton(
            color: Colors.greenAccent,
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context, false);
            },
          )
        ],
      );
    },
  );
}
