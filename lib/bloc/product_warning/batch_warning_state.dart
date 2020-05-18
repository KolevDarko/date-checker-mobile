import 'package:date_checker_app/database/models.dart';
import 'package:equatable/equatable.dart';

abstract class BatchWarningState extends Equatable {
  const BatchWarningState();

  @override
  List<Object> get props => [];
}

class BatchWarningEmpty extends BatchWarningState {}

class BatchWarningLoading extends BatchWarningState {}

class BatchWarningAllLoaded extends BatchWarningState {
  final List<BatchWarning> allBatchWarning;

  BatchWarningAllLoaded({this.allBatchWarning});
}

class SyncBatchWarningsSuccess extends BatchWarningState {
  final String message;

  SyncBatchWarningsSuccess({this.message});
}

class BatchWarningError extends BatchWarningState {
  final String error;

  BatchWarningError({this.error});
}

class Success extends BatchWarningState {
  final String productName;

  Success({this.productName});
}
