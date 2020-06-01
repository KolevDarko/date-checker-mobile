import 'package:date_checker_app/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getflutter/getflutter.dart';

enum ButtonIndicator { EditedBatches, NewUnsavedBatches, EditedWarnings }

class ButtonWithIndicator extends StatefulWidget {
  final Function callback;
  final ButtonIndicator buttonIndicator;

  const ButtonWithIndicator({Key key, this.callback, this.buttonIndicator})
      : super(key: key);
  @override
  _ButtonWithIndicatorState createState() => _ButtonWithIndicatorState();
}

class _ButtonWithIndicatorState extends State<ButtonWithIndicator> {
  @override
  Widget build(BuildContext context) {
    return _blocPicker();
  }

  Widget _blocPicker() {
    switch (widget.buttonIndicator) {
      case ButtonIndicator.EditedBatches:
        {
          return BlocBuilder<UnsyncedProductBatchBloc,
              UnsyncedProductBachState>(
            builder: (context, state) {
              if (state is UnsyncedProductsLoading) {
                return Container();
              } else if (state is UnsyncedProductsLoaded) {
                return GFButtonBadge(
                  color: Colors.transparent,
                  textColor: Colors.redAccent,
                  borderSide: BorderSide(color: Colors.redAccent),
                  onPressed: () {
                    // BlocProvider.of<ProductBatchBloc>(context)
                    //   ..add(UploadEditedProductBatches(editedProductBatches: state.unsyncProductBatches))
                    //   ..add(AllProductBatch());
                  },
                  text: 'Променети',
                  icon: GFBadge(
                    child: Text(state.unsyncProductBatches.length.toString() ??
                        0.toString()),
                  ),
                );
              }
              return Container();
            },
          );
        }
        break;
      case ButtonIndicator.NewUnsavedBatches:
        {
          return BlocBuilder<UnsyncedProductBatchBloc,
              UnsyncedProductBachState>(
            builder: (context, state) {
              if (state is UnsyncedProductsLoading) {
                return Container();
              } else if (state is UnsyncedProductsLoaded) {
                return GFButtonBadge(
                  color: Colors.transparent,
                  textColor: Colors.green,
                  borderSide: BorderSide(color: Colors.green),
                  onPressed: () {
                    // BlocProvider.of<ProductBatchBloc>(context)
                    //   ..add(UploadProductBatchData(newBatches: state.unsavedProductBatches))
                    //   ..add(AllProductBatch());
                  },
                  text: 'Нови',
                  icon: GFBadge(
                    color: Colors.green,
                    child: Text(state.unsavedProductBatches.length.toString() ??
                        0.toString()),
                  ),
                );
              }
              return Container();
            },
          );
        }
      case ButtonIndicator.EditedWarnings:
        {
          return BlocBuilder<UnsyncWarningBloc, UnsyncedWarningState>(
            builder: (context, state) {
              if (state is UnsyncedWarningsLoading) {
                return Container();
              } else if (state is UnsyncedWarningsLoaded) {
                return GFButtonBadge(
                  color: Colors.transparent,
                  textColor: Colors.orange,
                  borderSide: BorderSide(color: Colors.orange),
                  onPressed: () {
                    // BlocProvider.of<BatchWarningBloc>(context)
                    //   ..add(UploadEditedWarnings(warnings: state.unsyncWarnings))
                    //   ..add(AllBatchWarnings());
                  },
                  text: 'Проверени',
                  icon: GFBadge(
                    color: Colors.orange,
                    child: Text(
                      state.unsyncWarnings.length.toString() ?? 0.toString(),
                    ),
                  ),
                );
              }
              return Container();
            },
          );
        }
      default:
        return Container();
    }
  }
}
