import 'package:date_checker_app/database/models.dart';
import 'package:equatable/equatable.dart';

abstract class UnsyncedProductBachState extends Equatable {
  const UnsyncedProductBachState();

  @override
  List<Object> get props => [];
}

class UnsyncedProductsLoading extends UnsyncedProductBachState {}

class UnsyncedProductsLoaded extends UnsyncedProductBachState {
  final List<ProductBatch> unsyncProductBatches;
  final List<ProductBatch> unsavedProductBatches;

  UnsyncedProductsLoaded(
      {this.unsyncProductBatches, this.unsavedProductBatches});

  @override
  List<Object> get props => [unsyncProductBatches, unsavedProductBatches];
}
