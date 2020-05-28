import 'package:date_checker_app/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getflutter/getflutter.dart';

class UnsyncedBatchTracker extends StatefulWidget {
  final Function callback;

  const UnsyncedBatchTracker({Key key, this.callback}) : super(key: key);
  @override
  _UnsyncedBatchTrackerState createState() => _UnsyncedBatchTrackerState();
}

class _UnsyncedBatchTrackerState extends State<UnsyncedBatchTracker> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnsyncedProductBatchBloc, UnsyncedProductBachState>(
      builder: (context, state) {
        if (state is UnsyncedProductsLoading) {
          return Container();
        } else if (state is UnsyncedProductsLoaded) {
          return GFButtonBadge(
            color: Colors.transparent,
            textColor: Colors.redAccent,
            borderSide: BorderSide(color: Colors.redAccent),
            onPressed: () {
              widget.callback();
            },
            text: 'Unsynchronized',
            icon: GFBadge(
              child: Text(
                  state.unsyncProductBatches.length.toString() ?? 0.toString()),
            ),
          );
        }
        return Container();
      },
    );
  }
}

class UnsavedWarningsTracker extends StatefulWidget {
  final Function callback;

  const UnsavedWarningsTracker({Key key, this.callback}) : super(key: key);

  @override
  _UnsavedWarningsTrackerState createState() => _UnsavedWarningsTrackerState();
}

class _UnsavedWarningsTrackerState extends State<UnsavedWarningsTracker> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnsyncedProductBatchBloc, UnsyncedProductBachState>(
      builder: (context, state) {
        if (state is UnsyncedProductsLoading) {
          return Container();
        } else if (state is UnsyncedProductsLoaded) {
          return GFButtonBadge(
            color: Colors.transparent,
            textColor: Colors.green,
            borderSide: BorderSide(color: Colors.green),
            onPressed: () {
              widget.callback();
            },
            text: 'New unsaved',
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
}
