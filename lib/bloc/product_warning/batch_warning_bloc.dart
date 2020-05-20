import 'package:date_checker_app/bloc/product_warning/batch_warning_event.dart';
import 'package:date_checker_app/bloc/product_warning/batch_warning_state.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatchWarningBloc extends Bloc<BatchWarningEvent, BatchWarningState> {
  final BatchWarningRepository batchWarningRepository;

  BatchWarningBloc({this.batchWarningRepository});

  @override
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
    } else if (event is EditQuantityEvent) {
      try {
        await batchWarningRepository.updateQuantity(
            event.quantity, event.batchWarning);
        yield Success(productName: event.batchWarning.productName);
      } catch (e) {
        yield BatchWarningError(error: 'Грешка при зачувување на промени.');
      }
    } else if (event is SyncBatchWarnings) {
      yield BatchWarningLoading();
      try {
        String message = await this.batchWarningRepository.syncWarnings();
        yield SyncBatchWarningsSuccess(message: message);
      } catch (e) {
        yield BatchWarningError(error: 'Грешка при ажурирање на податоците');
      }
    }
  }
}
