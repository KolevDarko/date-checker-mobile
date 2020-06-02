import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/confirmation_dialog.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuantityEdit extends StatefulWidget {
  final int oldQuantity;
  final BatchWarning batchWarning;

  const QuantityEdit({Key key, this.oldQuantity, this.batchWarning})
      : super(key: key);
  @override
  _QuantityEditState createState() => _QuantityEditState();
}

class _QuantityEditState extends State<QuantityEdit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantity = TextEditingController();
  final FocusNode _quantityNode = FocusNode();

  @override
  void initState() {
    _quantity.text = (widget.oldQuantity).toString();
    super.initState();
  }

  @override
  void dispose() {
    _quantity.dispose();
    _quantityNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Промени Количина'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: TextFormField(
                  controller: _quantity,
                  focusNode: _quantityNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                  ),
                  onFieldSubmitted: (val) {
                    _quantityNode.unfocus();
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
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: RaisedButton(
                        color: Colors.greenAccent,
                        child: Text('Зачувај промени'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            int quantity = int.tryParse(_quantity.value.text);
                            if (widget.oldQuantity == quantity) {
                              Navigator.pop(context);
                            } else {
                              BlocProvider.of<BatchWarningBloc>(context)
                                ..add(
                                  EditQuantityEvent(
                                    quantity: quantity,
                                    batchWarning: widget.batchWarning,
                                  ),
                                )
                                ..add(AllBatchWarnings());
                              BlocProvider.of<BatchWarningBloc>(context);
                              BlocProvider.of<ProductBatchBloc>(context)
                                  .add(AllProductBatch());
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: RaisedButton(
                        color: Colors.redAccent,
                        onPressed: () async {
                          bool confirmed = await confirmationDialog(
                            context,
                            'Важно',
                            'Дали сте сигурни дека сакате да ја отстраните оваа пратка од базата на податоци?',
                          );
                          if (confirmed) {
                            BlocProvider.of<ProductBatchBloc>(context).add(
                              RemoveProductBatch(
                                warning: widget.batchWarning,
                              ),
                            );
                            BlocProvider.of<ProductBatchBloc>(context).add(
                              AllProductBatch(),
                            );
                          }
                        },
                        child: Text('Елиминирај пратка'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
