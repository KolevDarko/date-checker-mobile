import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnsyncWarningBloc extends Bloc<UnsyncWarningEvent, UnsyncedWarningState> {
  final BatchWarningBloc batchWarningBloc;
  StreamSubscription batchWarningBlocSubscription;

  UnsyncWarningBloc({this.batchWarningBloc}) {
    batchWarningBlocSubscription = batchWarningBloc.listen((state) {
      if (state is BatchWarningAllLoaded) {
        add(UnsyncWarningsUpdated(unsyncBatchWarnings: state.allBatchWarning));
      }
    });
  }

  @override
  UnsyncedWarningState get initialState {
    return batchWarningBloc.state is BatchWarningAllLoaded
        ? UnsyncedWarningsLoaded(
            unsyncWarnings: (batchWarningBloc.state as BatchWarningAllLoaded)
                .allBatchWarning,
          )
        : UnsyncedWarningsLoading();
  }

  @override
  Stream<UnsyncedWarningState> mapEventToState(UnsyncWarningEvent event) {
    throw UnimplementedError();
  }

  // TODO: implement filter for the unsynced batch warnings.
}
