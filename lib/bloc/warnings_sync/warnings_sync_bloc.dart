import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/repository/batch_warning_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SyncBatchWarningBloc
    extends Bloc<SyncBatchWarningEvent, SyncBatchWarningsState> {
  final BatchWarningBloc batchWarningBloc;
  final BatchWarningRepository batchWarningRepository;

  SyncBatchWarningBloc({
    this.batchWarningBloc,
    this.batchWarningRepository,
  });

  @override
  SyncBatchWarningsState get initialState => EmptySyncBatchWarningState();

  @override
  Stream<SyncBatchWarningsState> mapEventToState(
      SyncBatchWarningEvent event) async* {
    if (event is SyncBatchWarnings) {
      try {
        int returnedNumber = await this.batchWarningRepository.syncWarnings();
        if (returnedNumber == 0) {
          yield SyncBatchWarningDataSuccess(message: 'Нема нови податоци.');
        } else {
          yield SyncBatchWarningDataSuccess(
              message: 'Успешно ги синхронизиравте податоците.');
          batchWarningBloc.add(AllBatchWarnings());
        }
      } catch (e) {
        yield SyncBatchWarningDataError(
            error: 'Грешка при ажурирање на податоците');
      }
    }
  }
}
