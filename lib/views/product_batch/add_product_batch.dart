import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets.dart/custom_product_picker.dart';

import 'package:date_checker_app/database/models.dart';

import 'package:date_checker_app/repository/product_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class AddProductBatchView extends StatefulWidget {
  @override
  _AddProductBatchViewState createState() => _AddProductBatchViewState();
}

class _AddProductBatchViewState extends State<AddProductBatchView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _barCode = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _expirationDate = TextEditingController();

  Product _selectedProduct;
  ProductRepository productRepository = ProductRepository();

  FocusNode _barCodeNode = FocusNode();
  FocusNode _quantityNode = FocusNode();
  FocusNode _expirationDateNode = FocusNode();

  List<Product> products;
  DateTime expirationDate;

  @override
  void initState() {
    loadProducts();
    super.initState();
  }

  loadProducts() async {
    List<Product> products123 = await productRepository.getAllProducts();

    setState(() {
      products = products123;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product Batch"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _barCode,
                focusNode: _barCodeNode,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Bar Code',
                ),
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_quantityNode);
                },
                validator: (value) {
                  if (value.length < 2) {
                    return 'Bar Code must be atleast 2 characters.';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _quantity,
                focusNode: _quantityNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                ),
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_expirationDateNode);
                },
                validator: (value) {
                  var parsedStringNumber = int.tryParse(value);

                  if (value.length == 0) {
                    return 'Field is required';
                  } else if (parsedStringNumber.runtimeType != int) {
                    return 'Quantity must be a number';
                  }
                  return null;
                },
              ),
              TextFormField(
                readOnly: true,
                controller: _expirationDate,
                focusNode: _expirationDateNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                ),
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_expirationDateNode);
                },
                onTap: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime(2018, 3, 5),
                    maxTime: DateTime(2030, 6, 7),
                    onConfirm: (date) {
                      setState(() {
                        var newDate = DateFormat.yMMMd().format(date);
                        _expirationDate.text = newDate.toString();
                        expirationDate = date;
                      });
                    },
                    currentTime: DateTime.now(),
                    locale: LocaleType.en,
                  );
                },
                validator: (value) {
                  if (value.length == 0) {
                    return 'Field is required';
                  } else if (value.length < 2) {
                    return 'Bar Code must be atleast 2 characters.';
                  }
                  return null;
                },
              ),
              ProductPickerField(
                products: products,
                context: context,
                onSaved: (val) {
                  _selectedProduct = val;
                },
                validator: (val) {
                  if (val == null) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 40.0,
              ),
              Builder(builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        ProductBatch productBatch = ProductBatch(
                            null,
                            _barCode.text,
                            _selectedProduct.id,
                            int.tryParse(_quantity.text),
                            "$expirationDate",
                            "${DateTime.now()}",
                            "${DateTime.now()}");
                        // AppDatabase db = await DbProvider.instance.database;
                        // await db.productBatchDao.add(productBatch);
                        BlocProvider.of<ProductBatchBloc>(context)
                            .add(AddProductBatch(productBatch: productBatch));
                        BlocProvider.of<ProductBatchBloc>(context)
                            .add(AllProductBatch());
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Снимај'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
