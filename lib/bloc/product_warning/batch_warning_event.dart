import 'package:equatable/equatable.dart';

abstract class BatchWarningEvent extends Equatable {
  const BatchWarningEvent();
}

class AllBatchWarnings extends BatchWarningEvent {
  @override
  List<Object> get props => null;
}
