import 'package:date_checker_app/database/models.dart';
import 'package:equatable/equatable.dart';

abstract class UnsyncProductBatchesEvent extends Equatable {
  const UnsyncProductBatchesEvent();
}

class UnsyncUpdated extends UnsyncProductBatchesEvent {
  final List<ProductBatch> unsyncProductBatches;

  UnsyncUpdated({this.unsyncProductBatches});
  @override
  List<Object> get props => [unsyncProductBatches];
}
