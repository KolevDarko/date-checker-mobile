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

class SyncBatchWarnings extends BatchWarningEvent {
  @override
  List<Object> get props => null;
}

class BWProductBatchClosed extends BatchWarningEvent {
  final String message;

  BWProductBatchClosed(this.message);

  @override
  List<Object> get props => [message];
}

class UploadEditedWarnings extends BatchWarningEvent {
  final List<BatchWarning> warnings;

  UploadEditedWarnings({this.warnings});

  @override
  List<Object> get props => [warnings];
}
