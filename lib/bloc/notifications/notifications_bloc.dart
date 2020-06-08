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
        this.add(AddNewErrorNotification(error: state.error));
      }
    });
    syncBatchWarningBlocSubscription = syncBatchWarningBloc.listen((state) {
      if (state is SyncBatchWarningDataSuccess) {
        this.add(AddNewNotification(message: state.message));
      } else if (state is SyncBatchWarningDataError) {
        this.add(AddNewErrorNotification(error: state.error));
      }
    });
  }

  @override
  NotificationState get initialState => EmptyNotification();

  @override
  Stream<NotificationState> mapEventToState(NotificationsEvent event) async* {
    if (event is AddNewNotification) {
      yield DisplayNotification(message: event.message);
    } else if (event is AddNewErrorNotification) {
      yield DisplayErrorNotification(error: event.error);
    }
  }

  @override
  Future<void> close() {
    productSyncBlocSubscription?.cancel();
    syncBatchWarningBlocSubscription?.cancel();
    return super.close();
  }
}
