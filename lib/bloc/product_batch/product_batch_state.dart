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
}
