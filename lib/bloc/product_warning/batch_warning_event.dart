import 'package:date_checker_app/database/models.dart';
import 'package:equatable/equatable.dart';

abstract class BatchWarningEvent extends Equatable {
  const BatchWarningEvent();
}

class AllBatchWarnings extends BatchWarningEvent {
  @override
  List<Object> get props => null;
}

class EditQuantityEvent extends BatchWarningEvent {
  final int quantity;
  final BatchWarning batchWarning;

  EditQuantityEvent({this.quantity, this.batchWarning});
  @override
  List<Object> get props => [batchWarning];
}
