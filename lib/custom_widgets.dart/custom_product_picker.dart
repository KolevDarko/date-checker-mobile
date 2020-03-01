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
                        return ProductPickerDialog(
                          products: products,
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
                                  color: state.hasError
                                      ? Colors.red
                                      : Colors.black))),
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

class ProductPickerDialog extends StatefulWidget {
  final List<Product> products;

  const ProductPickerDialog({Key key, this.products}) : super(key: key);
  @override
  _ProductPickerDialogState createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<ProductPickerDialog> {
  TextEditingController inputController = TextEditingController();
  List<Product> filteredProducts = [];
  List<Product> allProducts;

  @override
  void initState() {
    allProducts = List.from(widget.products);
    filteredProducts = allProducts;
    inputController.addListener(() {
      filterProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick a Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TextField(
              controller: inputController,
            ),
            Column(
              children: _buildDialogItems(filteredProducts),
            ),
          ],
        ),
      ),
    );
  }

  filterProducts() {
    if (inputController.text.length > 0) {
      setState(() {
        filteredProducts = allProducts
            .where((product) => product.barCode.contains(inputController.text))
            .toList();
      });
    }
  }

  List<Widget> _buildDialogItems(List<Product> productList) {
    List<Widget> dialogItems = [];
    for (Product product in filteredProducts) {
      dialogItems.add(GestureDetector(
        onTap: () {
          Navigator.pop(context, product);
        },
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 1.0))),
          child: Row(
            children: <Widget>[
              SizedBox(width: 8.0),
              Text("${product.toString()}"),
              SizedBox(width: 8.0),
            ],
          ),
        ),
      ));
    }
    return dialogItems;
  }
}
