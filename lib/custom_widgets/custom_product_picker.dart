import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/debouncer.dart';
import 'package:date_checker_app/dependencies/dependency_assembler.dart';
import 'package:date_checker_app/main.dart';
import 'package:flutter/material.dart';

class ProductPickerField extends FormField<Product> {
  final BuildContext context;

  ProductPickerField({
    FormFieldSetter<Product> onSaved,
    FormFieldValidator<Product> validator,
    bool autovalidate = false,
    this.context,
    initialValue,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          autovalidate: autovalidate,
          initialValue: initialValue,
          builder: (FormFieldState<Product> state) {
            return GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return ItemPickerDialog(
                        label: "Продукт",
                      );
                    }).then((val) {
                  if (val != null) {
                    state.didChange(val);
                    state.save();
                  }
                });
              },
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            color: state.hasError ? Colors.red : Colors.black),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    height: 50.0,
                    child: state.value != null
                        ? Text(state.value.toString())
                        : Text(
                            'Продукт',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16.0),
                          ),
                  ),
                  state.hasError
                      ? Container(
                          padding: EdgeInsets.only(top: 5.0),
                          alignment: Alignment.centerLeft,
                          child: Text(state.errorText,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 12.0)),
                        )
                      : Container(),
                ],
              ),
            );
          },
        );
}

class ItemPickerDialog<T> extends StatefulWidget {
  final String label;
  final AppDatabase database;

  const ItemPickerDialog({
    Key key,
    this.label,
    this.database,
  }) : super(key: key);
  @override
  _ItemPickerDialogState createState() => _ItemPickerDialogState();
}

class _ItemPickerDialogState<T> extends State<ItemPickerDialog> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> filteredItems = [];
  AppDatabase db;
  List<dynamic> allItems;
  Debouncer debouncer = dependencyAssembler.get<Debouncer>();

  @override
  void initState() {
    _controller.addListener(() {
      debouncer.run(() async {
        await filterItems();
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    db = InheritedDataProviderHelper.of(context).database;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Избери ${widget.label}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(hintText: "Внесете име на производ."),
              controller: _controller,
            ),
            Column(
              children: _buildDialogItems(filteredItems),
            ),
          ],
        ),
      ),
    );
  }

  filterItems() async {
    List<dynamic> filtered = [];
    if (_controller.text.length > 0) {
      filtered = await this
          .db
          .productDao
          .getProductsBySearchTerm(_controller.text.toUpperCase());
    }
    setState(() {
      filteredItems = filtered;
    });
  }

  List<Widget> _buildDialogItems(List<T> filteredItems) {
    List<Widget> dialogItems = [];
    if (filteredItems.length > 0) {
      for (var item in filteredItems) {
        dialogItems.add(
          GestureDetector(
            onTap: () {
              Navigator.pop(context, item);
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration:
                  BoxDecoration(border: Border(bottom: BorderSide(width: 1.0))),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "${item.toString()}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      dialogItems.add(Container(
        child: Text("Нема производи со внесениот внесениот израз."),
      ));
    }
    return dialogItems;
  }
}
