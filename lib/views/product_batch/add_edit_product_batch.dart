import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/custom_product_picker.dart';

import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/dependencies/date_time_formatter.dart';

import 'package:date_checker_app/repository/product_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class AddOrEditProductBatchView extends StatefulWidget {
  final ProductBatch productBatch;
  final Product product;

  const AddOrEditProductBatchView({
    Key key,
    this.productBatch,
    this.product,
  }) : super(key: key);
  @override
  _AddOrEditProductBatchViewState createState() =>
      _AddOrEditProductBatchViewState();
}

class _AddOrEditProductBatchViewState extends State<AddOrEditProductBatchView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _barCode;
  TextEditingController _quantity;
  TextEditingController _expirationDate;

  FocusNode _barCodeNode = FocusNode();
  FocusNode _quantityNode = FocusNode();
  FocusNode _expirationDateNode = FocusNode();

  DateTime expirationDate;
  Product _selectedProduct;

  ProductBatch productBatch;

  @override
  void initState() {
    productBatch = widget.productBatch ?? null;
    _barCode = TextEditingController(text: productBatch?.barCode ?? '');
    _quantity = TextEditingController(
        text: productBatch != null ? productBatch.quantity.toString() : '');
    _expirationDate = TextEditingController(
      text: productBatch != null
          ? DateTimeFormatter.formatDateDMY(
              productBatch.expirationDate,
              shortYear: false,
            )
          : '',
    );
    _selectedProduct = widget.product ?? null;
    expirationDate = productBatch != null
        ? DateTimeFormatter.dateTimeParser(productBatch.expirationDate)
        : null;
    super.initState();
  }

  @override
  void dispose() {
    _barCodeNode.dispose();
    _quantityNode.dispose();
    _expirationDateNode.dispose();
    _barCode.dispose();
    _quantity.dispose();
    _expirationDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: productBatch == null
            ? Text("Додај нова пратка")
            : Text("Промени пратка"),
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
                  labelText: 'Бар код',
                ),
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_quantityNode);
                },
                validator: (value) {
                  if (value.length < 2) {
                    return 'Бар кодот мора да биде најмалку 2 карактери.';
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
                  labelText: 'Количина',
                ),
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_expirationDateNode);
                },
                validator: (value) {
                  var parsedStringNumber = int.tryParse(value);

                  if (value.length == 0) {
                    return 'Ова поле не може да биде празно.';
                  } else if (parsedStringNumber.runtimeType != int) {
                    return 'Количината мора да биде број';
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
                  labelText: 'Датум на истекување',
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
                    currentTime: productBatch != null
                        ? DateTimeFormatter.dateTimeParser(
                            productBatch.expirationDate)
                        : DateTime.now(),
                    locale: LocaleType.en,
                  );
                },
                validator: (value) {
                  if (value.length == 0) {
                    return 'Ова поле не може да биде празно.';
                  } else if (value.length < 2) {
                    return 'Ова поле мора да биде најмалку 2 карактери.';
                  }
                  return null;
                },
              ),
              ProductPickerField(
                initialValue: widget.product ?? null,
                context: context,
                onSaved: (val) {
                  _selectedProduct = val;
                },
                validator: (val) {
                  if (val == null) {
                    return 'Ова поле не може да биде празно.';
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
                    color: Colors.green,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if (productBatch == null) {
                          ProductBatch productBatch = ProductBatch(
                            null,
                            null,
                            _barCode.text,
                            _selectedProduct.serverId,
                            int.tryParse(_quantity.text),
                            expirationDate.toString(),
                            false,
                            "${DateTime.now()}",
                            "${DateTime.now()}",
                            _selectedProduct.name,
                          );
                          BlocProvider.of<ProductBatchBloc>(context).add(
                            AddProductBatch(productBatch: productBatch),
                          );
                        } else {
                          productBatch.productId = _selectedProduct.serverId;
                          productBatch.productName = _selectedProduct.name;
                          productBatch.barCode = _barCode.text;
                          productBatch.quantity = int.tryParse(_quantity.text);
                          productBatch.expirationDate =
                              expirationDate.toString();
                          productBatch.synced = false;
                          productBatch.updated = DateTime.now().toString();
                          BlocProvider.of<ProductBatchBloc>(context).add(
                            EditProductBatch(productBatch: productBatch),
                          );
                        }

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
