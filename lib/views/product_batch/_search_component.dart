import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/dependencies/debouncer.dart';
import 'package:date_checker_app/dependencies/dependency_assembler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchInputWidget extends StatefulWidget {
  @override
  _SearchInputWidgetState createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  final _controller = TextEditingController();
  Debouncer debouncer = dependencyAssembler.get<Debouncer>();

  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.text.length >= 3) {
        debouncer.run(() {
          BlocProvider.of<ProductBatchBloc>(context).add(
            FilterProductBatch(
              inputValue: _controller.text,
            ),
          );
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Пребарајте пратка',
            suffixIcon: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.red,
              ),
              onPressed: () {
                _controller.clear();
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                BlocProvider.of<ProductBatchBloc>(context).add(
                  AllProductBatch(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
