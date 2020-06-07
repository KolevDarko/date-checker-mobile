import 'package:equatable/equatable.dart';

abstract class SyncBatchWarningEvent extends Equatable {
  const SyncBatchWarningEvent();
}

class SyncBatchWarnings extends SyncBatchWarningEvent {
  @override
  List<Object> get props => null;
}
