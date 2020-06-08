import 'package:date_checker_app/database/models.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class ProductBatchState extends Equatable {
  const ProductBatchState();

  @override
  List<Object> get props => [];
}

class ProductBatchAdded extends ProductBatchState {
  final int productBatchId;

  ProductBatchAdded({this.productBatchId});
}

class ProductBatchEmpty extends ProductBatchState {}

class ProductBatchLoading extends ProductBatchState {}

class AllProductBatchLoaded extends ProductBatchState {
  final List<ProductBatch> productBatchList;

  AllProductBatchLoaded({this.productBatchList});
  List<Object> get props => [productBatchList];
}

class OrderedByExpiryDate extends ProductBatchState {
  final List<ProductBatch> productBatchList;

  OrderedByExpiryDate({this.productBatchList});
  List<Object> get props => [productBatchList];
}

class ProductBatchLoaded extends ProductBatchState {
  final ProductBatch productBatch;

  const ProductBatchLoaded({@required this.productBatch})
      : assert(productBatch != null);

  @override
  List<Object> get props => [productBatch];
}

class ProductBatchError extends ProductBatchState {
  final String error;

  ProductBatchError({this.error});
  @override
  List<Object> get props => [error];
}

class SyncProductBatchDataSuccess extends ProductBatchState {
  final String message;

  SyncProductBatchDataSuccess({this.message});
  @override
  List<Object> get props => [message];
}

class UploadProductBatchesSuccess extends ProductBatchState {
  final String message;

  UploadProductBatchesSuccess({this.message});
  @override
  List<Object> get props => [message];
}

class ProductBatchClosedState extends ProductBatchState {
  final String message;

  ProductBatchClosedState({this.message});

  @override
  List<Object> get props => [message];
}

class ProductBatchEditSuccess extends ProductBatchState {
  final String message;

  ProductBatchEditSuccess({this.message});

  @override
  List<Object> get props => [message];
}
