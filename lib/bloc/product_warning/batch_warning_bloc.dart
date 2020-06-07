import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/bloc/product_warning/batch_warning_event.dart';
import 'package:date_checker_app/bloc/product_warning/batch_warning_state.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatchWarningBloc extends Bloc<BatchWarningEvent, BatchWarningState> {
  final BatchWarningRepository batchWarningRepository;
  final ProductBatchBloc productBatchBloc;
  StreamSubscription productBatchSubscription;

  BatchWarningBloc({this.productBatchBloc, this.batchWarningRepository}) {
    productBatchSubscription = productBatchBloc.listen((state) {
      if (state is ProductBatchClosedState) {
        add(BWProductBatchClosed(
            (productBatchBloc.state as ProductBatchClosedState).message));
        add(AllBatchWarnings());
      }
    });
  }

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
        String message = await batchWarningRepository.updateQuantity(
            event.quantity, event.batchWarning);
        productBatchBloc.add(AllProductBatch());
        yield Success(message: message);
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
    } else if (event is BWProductBatchClosed) {
      yield Success(message: event.message);
    } else if (event is UploadEditedWarnings) {
      yield BatchWarningLoading();
      try {
        await this.batchWarningRepository.uploadEditedWarnings(event.warnings);
        yield Success(message: 'Успешно ги снимавте истекувањата на серверот');
        productBatchBloc.add(AllProductBatch());
      } catch (e) {
        yield BatchWarningError(
            error: 'Грешка при снимањето на истекувањата на серверот');
      }
    }
  }

  @override
  Future<void> close() {
    productBatchSubscription.cancel();
    return super.close();
  }
}
