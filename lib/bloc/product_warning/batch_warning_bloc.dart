import 'package:date_checker_app/bloc/product_warning/batch_warning_event.dart';
import 'package:date_checker_app/bloc/product_warning/batch_warning_state.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatchWarningBloc extends Bloc<BatchWarningEvent, BatchWarningState> {
  final BatchWarningRepository batchWarningRepository;

  BatchWarningBloc({this.batchWarningRepository});

  @override
  // TODO: implement initialState
  BatchWarningState get initialState => BatchWarningEmpty();

  @override
  Stream<BatchWarningState> mapEventToState(BatchWarningEvent event) async* {
    if (event is AllBatchWarnings) {
      yield BatchWarningLoading();
      try {
        List<BatchWarning> allWarnings =
            await batchWarningRepository.warnings();
        yield BatchWarningAllLoaded(allBatchWarning: allWarnings);
      } catch (e) {
        yield BatchWarningError(error: 'Грешка при превземање на пратки');
      }
    }
  }
}
