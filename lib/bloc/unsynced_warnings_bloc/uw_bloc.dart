import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/models.dart';
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
            unsyncWarnings: _mapCheckedBatchWarnings(
              (batchWarningBloc.state as BatchWarningAllLoaded).allBatchWarning,
            ),
          )
        : UnsyncedWarningsLoading();
  }

  @override
  Stream<UnsyncedWarningState> mapEventToState(
      UnsyncWarningEvent event) async* {
    if (event is UnsyncWarningsUpdated) {
      yield* _mapCheckedWarningsToState(event);
    }
  }

  Stream<UnsyncedWarningState> _mapCheckedWarningsToState(
      UnsyncWarningEvent event) async* {
    if (batchWarningBloc.state is BatchWarningAllLoaded) {
      yield UnsyncedWarningsLoaded(
        unsyncWarnings: _mapCheckedBatchWarnings(
          (batchWarningBloc.state as BatchWarningAllLoaded).allBatchWarning,
        ),
      );
    }
  }

  List<BatchWarning> _mapCheckedBatchWarnings(List<BatchWarning> warnings) {
    return warnings
        .where(
          (warning) => warning.status == BatchWarning.batchWarningStatus()[1],
        )
        .toList();
  }

  @override
  Future<void> close() {
    batchWarningBlocSubscription?.cancel();
    return super.close();
  }
}
