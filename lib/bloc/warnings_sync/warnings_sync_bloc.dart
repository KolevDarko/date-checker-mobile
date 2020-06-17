import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/repository/batch_warning_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SyncBatchWarningBloc
    extends Bloc<SyncBatchWarningEvent, SyncBatchWarningsState> {
  final BatchWarningBloc batchWarningBloc;
  final BatchWarningRepository batchWarningRepository;

  static const NO_NEW_WARNINGS = 'Нема нови податоци.';
  static const NEW_WARNINGS_SYNCED = 'Успешно ги синхронизиравте податоците.';
  static const ERROR_SYNC_WARNINGS = 'Грешка при ажурирање на податоците';

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
          yield SyncBatchWarningDataSuccess(message: NO_NEW_WARNINGS);
        } else {
          yield SyncBatchWarningDataSuccess(message: NEW_WARNINGS_SYNCED);
          batchWarningBloc.add(AllBatchWarnings());
        }
      } catch (e) {
        yield SyncBatchWarningDataError(error: ERROR_SYNC_WARNINGS);
      }
    }
  }
}
