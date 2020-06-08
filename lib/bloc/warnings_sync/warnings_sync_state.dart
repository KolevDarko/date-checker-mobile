abstract class SyncBatchWarningsState {
  const SyncBatchWarningsState();
}

class EmptySyncBatchWarningState extends SyncBatchWarningsState {
  const EmptySyncBatchWarningState();
}

class SyncBatchWarningDataSuccess extends SyncBatchWarningsState {
  final String message;

  const SyncBatchWarningDataSuccess({this.message});
}

class SyncBatchWarningDataError extends SyncBatchWarningsState {
  final String error;

  const SyncBatchWarningDataError({this.error});
}
