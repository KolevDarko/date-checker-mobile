import 'package:equatable/equatable.dart';

abstract class ProductSyncEvent extends Equatable {
  const ProductSyncEvent();
}

class SyncProductData extends ProductSyncEvent {
  @override
  List<Object> get props => null;
}
