abstract class ProductSyncState {
  const ProductSyncState();
}

class EmptySyncProductState extends ProductSyncState {
  const EmptySyncProductState();
}

class SyncProductDataSuccess extends ProductSyncState {
  final String message;

  const SyncProductDataSuccess({this.message});
}

class SyncProductDataError extends ProductSyncState {
  final String error;

  const SyncProductDataError({this.error});
}
