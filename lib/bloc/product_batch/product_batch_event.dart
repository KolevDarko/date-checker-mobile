import 'package:date_checker_app/repository/repository.dart';
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

class EditProductBatch extends ProductBatchEvent {
  final ProductBatch productBatch;

  EditProductBatch({this.productBatch});

  @override
  List<Object> get props => [productBatch];
}

class FilterEvent extends ProductBatchEvent {
  final List<ProductBatch> productBatchList;
  final ProductBatchFilter filter;

  FilterEvent({this.productBatchList, this.filter});
  @override
  List<Object> get props => [productBatchList, filter];
}

class AllProductBatch extends ProductBatchEvent {
  @override
  List<Object> get props => null;
}

class SyncProductBatchData extends ProductBatchEvent {
  @override
  List<Object> get props => null;
}

class UploadProductBatchData extends ProductBatchEvent {
  final List<ProductBatch> newBatches;

  UploadProductBatchData({this.newBatches});
  @override
  List<Object> get props => [newBatches];
}

class UploadEditedProductBatches extends ProductBatchEvent {
  final List<ProductBatch> editedProductBatches;

  UploadEditedProductBatches({this.editedProductBatches});
  @override
  List<Object> get props => [editedProductBatches];
}

class FilterProductBatch extends ProductBatchEvent {
  final ProductBatch productBatch;
  final String inputValue;

  FilterProductBatch({this.productBatch, this.inputValue});
  @override
  List<Object> get props => [productBatch, inputValue];
}

class RemoveProductBatch extends ProductBatchEvent {
  final BatchWarning warning;

  RemoveProductBatch({this.warning});

  @override
  List<Object> get props => [warning];
}
