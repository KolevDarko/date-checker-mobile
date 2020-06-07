import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationState> {
  final SyncBatchWarningBloc syncBatchWarningBloc;
  final ProductSyncBloc productSyncBloc;

  StreamSubscription syncBatchWarningBlocSubscription;
  StreamSubscription productSyncBlocSubscription;

  NotificationsBloc({
    this.syncBatchWarningBloc,
    this.productSyncBloc,
  }) {
    productSyncBlocSubscription = productSyncBloc.listen((state) {
      if (state is SyncProductDataSuccess) {
        this.add(AddNewNotification(message: state.message));
      } else if (state is SyncProductDataError) {
        this.add(AddNewNotification(message: state.error));
      }
    });
    syncBatchWarningBlocSubscription = syncBatchWarningBloc.listen((state) {
      if (state is SyncBatchWarningDataSuccess) {
        this.add(AddNewNotification(message: state.message));
      } else if (state is SyncBatchWarningDataError) {
        this.add(AddNewNotification(message: state.error));
      }
    });
  }

  @override
  NotificationState get initialState => EmptyNotification();

  @override
  Stream<NotificationState> mapEventToState(NotificationsEvent event) async* {
    if (event is AddNewNotification) {
      yield* _mapEventsToState(event);
    }
  }

  Stream<NotificationState> _mapEventsToState(NotificationsEvent event) async* {
    if (productSyncBloc.state is SyncProductDataSuccess) {
      yield DisplayNotification(
        message: (productSyncBloc.state as SyncProductDataSuccess).message,
      );
    } else if (productSyncBloc.state is SyncProductDataError) {
      yield DisplayNotification(
        message: (productSyncBloc.state as SyncProductDataError).error,
      );
    } else if (syncBatchWarningBloc.state is SyncBatchWarningDataSuccess) {
      yield DisplayNotification(
        message:
            (syncBatchWarningBloc.state as SyncBatchWarningDataSuccess).message,
      );
    } else if (syncBatchWarningBloc.state is SyncBatchWarningDataError) {
      yield DisplayNotification(
        message:
            (syncBatchWarningBloc.state as SyncBatchWarningDataError).error,
      );
    }
  }

  @override
  Future<void> close() {
    productSyncBlocSubscription.cancel();
    syncBatchWarningBlocSubscription.cancel();
    return super.close();
  }
}
