import 'package:equatable/equatable.dart';
import 'package:date_checker_app/database/models.dart';

abstract class ProductBatchEvent extends Equatable {
  const ProductBatchEvent();
}

class AddProductBatch extends ProductBatchEvent {
  final ProductBatch productBatch;

  AddProductBatch({this.productBatch});

  @override
  List<Object> get props => [productBatch];
}

class GetProductBatch extends ProductBatchEvent {
  final int id;

  GetProductBatch(this.id);

  @override
  List<Object> get props => [id];
}

class OrderByExpiryDateEvent extends ProductBatchEvent {
  @override
  List<Object> get props => null;
}

class AllProductBatch extends ProductBatchEvent {
  @override
  List<Object> get props => null;
}

class SyncProductBatchData extends ProductBatchEvent {
  @override
  List<Object> get props => null;
}
