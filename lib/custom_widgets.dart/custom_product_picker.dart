import 'package:date_checker_app/database/models.dart';
import 'package:flutter/material.dart';

class ProductPickerField extends FormField<Product> {
  final BuildContext context;
  final List<Product> products;

  ProductPickerField({
    FormFieldSetter<Product> onSaved,
    FormFieldValidator<Product> validator,
    bool autovalidate = false,
    this.context,
    this.products,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            autovalidate: autovalidate,
            builder: (FormFieldState<Product> state) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ItemPickerDialog(
                          items: products,
                          label: "Продукт",
                        );
                      }).then((val) {
                    state.didChange(val);
                    state.save();
                  });
                },
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1.0,
                              color:
                                  state.hasError ? Colors.red : Colors.black),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      height: 50.0,
                      child: state.value != null
                          ? Text(state.value.toString())
                          : Text(
                              'Product',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16.0),
                            ),
                    ),
                    state.hasError
                        ? Container(
                            padding: EdgeInsets.only(top: 5.0),
                            alignment: Alignment.centerLeft,
                            child: Text(state.errorText,
                                style: TextStyle(
                                    color: Colors.red, fontSize: 12.0)),
                          )
                        : Container(),
                  ],
                ),
              );
            });
}

class ItemPickerDialog<T> extends StatefulWidget {
  final List<T> items;
  final String label;

  const ItemPickerDialog({
    Key key,
    this.items,
    this.label,
  }) : super(key: key);
  @override
  _ItemPickerDialogState createState() => _ItemPickerDialogState();
}

class _ItemPickerDialogState<T> extends State<ItemPickerDialog> {
  TextEditingController inputController = TextEditingController();
  List<T> filteredItems = [];
  List<T> allItems;

  @override
  void initState() {
    print(widget.items);
    allItems = List.from(widget.items);
    filteredItems = allItems;
    inputController.addListener(() {
      filterItems();
    });
    super.initState();
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
              controller: inputController,
            ),
            Column(
              children: _buildDialogItems(filteredItems),
            ),
          ],
        ),
      ),
    );
  }

  filterItems() {
    if (inputController.text.length > 0) {
      setState(() {
        filteredItems = allItems.where((item) {
          if (item is Product) {
            return item.barCode.contains(inputController.text) ||
                item.name.contains(inputController.text);
          } else if (item is ProductBatch) {
            return item.barCode.contains(inputController.text);
          }
          return null;
        }).toList();
      });
    }
  }

  List<Widget> _buildDialogItems(List<T> filteredItems) {
    List<Widget> dialogItems = [];
    for (var item in filteredItems) {
      dialogItems.add(GestureDetector(
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
      ));
    }
    return dialogItems;
  }
}
