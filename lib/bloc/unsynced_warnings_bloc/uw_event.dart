import 'package:date_checker_app/database/models.dart';
import 'package:equatable/equatable.dart';

abstract class UnsyncWarningEvent extends Equatable {
  const UnsyncWarningEvent();
}

class UnsyncWarningsUpdated extends UnsyncWarningEvent {
  final List<BatchWarning> unsyncBatchWarnings;

  UnsyncWarningsUpdated({this.unsyncBatchWarnings});
  @override
  List<Object> get props => [unsyncBatchWarnings];
}
