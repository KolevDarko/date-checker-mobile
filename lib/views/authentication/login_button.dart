import 'package:date_checker_app/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback _onPressed;

  const LoginButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  _saveBatchWarnings(BuildContext context) {
    BlocProvider.of<ProductSyncBloc>(context).add(SyncProductData());
    BlocProvider.of<ProductBloc>(context).add(FetchAllProducts());
    BlocProvider.of<ProductBatchBloc>(context)
      ..add(SyncProductBatchData())
      ..add(AllProductBatch());
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Theme.of(context).appBarTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: () {
        _onPressed();
        _saveBatchWarnings(context);
      },
      child: Text(
        'Login',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
